`replyr::gapply` gives you the ability to apply a custom pipeline once per group of a data item with a user specified in-group order.

`data.frame` example.

``` r
library('dplyr')
 #  
 #  Attaching package: 'dplyr'
 #  The following objects are masked from 'package:stats':
 #  
 #      filter, lag
 #  The following objects are masked from 'package:base':
 #  
 #      intersect, setdiff, setequal, union
library('replyr')
d <- data.frame(group=c(1,1,2,2,2),
                order=c(.1,.2,.3,.4,.5),
                values=c(10,20,2,4,8))

# User supplied window functions.  These depend on known column names and
# the data back-end matching function names (such as cumsum).  The idea
# the user supplies one of these to gapply, and gapply
# organizes the calcuation (spliting on gcolumn, and optionally ordering
# on ocolumn).
cumulative_sum <- . %>% arrange(order) %>% mutate(cv=cumsum(values))

# split version of sumgroup
sumgroupS <- . %>% summarize(group=min(group), # pseudo aggregation, as group constant in groups
                   minv=min(values),maxv=max(values))
# group version of sumgroup
sumgroupG <- . %>% summarize(minv=min(values),maxv=max(values))
sumgroup <- list('TRUE'=sumgroupG,'FALSE'=sumgroupS)

rank_in_group <- . %>% mutate(constcol=1) %>% mutate(rank=cumsum(constcol)) %>% select(-constcol)

for(usegroups in c(FALSE,TRUE)) {
  print(d %>% gapply('group',cumulative_sum,ocolumn='order',
                            usegroups=usegroups))
  print(d %>% gapply('group',sumgroup[[as.character(usegroups)]],
                            usegroups=usegroups))
  print(d %>% gapply('group',rank_in_group,ocolumn='order',
                            usegroups=usegroups))
  print(d %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
                            usegroups=usegroups))
}
 #    group order values cv
 #  1     1   0.1     10 10
 #  2     1   0.2     20 30
 #  3     2   0.3      2  2
 #  4     2   0.4      4  6
 #  5     2   0.5      8 14
 #    group minv maxv
 #  1     1   10   20
 #  2     2    2    8
 #    group order values rank
 #  1     1   0.1     10    1
 #  2     1   0.2     20    2
 #  3     2   0.3      2    1
 #  4     2   0.4      4    2
 #  5     2   0.5      8    3
 #    group order values rank
 #  1     1   0.2     20    1
 #  2     1   0.1     10    2
 #  3     2   0.5      8    1
 #  4     2   0.4      4    2
 #  5     2   0.3      2    3
 #  # A tibble: 5 × 4
 #    group order values    cv
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10    10
 #  2     1   0.2     20    30
 #  3     2   0.3      2     2
 #  4     2   0.4      4     6
 #  5     2   0.5      8    14
 #  # A tibble: 2 × 3
 #    group  minv  maxv
 #    <dbl> <dbl> <dbl>
 #  1     1    10    20
 #  2     2     2     8
 #  # A tibble: 5 × 4
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10     1
 #  2     1   0.2     20     2
 #  3     2   0.3      2     1
 #  4     2   0.4      4     2
 #  5     2   0.5      8     3
 #  # A tibble: 5 × 4
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     2   0.5      8     1
 #  2     2   0.4      4     2
 #  3     2   0.3      2     3
 #  4     1   0.2     20     1
 #  5     1   0.1     10     2
```

`PostgreSQL` example.

``` r
#below only works for services which have a cumsum operator
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
dR <- replyr_copy_to(my_db,d,'dR')

for(usegroups in c(FALSE,TRUE)) {
  print(dR %>% gapply('group',cumulative_sum,ocolumn='order',
                      usegroups=usegroups))
  print(dR %>% gapply('group',sumgroup[[as.character(usegroups)]],
                      usegroups=usegroups))
  print(dR %>% gapply('group',rank_in_group,ocolumn='order',
                      usegroups=usegroups))
  print(dR %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
                      usegroups=usegroups))
}
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values    cv
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10    10
 #  2     1   0.2     20    30
 #  3     2   0.3      2     2
 #  4     2   0.4      4     6
 #  5     2   0.5      8    14
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group  minv  maxv
 #    <dbl> <dbl> <dbl>
 #  1     1    10    20
 #  2     2     2     8
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10     1
 #  2     1   0.2     20     2
 #  3     2   0.3      2     1
 #  4     2   0.4      4     2
 #  5     2   0.5      8     3
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.2     20     1
 #  2     1   0.1     10     2
 #  3     2   0.5      8     1
 #  4     2   0.4      4     2
 #  5     2   0.3      2     3
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values    cv
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10    10
 #  2     1   0.2     20    30
 #  3     2   0.3      2     2
 #  4     2   0.4      4     6
 #  5     2   0.5      8    14
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group  minv  maxv
 #    <dbl> <dbl> <dbl>
 #  1     1    10    20
 #  2     2     2     8
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10     1
 #  2     1   0.2     20     2
 #  3     2   0.3      2     1
 #  4     2   0.4      4     2
 #  5     2   0.5      8     3
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.2     20     1
 #  2     1   0.1     10     2
 #  3     2   0.5      8     1
 #  4     2   0.4      4     2
 #  5     2   0.3      2     3

my_db <- NULL; gc();
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 478344 25.6     940480 50.3   750400 40.1
 #  Vcells 726759  5.6    1380305 10.6  1305948 10.0
```

`Spark` example.

``` r
#below only works for services which have a cumsum operator
my_db <- sparklyr::spark_connect(version='2.0.0', 
                                 master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
dR <- replyr_copy_to(my_db,d,'dR')

for(usegroups in c(FALSE,TRUE)) {
  print(dR %>% gapply('group',cumulative_sum,ocolumn='order',
                      usegroups=usegroups))
  print(dR %>% gapply('group',sumgroup[[as.character(usegroups)]],
                      usegroups=usegroups))
  print(dR %>% gapply('group',rank_in_group,ocolumn='order',
                      usegroups=usegroups))
  print(dR %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
                      usegroups=usegroups))
}
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values    cv
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.2     20    30
 #  2     1   0.1     10    10
 #  3     2   0.3      2     2
 #  4     2   0.4      4     6
 #  5     2   0.5      8    14
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group  minv  maxv
 #    <dbl> <dbl> <dbl>
 #  1     2     2     8
 #  2     1    10    20
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10     1
 #  2     2   0.4      4     2
 #  3     2   0.3      2     1
 #  4     1   0.2     20     2
 #  5     2   0.5      8     3
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     2   0.5      8     1
 #  2     2   0.4      4     2
 #  3     1   0.2     20     1
 #  4     1   0.1     10     2
 #  5     2   0.3      2     3
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values    cv
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10    10
 #  2     1   0.2     20    30
 #  3     2   0.3      2     2
 #  4     2   0.4      4     6
 #  5     2   0.5      8    14
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group  minv  maxv
 #    <dbl> <dbl> <dbl>
 #  1     1    10    20
 #  2     2     2     8
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10     1
 #  2     1   0.2     20     2
 #  3     2   0.3      2     1
 #  4     2   0.4      4     2
 #  5     2   0.5      8     3
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.2     20     1
 #  2     1   0.1     10     2
 #  3     2   0.5      8     1
 #  4     2   0.4      4     2
 #  5     2   0.3      2     3

my_db <- NULL; gc();
 #  Auto-disconnecting postgres connection (84673, 0)
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 546400 29.2     940480 50.3   940480 50.3
 #  Vcells 787802  6.1    1380305 10.6  1315949 10.1
```
