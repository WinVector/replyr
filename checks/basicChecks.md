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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1 numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2 numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3  factor     3   0       2  NA  NA   NA       NA      a      z
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
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
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
 #  [1] "coalesce example 1"
 #    year count name
 #  1 2005     6    a
 #  2 2007     1    b
 #  3 2010    NA    c
 #  4 2009     0     
 #  5 2008     0     
 #  6 2006     0     
 #  [1] "coalesce example 2"
 #     year count name
 #  1  2005     6    a
 #  2  2007     1    b
 #  3  2010    NA    c
 #  4  2010     0    d
 #  5  2009     0    d
 #  6  2008     0    d
 #  7  2007     0    d
 #  8  2006     0    d
 #  9  2005     0    d
 #  10 2009     0    c
 #  11 2008     0    c
 #  12 2007     0    c
 #  13 2006     0    c
 #  14 2005     0    c
 #  15 2010     0    b
 #  16 2009     0    b
 #  17 2008     0    b
 #  18 2006     0    b
 #  19 2005     0    b
 #  20 2010     0    a
 #  21 2009     0    a
 #  22 2008     0    a
 #  23 2007     0    a
 #  24 2006     0    a
 #  NULL
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1 numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2 numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3  factor     3   0       2  NA  NA   NA       NA      a      z
 #  # A tibble: 3 × 3
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
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
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
 #  [1] "coalesce example 1"
 #  # A tibble: 6 × 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  4  2009     0      
 #  5  2008     0      
 #  6  2006     0      
 #  [1] "coalesce example 2"
 #  # A tibble: 24 × 3
 #      year count  name
 #     <dbl> <dbl> <chr>
 #  1   2005     6     a
 #  2   2007     1     b
 #  3   2010    NA     c
 #  4   2010     0     d
 #  5   2009     0     d
 #  6   2008     0     d
 #  7   2007     0     d
 #  8   2006     0     d
 #  9   2005     0     d
 #  10  2009     0     c
 #  # ... with 14 more rows
 #  NULL
```

`SQLite` example.

``` r
my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
class(my_db)
 #  [1] "src_sqlite" "src_sql"    "src"
copyToRemote <- remoteCopy(my_db)
runExample(copyToRemote)
 #  [1] "tbl_sqlite" "tbl_sql"    "tbl_lazy"   "tbl"       
 #  [1] "src_sqlite"
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.11.1 [:memory:]
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
 #  Database: sqlite 3.11.1 [:memory:]
 #  
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
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
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
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.11.1 [:memory:]
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
 #  Database: sqlite 3.11.1 [:memory:]
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
 #  Database: sqlite 3.11.1 [:memory:]
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
 #  Database: sqlite 3.11.1 [:memory:]
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
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     2     1
 #  3     3     2
 #  [1] "let example"
 #  Source:   query [?? x 4]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  4  2006     0      
 #  5  2008     0      
 #  6  2009     0      
 #  [1] "coalesce example 2"
 #  Source:   query [?? x 3]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #      year count  name
 #     <dbl> <dbl> <chr>
 #  1   2005     6     a
 #  2   2007     1     b
 #  3   2010    NA     c
 #  4   2006     0     a
 #  5   2007     0     a
 #  6   2008     0     a
 #  7   2009     0     a
 #  8   2010     0     a
 #  9   2005     0     b
 #  10  2006     0     b
 #  # ... with more rows
 #  NULL
my_db <- NULL; gc() # disconnect
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 533879 28.6     940480 50.3   940480 50.3
 #  Vcells 787313  6.1    2060183 15.8  2060183 15.8
```

MySQL example ("docker start mysql").

``` r
my_db <- dplyr::src_mysql('mysql','127.0.0.1',3306,'root','passwd')
class(my_db)
 #  [1] "src_mysql" "src_sql"   "src"
