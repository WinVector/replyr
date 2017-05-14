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
packageVersion("dplyr")
 #  [1] '0.5.0'
library('sparklyr')
packageVersion("sparklyr")
 #  [1] '0.5.4'
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
R.Version()$version.string
 #  [1] "R version 3.4.0 (2017-04-21)"
packageVersion("replyr")
 #  [1] '0.3.2'
source('CheckFns.R')
```

Check `replyr` basic opearations against a few data service providers.
----------------------------------------------------------------------

Local `data.frame` example.

``` r
noopCopy <- function(df,name) {
  df
}
resBase <- runExample(noopCopy)
 #  [1] "data.frame"
 #  [1] "character"
 #    x y
 #  1 1 a
 #  2 2 b
 #  [1] "local: TRUE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1 numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2 numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3  factor     3   0      NA  NA  NA   NA       NA      a      z
 #    x  y z
 #  1 1  3 a
 #  2 2  5 a
 #  3 3 NA z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
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
 #  # A tibble: 3 x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #    Sepal_Length Sepal_Width Species rank
 #  1          5.8         4.0  setosa    0
 #  2          5.7         4.4  setosa    1
 #  [1] "coalesce example 1"
 #    year count name
 #  1 2005     6    a
 #  2 2006     0     
 #  3 2007     1    b
 #  4 2008     0     
 #  5 2009     0     
 #  6 2010    NA    c
 #  [1] "coalesce example 2"
 #     year count name
 #  1  2005     6    a
 #  2  2005     0    b
 #  3  2005     0    c
 #  4  2005     0    d
 #  5  2006     0    a
 #  6  2006     0    b
 #  7  2006     0    c
 #  8  2006     0    d
 #  9  2007     0    a
 #  10 2007     1    b
 #  11 2007     0    c
 #  12 2007     0    d
 #  13 2008     0    a
 #  14 2008     0    b
 #  15 2008     0    c
 #  16 2008     0    d
 #  17 2009     0    a
 #  18 2009     0    b
 #  19 2009     0    c
 #  20 2009     0    d
 #  21 2010     0    a
 #  22 2010     0    b
 #  23 2010    NA    c
 #  24 2010     0    d
 #  [1] "split re-join"
 #  [1] "gapply"
 #  [1] "replyr_moveValuesToColumns"
 #  [1] "replyr_moveValuesToRows"
```

Local `tbl` example.

``` r
tblCopy <- function(df,name) {
  as.tbl(df)
}
resTbl <- runExample(tblCopy)
 #  [1] "tbl_df"     "tbl"        "data.frame"
 #  [1] "character"
 #  # A tibble: 2 x 2
 #        x      y
 #    <dbl> <fctr>
 #  1     1      a
 #  2     2      b
 #  [1] "local: TRUE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
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
 #  # A tibble: 3 x 3
 #        x     y      z
 #    <dbl> <dbl> <fctr>
 #  1     1     3      a
 #  2     2     5      a
 #  3     3    NA      z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1 numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2 numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3  factor     3   0      NA  NA  NA   NA       NA      a      z
 #  # A tibble: 3 x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # A tibble: 6 x 2
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
 #  # A tibble: 4 x 2
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  # A tibble: 6 x 3
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  # A tibble: 4 x 1
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  # A tibble: 3 x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #  # A tibble: 2 x 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>  <fctr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  # A tibble: 6 x 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010    NA     c
 #  [1] "coalesce example 2"
 #  # A tibble: 24 x 3
 #      year count  name
 #     <dbl> <dbl> <chr>
 #   1  2005     6     a
 #   2  2005     0     b
 #   3  2005     0     c
 #   4  2005     0     d
 #   5  2006     0     a
 #   6  2006     0     b
 #   7  2006     0     c
 #   8  2006     0     d
 #   9  2007     0     a
 #  10  2007     1     b
 #  # ... with 14 more rows
 #  [1] "split re-join"
 #  [1] "gapply"
 #  [1] "replyr_moveValuesToColumns"
 #  [1] "replyr_moveValuesToRows"
if(!listsOfSameData(resBase, resTbl)) {
  stop("tbl result differs")
}
```

`SQLite` example.

``` r
my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
class(my_db)
 #  [1] "src_sqlite" "src_sql"    "src"
