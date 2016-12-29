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
sumgroup <- list(group_by=sumgroupG,split=sumgroupS,extract=sumgroupS)
sumgroup <- list('TRUE'=sumgroupG,'FALSE'=sumgroupS)

rank_in_group <- . %>% mutate(constcol=1) %>% mutate(rank=cumsum(constcol)) %>% select(-constcol)
```

In memory example.

``` r
for(partitionMethod in c('group_by','split','extract')) {
  print(partitionMethod)
  print('cumulative sum example')
  print(d %>% gapply('group',cumulative_sum,ocolumn='order',
                     partitionMethod=partitionMethod))
  print('summary example')
  print(d %>% gapply('group',sumgroup[[partitionMethod]],
                     partitionMethod=partitionMethod))
  print('ranking example')
  print(d %>% gapply('group',rank_in_group,ocolumn='order',
                     partitionMethod=partitionMethod))
  print('ranking example (decreasing)')
  print(d %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
                     partitionMethod=partitionMethod))
}
 #  [1] "group_by"
 #  [1] "cumulative sum example"
 #  # A tibble: 5 × 4
 #    group order values    cv
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10    10
 #  2     1   0.2     20    30
 #  3     2   0.3      2     2
 #  4     2   0.4      4     6
 #  5     2   0.5      8    14
 #  [1] "summary example"
 #  # A tibble: 5 × 3
 #    group order values
 #    <dbl> <dbl>  <dbl>
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
 #  # A tibble: 5 × 4
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     1   0.1     10     1
 #  2     1   0.2     20     2
 #  3     2   0.3      2     1
 #  4     2   0.4      4     2
 #  5     2   0.5      8     3
 #  [1] "ranking example (decreasing)"
 #  # A tibble: 5 × 4
 #    group order values  rank
 #    <dbl> <dbl>  <dbl> <dbl>
 #  1     2   0.5      8     1
 #  2     2   0.4      4     2
 #  3     2   0.3      2     3
 #  4     1   0.2     20     1
 #  5     1   0.1     10     2
 #  [1] "split"
 #  [1] "cumulative sum example"
 #    group order values cv
 #  1     1   0.1     10 10
 #  2     1   0.2     20 30
 #  3     2   0.3      2  2
 #  4     2   0.4      4  6
 #  5     2   0.5      8 14
 #  [1] "summary example"
 #    group order values
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
 #    group order values rank
 #  1     1   0.1     10    1
 #  2     1   0.2     20    2
 #  3     2   0.3      2    1
 #  4     2   0.4      4    2
 #  5     2   0.5      8    3
 #  [1] "ranking example (decreasing)"
 #    group order values rank
 #  1     1   0.2     20    1
 #  2     1   0.1     10    2
 #  3     2   0.5      8    1
 #  4     2   0.4      4    2
 #  5     2   0.3      2    3
 #  [1] "extract"
 #  [1] "cumulative sum example"
 #    group order values cv
 #  1     1   0.1     10 10
 #  2     1   0.2     20 30
 #  3     2   0.3      2  2
 #  4     2   0.4      4  6
 #  5     2   0.5      8 14
 #  [1] "summary example"
 #    group order values
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
 #    group order values rank
 #  1     1   0.1     10    1
 #  2     1   0.2     20    2
 #  3     2   0.3      2    1
 #  4     2   0.4      4    2
 #  5     2   0.5      8    3
 #  [1] "ranking example (decreasing)"
 #    group order values rank
 #  1     1   0.2     20    1
 #  2     1   0.1     10    2
 #  3     2   0.5      8    1
 #  4     2   0.4      4    2
 #  5     2   0.3      2    3
```

`PostgreSQL` example.

``` r
#below only works for services which have a cumsum operator
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
dR <- replyr_copy_to(my_db,d,'dR')

for(partitionMethod in c('group_by','extract')) {
  print(partitionMethod)
  print('cumulative sum example')
  print(dR %>% gapply('group',cumulative_sum,ocolumn='order',
                     partitionMethod=partitionMethod))
  print('summary example')
  print(dR %>% gapply('group',sumgroup[[partitionMethod]],
                     partitionMethod=partitionMethod))
  print('ranking example')
  print(dR %>% gapply('group',rank_in_group,ocolumn='order',
                     partitionMethod=partitionMethod))
  print('ranking example (decreasing)')
  print(dR %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
                     partitionMethod=partitionMethod))
}
 #  [1] "group_by"
 #  [1] "cumulative sum example"
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
 #  [1] "summary example"
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values
 #    <dbl> <dbl>  <dbl>
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
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
 #  [1] "ranking example (decreasing)"
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
 #  [1] "extract"
 #  [1] "cumulative sum example"
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
 #  [1] "summary example"
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    group order values
 #    <dbl> <dbl>  <dbl>
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
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
 #  [1] "ranking example (decreasing)"
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
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  502470 26.9     940480 50.3   940480 50.3
 #  Vcells 1180642  9.1    2099627 16.1  2086820 16.0
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
dS <- replyr_copy_to(my_db,d,'dS')

for(partitionMethod in c('group_by','extract')) {
  print(partitionMethod)
  print('cumulative sum example')
  print(dS %>% gapply('group',cumulative_sum,ocolumn='order',
                     partitionMethod=partitionMethod))
  print('summary example')
  print(dS %>% gapply('group',sumgroup[[partitionMethod]],
                     partitionMethod=partitionMethod))
  print('ranking example')
  print(dS %>% gapply('group',rank_in_group,ocolumn='order',
                     partitionMethod=partitionMethod))
  print('ranking example (decreasing)')
  print(dS %>% gapply('group',rank_in_group,ocolumn='order',decreasing=TRUE,
                     partitionMethod=partitionMethod))
}
 #  [1] "group_by"
 #  [1] "cumulative sum example"
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
 #  [1] "summary example"
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values
 #    <dbl> <dbl>  <dbl>
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
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
 #  [1] "ranking example (decreasing)"
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
 #  [1] "extract"
 #  [1] "cumulative sum example"
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
 #  [1] "summary example"
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    group order values
 #    <dbl> <dbl>  <dbl>
 #  1     1   0.1     10
 #  2     1   0.2     20
 #  3     2   0.3      2
 #  4     2   0.4      4
 #  5     2   0.5      8
 #  [1] "ranking example"
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
 #  [1] "ranking example (decreasing)"
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
my_db <- NULL; gc();
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  569453 30.5     940480 50.3   940480 50.3
 #  Vcells 1239239  9.5    2099627 16.1  2086820 16.0
```