copyToRemote <- remoteCopy(my_db)
runExample(copyToRemote)
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max     mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3 2.000000 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   0       3   0   5 2.666667 2.516611   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA       NA       NA      a      z
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max     mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3 2.000000 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   0       3   0   5 2.666667 2.516611   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA       NA       NA      a      z
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
 #  [1] "coalesce example 1"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010     0     c
 #  4  2006     0      
 #  5  2008     0      
 #  6  2009     0      
 #  [1] "coalesce example 2"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric
 #  Source:   query [?? x 3]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  
 #      year count  name
 #     <dbl> <dbl> <chr>
 #  1   2005     6     a
 #  2   2007     1     b
 #  3   2010     0     c
 #  4   2006     0     a
 #  5   2007     0     a
 #  6   2008     0     a
 #  7   2009     0     a
 #  8   2010     0     a
 #  9   2005     0     b
 #  10  2006     0     b
 #  # ... with more rows
 #  NULL
my_db <- NULL; gc() # disconnect
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 569034 30.4     940480 50.3   940480 50.3
 #  Vcells 814544  6.3    2060183 15.8  2060183 15.8
```

PostgreSQL example ("docker start pg").

``` r
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
 #  [1] "src_postgres" "src_sql"      "src"
copyToRemote <- remoteCopy(my_db)
runExample(copyToRemote)
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
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
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
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
 #  [1] "coalesce example 1"
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  4  2006     0      
 #  5  2008     0      
 #  6  2009     0      
 #  [1] "coalesce example 2"
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #      year count  name
 #     <dbl> <dbl> <chr>
 #  1   2005     6     a
 #  2   2007     1     b
 #  3   2010    NA     c
 #  4   2006     0     a
 #  5   2007     0     a
 #  6   2008     0     a
 #  7   2009     0     a
 #  8   2010     0     a
 #  9   2005     0     b
 #  10  2006     0     b
 #  # ... with more rows
 #  NULL
my_db <- NULL; gc() # disconnect
 #  Auto-disconnecting mysql connection (0, 0)
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 602825 32.2    1168576 62.5   940480 50.3
 #  Vcells 840905  6.5    2060183 15.8  2060183 15.8
```

Spark 2.0.0. example (lowest version of Spark we are supporting).

``` r
# Can't easilly override Spark version once it is up.
my_db <- sparklyr::spark_connect(version='2.0.0', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
copyToRemote <- remoteCopy(my_db)
runExample(copyToRemote)
 #  [1] "tbl_spark" "tbl_sql"   "tbl_lazy"  "tbl"      
 #  [1] "src_spark"
 #  Source:   query [2 x 2]
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
 #  Observations: 2
 #  Variables: 2
 #  $ x <dbl> 1, 2
 #  $ y <chr> "a", "b"NULL
 #  Source:   query [3 x 3]
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
 #  Source:   query [3 x 3]
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
 #  Source:   query [6 x 2]
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
 #  Source:   query [4 x 2]
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
 #  Source:   query [6 x 3]
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
 #  Source:   query [4 x 1]
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
 #  Source:   query [3 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     3     2
 #  3     2     1
 #  [1] "let example"
 #  Source:   query [2 x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  Source:   query [6 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2007     1     b
 #  2  2005     6     a
 #  3  2008     0      
 #  4  2010   NaN     c
 #  5  2006     0      
 #  6  2009     0      
 #  [1] "coalesce example 2"
 #  Source:   query [24 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #      year count  name
 #     <dbl> <dbl> <chr>
 #  1   2007     1     b
 #  2   2005     0     b
 #  3   2005     0     c
 #  4   2007     0     c
 #  5   2006     0     d
 #  6   2007     0     d
 #  7   2008     0     d
 #  8   2005     6     a
 #  9   2006     0     a
 #  10  2007     0     a
 #  # ... with 14 more rows
 #  NULL
my_db <- NULL; gc() # disconnect
 #  Auto-disconnecting postgres connection (74688, 0)
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 639757 34.2    1168576 62.5  1168576 62.5
 #  Vcells 875310  6.7    2060183 15.8  2060183 15.8
```
