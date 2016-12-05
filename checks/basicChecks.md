Example trying most of the `replyr` functions on a few data sources.

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

Check `replyr` basic opearations against a few data service providers.
----------------------------------------------------------------------

Local `data.frame` example.

``` r
noopCopy <- function(df,name) {
  df
}

runExample(noopCopy)
 #  [1] "data.frame"
 #  [1] "data.frame"
 #    x y
 #  1 1 a
 #  2 2 b
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "factor"
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
 #  Observations: 2
 #  Variables: 2
 #  $ x <dbl> 1, 2
 #  $ y <fctr> a, bNULL
 #    x  y z
 #  1 1  3 a
 #  2 2  5 a
 #  3 3 NA z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    3    3 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z  factor     3   0       2  NA  NA   NA       NA      a      z
 #    x  y z
 #  1 1  3 a
 #  2 2  5 a
 #  3 3 NA z
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
 #    x y
 #  1 a 1
 #  2 a 2
 #  3 b 3
 #  4 b 4
 #  5 c 5
 #  6 c 6
 #  [1] "a" "c"
 #  
 #  d3 %>% replyr::replyr_filter("x",values,verbose=FALSE) 
 #    x y
 #  1 a 1
 #  2 a 2
 #  3 c 5
 #  4 c 6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #    x y match
 #  1 a 1  TRUE
 #  2 a 2  TRUE
 #  3 b 3 FALSE
 #  4 b 4 FALSE
 #  5 c 5  TRUE
 #  6 c 6  TRUE
 #    x
 #  1 1
 #  2 2
 #  3 3
 #  4 3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  # A tibble: 3 × 2
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     2     1
 #  3     3     2
 #  [1] "let example"
 #    Sepal_Length Sepal_Width Species rank
 #  1          5.8         4.0  setosa    0
 #  2          5.7         4.4  setosa    1
 #  [1] "gather/spread examples"
 #    index info meas1 meas2
 #  1     1    a  m1_1  m2_1
 #  2     2    b  m1_2  m2_2
 #  3     3    c  m1_3  m2_3
 #  
 #   dg %>% replyr::replyr_gather(c('meas1','meas2'),'meastype','meas')
 #    index meastype meas
 #  1     1    meas1 m1_1
 #  2     2    meas1 m1_2
 #  3     3    meas1 m1_3
 #  4     1    meas2 m2_1
 #  5     2    meas2 m2_2
 #  6     3    meas2 m2_3
 #  
 #   ds %>% replyr::replyr_spread('index','meastype','meas')
 #  # A tibble: 1 × 3
 #    index meas1 meas2
 #    <dbl> <chr> <chr>
 #  1     1  m1_1  m2_1
```

Local `tbl` example.

``` r
tblCopy <- function(df,name) {
  as.tbl(df)
}

runExample(tblCopy)
 #  [1] "tbl_df"     "tbl"        "data.frame"
 #  [1] "tbl"
 #  # A tibble: 2 × 2
 #        x      y
 #    <dbl> <fctr>
 #  1     1      a
 #  2     2      b
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "factor"
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
 #  Observations: 2
 #  Variables: 2
 #  $ x <dbl> 1, 2
 #  $ y <fctr> a, bNULL
 #  # A tibble: 3 × 3
 #        x     y      z
 #    <dbl> <dbl> <fctr>
 #  1     1     3      a
 #  2     2     5      a
 #  3     3    NA      z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    3    3 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z  factor     3   0       2  NA  NA   NA       NA      a      z
 #  # A tibble: 3 × 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
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
 #  # A tibble: 6 × 2
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
 #  # A tibble: 4 × 2
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  # A tibble: 6 × 3
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  # A tibble: 4 × 1
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  # A tibble: 3 × 2
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     2     1
 #  3     3     2
 #  [1] "let example"
 #  # A tibble: 2 × 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>  <fctr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "gather/spread examples"
 #  # A tibble: 3 × 4
 #    index  info meas1 meas2
 #    <dbl> <chr> <chr> <chr>
 #  1     1     a  m1_1  m2_1
 #  2     2     b  m1_2  m2_2
 #  3     3     c  m1_3  m2_3
 #  
 #   dg %>% replyr::replyr_gather(c('meas1','meas2'),'meastype','meas')
 #  # A tibble: 6 × 3
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
 #  # A tibble: 1 × 3
 #    index meas1 meas2
 #    <dbl> <chr> <chr>
 #  1     1  m1_1  m2_1
```

`SQLite` example.

