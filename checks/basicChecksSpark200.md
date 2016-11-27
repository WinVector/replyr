Example trying most of the `replyr` on a Spark.

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
library('sparklyr')
source('CheckFns.R')
```

Spark 2.0.0. example.

``` r
# Can't easilly override Spark version once it is up.
my_db <- sparklyr::spark_connect(version='2.0.0', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
runExample(remoteCopy(my_db))
 #  Source:   query [?? x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     2     b
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      x     y 
 #   TRUE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 2 2
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 2
 #  
 #  d1 %>% replyr::replyr_str() 
 #  nrows: 2
 #  Observations: NA
 #  Variables: 2
 #  $ x <dbl> 1, 2
 #  $ y <chr> "a", "b"NULL
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3   NaN     z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    3    3 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z character     3   0       2  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3   NaN     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    3    3 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z character     3   0       2  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     b     3
 #  4     b     4
 #  5     c     5
 #  6     c     6
 #  [1] "a" "c"
 #  
 #  d3 %>% replyr::replyr_filter("x",values,verbose=FALSE) 
 #  Source:   query [?? x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  Source:   query [?? x 1]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  Source:   query [?? x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     3     2
 #  3     2     1
my_db <- NULL; gc() # disconnect
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 515750 27.6     940480 50.3   750400 40.1
 #  Vcells 731243  5.6    1308461 10.0   898023  6.9
```