copyToRemote <- remoteCopy(my_db)
resSQLite <- runExample(copyToRemote)
 #  [1] "tbl_sqlite" "tbl_sql"    "tbl_lazy"   "tbl"       
 #  [1] "src_sqlite" "src_sql"    "src"       
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 2
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     2     b
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
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
 #  $ src <S3: src_sqlite> 1, 2
 #  $ ops <S3: op_base_remote> "a", "b"NULL
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 2
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
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 2
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 3
 #        x     y match
 #    <chr> <int> <int>
 #  1     a     1     1
 #  2     a     2     1
 #  3     b     3     0
 #  4     b     4     0
 #  5     c     5     1
 #  6     c     6     1
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 1
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010    NA     c
 #  [1] "coalesce example 2"
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #  # A tibble: ?? x 3
 #      year count  name
 #     <dbl> <dbl> <chr>
 #   1  2005     6     a
 #   2  2005     0     b
 #   3  2005     0     c
 #   4  2005     0     d
 #   5  2006     0     a
 #   6  2006     0     b
 #   7  2006     0     c
 #   8  2006     0     d
 #   9  2007     0     a
 #  10  2007     1     b
 #  # ... with more rows
 #  [1] "split re-join"
 #  [1] "gapply"
 #  [1] "replyr_moveValuesToColumns"
 #  [1] "replyr_moveValuesToRows"
if(!listsOfSameData(resBase, resSQLite)) {
  stop("SQLite result differs")
}
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  706080 37.8    1168576 62.5  1168576 62.5
 #  Vcells 1350552 10.4    2552219 19.5  2552130 19.5
```

MySQL example ("docker start mysql"). Kind of poor as at least the adapted MySql has a hard time with `NA`.

``` r
my_db <- dplyr::src_mysql('mysql','127.0.0.1',3306,'root','passwd')
class(my_db)
 #  [1] "src_mysql" "src_sql"   "src"
copyToRemote <- remoteCopy(my_db)

resMySQL <- runExample(copyToRemote)
 #  [1] "tbl_mysql" "tbl_sql"   "tbl_lazy"  "tbl"      
 #  [1] "src_mysql" "src_sql"   "src"      
 #  Source:   query [?? x 2]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 2
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     2     b
 #  [1] "local: FALSE"
 #  [1] "MySQL: TRUE"
 #  [1] "Spark: FALSE"
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
 #  $ src <S3: src_mysql> 1, 2
 #  $ ops <S3: op_base_remote> "a", "b"NULL
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3     0     z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max     mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3 2.000000 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   0      NA   0   5 2.666667 2.516611   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA       NA       NA      a      z
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3     0     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max     mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3 2.000000 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   0      NA   0   5 2.666667 2.516611   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA       NA       NA      a      z
 #  Source:   query [?? x 2]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 2
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
 #  # A tibble: ?? x 2
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
 #  # A tibble: ?? x 3
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
 #  # A tibble: ?? x 1
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
 #  # A tibble: ?? x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010     0     c
 #  [1] "coalesce example 2"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #  # A tibble: ?? x 3
 #      year count  name
 #     <dbl> <dbl> <chr>
 #   1  2005     6     a
 #   2  2005     0     b
 #   3  2005     0     c
 #   4  2005     0     d
 #   5  2006     0     a
 #   6  2006     0     b
 #   7  2006     0     c
 #   8  2006     0     d
 #   9  2007     0     a
 #  10  2007     1     b
 #  # ... with more rows
 #  [1] "split re-join"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  [1] "gapply"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  [1] "replyr_moveValuesToColumns"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  [1] "replyr_moveValuesToRows"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

failures <- failingFrameIndices(resBase, resMySQL) 
retrykeys <- list()
retrykeys[[2]] <- c('x', 'z')
retrykeys[[3]] <- c('x', 'z')
retrykeys[[7]] <- c('year', 'name')
retrykeys[[8]] <- c('year', 'name')
retrykeys[[9]] <- c('year')
retrykeys[[10]] <- c('group')
retrykeys[[11]] <- c('index')
retrykeys[[12]] <- c('index','meastype')
for(i in failures) {
  if(i<=length(retrykeys)) {
    explained <- sameData(resBase[[i]], resMySQL[[i]],
                          ingoreLeftNAs= TRUE, keySet=retrykeys[[i]])
    print(paste("MySQL result differs",i,
                " explained by left NAs: ",
                explained))
    if(!explained) {
      stop("MySQL non NA differnce")
    }
  } else {
    stop(paste("different result for example", i))
  }
}
 #  [1] "MySQL result differs 8  explained by left NAs:  TRUE"
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #  Auto-disconnecting mysql connection (0, 0)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  745253 39.9    1168576 62.5  1168576 62.5
 #  Vcells 1395546 10.7    2552219 19.5  2552219 19.5
