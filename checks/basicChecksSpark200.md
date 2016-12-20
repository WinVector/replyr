Example trying most of the `replyr` on a Spark 2.0.0 local instance.

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
 #  [1] "tbl_spark" "tbl_sql"   "tbl_lazy"  "tbl"      
 #  [1] "src_spark"
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
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
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "gather/spread examples"
 #  Source:   query [?? x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    index  info meas1 meas2
 #    <dbl> <chr> <chr> <chr>
 #  1     1     a  m1_1  m2_1
 #  2     2     b  m1_2  m2_2
 #  3     3     c  m1_3  m2_3
 #  
 #   dg %>% replyr::replyr_gather(c('meas1','meas2'),'meastype','meas')
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    index meastype  meas
 #    <dbl>    <chr> <chr>
 #  1     1    meas1  m1_1
 #  2     2    meas1  m1_2
 #  3     3    meas1  m1_3
 #  4     1    meas2  m2_1
 #  5     2    meas2  m2_2
 #  6     3    meas2  m2_3
 #  
 #   ds %>% replyr::replyr_spread('index','meastype','meas')
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    index meas1 meas2
 #    <dbl> <chr> <chr>
 #  1     1  m1_1  m2_1
my_db <- NULL; gc() # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  543614 29.1     940480 50.3   940480 50.3
 #  Vcells 1230147  9.4    2095378 16.0  1676963 12.8
```