``` r
my_db <- dplyr::src_sqlite("replyr_sqliteEx.sqlite3", create = TRUE)
class(my_db)
 #  [1] "src_sqlite" "src_sql"    "src"
runExample(remoteCopy(my_db))
 #  [1] "tbl_sqlite" "tbl_sql"    "tbl_lazy"   "tbl"       
 #  [1] "src_sqlite"
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     y match
 #    <chr> <int> <int>
 #  1     a     1     1
 #  2     a     2     1
 #  3     b     3     0
 #  4     b     4     0
 #  5     c     5     1
 #  6     c     6     1
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     2     1
 #  3     3     2
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "gather/spread examples"
 #  Source:   query [?? x 4]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #    index  info meas1 meas2
 #    <dbl> <chr> <chr> <chr>
 #  1     1     a  m1_1  m2_1
 #  2     2     b  m1_2  m2_2
 #  3     3     c  m1_3  m2_3
 #  
 #   dg %>% replyr::replyr_gather(c('meas1','meas2'),'meastype','meas')
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
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
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #    index meas1 meas2
 #    <dbl> <chr> <chr>
 #  1     1  m1_1  m2_1
my_db <- NULL; gc() # disconnect
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 518963 27.8     940480 50.3   940480 50.3
 #  Vcells 763884  5.9    1650153 12.6  1650119 12.6
```

MySQL example.

``` r
my_db <- dplyr::src_mysql('mysql','127.0.0.1',3306,'root','passwd')
class(my_db)
 #  [1] "src_mysql" "src_sql"   "src"
runExample(remoteCopy(my_db))
 #  [1] "tbl_mysql" "tbl_sql"   "tbl_lazy"  "tbl"      
 #  [1] "src_mysql"
 #  Source:   query [?? x 2]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
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
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3     0     z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    3    3 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column     class nrows nna nunique min max     mean       sd lexmin lexmax
 #  1      x   numeric     3   0       3   1   3 2.000000 1.000000   <NA>   <NA>
 #  2      y   numeric     3   0       3   0   5 2.666667 2.516611   <NA>   <NA>
 #  3      z character     3   0       2  NA  NA       NA       NA      a      z
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3     0     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #     1    1    2    3    3 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column     class nrows nna nunique min max     mean       sd lexmin lexmax
 #  1      x   numeric     3   0       3   1   3 2.000000 1.000000   <NA>   <NA>
 #  2      y   numeric     3   0       3   0   5 2.666667 2.516611   <NA>   <NA>
 #  3      z character     3   0       2  NA  NA       NA       NA      a      z
 #  Source:   query [?? x 2]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
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
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
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
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #        x     y match
 #    <chr> <int> <int>
 #  1     a     1     1
 #  2     a     2     1
 #  3     c     5     1
 #  4     c     6     1
 #  5     b     3     0
 #  6     b     4     0
 #  Source:   query [?? x 1]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
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
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     2     1
 #  3     3     2
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "gather/spread examples"
 #  Source:   query [?? x 4]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #    index  info meas1 meas2
 #    <dbl> <chr> <chr> <chr>
 #  1     1     a  m1_1  m2_1
 #  2     2     b  m1_2  m2_2
 #  3     3     c  m1_3  m2_3
 #  
 #   dg %>% replyr::replyr_gather(c('meas1','meas2'),'meastype','meas')
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
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
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #    index meas1 meas2
 #    <dbl> <chr> <chr>
 #  1     1  m1_1  m2_1
my_db <- NULL; gc() # disconnect
 #  Auto-disconnecting mysql connection (0, 0)
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 554087 29.6     940480 50.3   940480 50.3
 #  Vcells 791439  6.1    1650153 12.6  1650153 12.6
```

PostgreSQL example.

``` r
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
 #  [1] "src_postgres" "src_sql"      "src"
runExample(remoteCopy(my_db))
 #  [1] "tbl_postgres" "tbl_sql"      "tbl_lazy"     "tbl"         
 #  [1] "src_postgres"
 #  Source:   query [?? x 2]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     3     2
 #  3     2     1
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "gather/spread examples"
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    index  info meas1 meas2
 #    <dbl> <chr> <chr> <chr>
 #  1     1     a  m1_1  m2_1
 #  2     2     b  m1_2  m2_2
 #  3     3     c  m1_3  m2_3
 #  
 #   dg %>% replyr::replyr_gather(c('meas1','meas2'),'meastype','meas')
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #    index meas1 meas2
 #    <dbl> <chr> <chr>
 #  1     1  m1_1  m2_1
my_db <- NULL; gc() # disconnect
 #  Auto-disconnecting postgres connection (88137, 0)
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 587825 31.4     940480 50.3   940480 50.3
 #  Vcells 817874  6.3    1650153 12.6  1650153 12.6
```

Spark 1.6.2 example.

``` r
# Can't easilly override Spark version once it is up.
my_db <- sparklyr::spark_connect(version='1.6.2', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-1.6.2-bin-hadoop2.6"
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
 #  2     2     1
 #  3     3     2
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
 #    index meas2 meas1
 #    <dbl> <chr> <chr>
 #  1     1  m2_1  m1_1
my_db <- NULL; gc() # disconnect
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 623903 33.4    1168576 62.5  1168576 62.5
 #  Vcells 849851  6.5    1650153 12.6  1650153 12.6
```