```

PostgreSQL example ("docker start pg"). Commented out for now as we are having trouble re-installing `RPostgreSQL`.

``` r
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
 #  [1] "src_postgres" "src_sql"      "src"
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
 #  [1] "tbl_postgres" "tbl_sql"      "tbl_lazy"     "tbl"         
 #  [1] "src_postgres" "src_sql"      "src"         
 #  Source:   query [?? x 2]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 2
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     2     b
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
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
 #  $ src <S3: src_postgres> 1, 2
 #  $ ops <S3: op_base_remote> "a", "b"NULL
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 3
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 2]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 2
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
 #  # A tibble: ?? x 2
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
 #  # A tibble: ?? x 3
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
 #  # A tibble: ?? x 1
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
 #  # A tibble: ?? x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     3                      2
 #  3     2                      1
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010    NA     c
 #  [1] "coalesce example 2"
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #  # A tibble: ?? x 3
 #      year count  name
 #     <dbl> <dbl> <chr>
 #   1  2005     6     a
 #   2  2005     0     b
 #   3  2005     0     c
 #   4  2005     0     d
 #   5  2006     0     a
 #   6  2006     0     b
 #   7  2006     0     c
 #   8  2006     0     d
 #   9  2007     0     a
 #  10  2007     1     b
 #  # ... with more rows
 #  [1] "split re-join"
 #  [1] "gapply"
 #  [1] "replyr_moveValuesToColumns"
 #  [1] "replyr_moveValuesToRows"
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("PostgreSQL result differs")
}
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #  Auto-disconnecting postgres connection (55878, 0)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  780852 41.8    1442291 77.1  1442291 77.1
 #  Vcells 1433779 11.0    3142662 24.0  3131419 23.9
```

Another PostgreSQL example `devtools::install_github('rstats-db/RPostgres')`. Doesn't seem to be wired up to `dplyr 0.5.0` but likely will talk to `dbdplyr`.

``` r
my_db <- DBI::dbConnect(RPostgres::Postgres(),
  host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("RPostgres result differs")
}
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
```

Spark 2. example (lowest version of Spark we are supporting).

``` r
# Can't easilly override Spark version once it is up.
my_db <- sparklyr::spark_connect(version='2.0.2', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.2-bin-hadoop2.7"
copyToRemote <- remoteCopy(my_db)
resSpark <- runExample(copyToRemote)
 #  [1] "tbl_spark" "tbl_sql"   "tbl_lazy"  "tbl"      
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"         
 #  Source:   query [2 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 2 x 2
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     2     b
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: TRUE"
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
 #  Observations: 2
 #  Variables: 2
 #  $ src <S3: src_spark> 1, 2
 #  $ ops <S3: op_base_remote> "a", "b"NULL
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 3 x 3
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
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 3 x 3
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
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  Source:   query [6 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 6 x 2
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
 #  Source:   query [4 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 4 x 2
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  Source:   query [6 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 6 x 3
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  Source:   query [4 x 1]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 4 x 1
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  Source:   query [3 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 3 x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     3                      2
 #  3     2                      1
 #  [1] "let example"
 #  Source:   query [2 x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 2 x 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  Source:   query [6 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 6 x 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010   NaN     c
 #  [1] "coalesce example 2"
 #  Source:   query [24 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 24 x 3
 #      year count  name
 #     <dbl> <dbl> <chr>
 #   1  2005     6     a
 #   2  2005     0     b
 #   3  2005     0     c
 #   4  2005     0     d
 #   5  2006     0     a
 #   6  2006     0     b
 #   7  2006     0     c
 #   8  2006     0     d
 #   9  2007     0     a
 #  10  2007     1     b
 #  # ... with 14 more rows
 #  [1] "split re-join"
 #  [1] "gapply"
 #  [1] "replyr_moveValuesToColumns"
 #  [1] "replyr_moveValuesToRows"
if(!listsOfSameData(resBase, resSpark)) {
  stop("Spark result differs")
}
spark_disconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  825977 44.2    1442291 77.1  1442291 77.1
 #  Vcells 1498528 11.5    3142662 24.0  3131419 23.9
```

``` r
print("all done")
 #  [1] "all done"
rm(list=ls())
gc(verbose = FALSE)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  824946 44.1    1442291 77.1  1442291 77.1
 #  Vcells 1495222 11.5    3142662 24.0  3131419 23.9
```
