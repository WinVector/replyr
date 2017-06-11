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
 #  [1] '0.7.0'
library('sparklyr')
 #  
 #  Attaching package: 'sparklyr'
 #  The following object is masked from 'package:dplyr':
 #  
 #      top_n
packageVersion("sparklyr")
 #  [1] '0.5.6'
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
 #  [1] '1.0.0'
R.Version()$version.string
 #  [1] "R version 3.4.0 (2017-04-21)"
packageVersion("replyr")
 #  [1] '0.3.902'
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
 #        p w  x  y z
 #  1  TRUE 1 NA  3 a
 #  2 FALSE 2  2  5 b
 #  3    NA 3  3 hi z
 #  [1] "local: TRUE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   logical     3   1      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer     3   0      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric     3   1      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4    factor     3   0      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character     3   0      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $p
 #  [1] "logical"
 #  
 #  $w
 #  [1] "integer"
 #  
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "factor"
 #  
 #  $z
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 3 5
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 3
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
 #    year count name
 #  1 2005     6    a
 #  2 2007     1    b
 #  3 2010    NA    c
 #  [1] "gapply"
 #    cv group
 #  1 20     1
 #  2  8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # A tibble: 3 x 3
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #    index info meastype meas
 #  1     1    a    meas1 m1_1
 #  2     1    a    meas2 m2_1
 #  3     2    b    meas1 m1_2
 #  4     2    b    meas2 m2_2
 #  5     3    c    meas1 m1_3
 #  6     3    c    meas2 m2_3
```

Local `tbl` example.

``` r
tblCopy <- function(df,name) {
  as.tbl(df)
}
resTbl <- runExample(tblCopy)
 #  [1] "tbl_df"     "tbl"        "data.frame"
 #  [1] "character"
 #  # A tibble: 3 x 5
 #        p     w     x      y     z
 #    <lgl> <int> <dbl> <fctr> <chr>
 #  1  TRUE     1    NA      3     a
 #  2 FALSE     2     2      5     b
 #  3    NA     3     3     hi     z
 #  [1] "local: TRUE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   logical     3   1      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer     3   0      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric     3   1      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4    factor     3   0      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character     3   0      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $p
 #  [1] "logical"
 #  
 #  $w
 #  [1] "integer"
 #  
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "factor"
 #  
 #  $z
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 3 5
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 3
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
 #  # A tibble: 3 x 3
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  # A tibble: 2 x 2
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # A tibble: 3 x 3
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # A tibble: 6 x 4
 #    index  info meastype  meas
 #    <dbl> <chr>    <chr> <chr>
 #  1     1     a    meas1  m1_1
 #  2     1     a    meas2  m2_1
 #  3     2     b    meas1  m1_2
 #  4     2     b    meas2  m2_2
 #  5     3     c    meas1  m1_3
 #  6     3     c    meas2  m2_3
if(!listsOfSameData(resBase, resTbl)) {
  stop("tbl result differs")
}
```

`SQLite` example.

``` r
my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
class(my_db)
 #  [1] "src_dbi" "src_sql" "src"
copyToRemote <- remoteCopy(my_db)
resSQLite <- runExample(copyToRemote)
 #  [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"     
 #  [1] "src_dbi" "src_sql" "src"    
 #  # Source:   table<d1> [?? x 5]
 #  # Database: sqlite 3.11.1 [:memory:]
 #        p     w     x     y     z
 #    <int> <int> <dbl> <chr> <chr>
 #  1     1     1    NA     3     a
 #  2     0     2     2     5     b
 #  3    NA     3     3    hi     z
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   integer    NA  NA      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer    NA  NA      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric    NA  NA      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character    NA  NA      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character    NA  NA      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $p
 #  [1] "integer"
 #  
 #  $w
 #  [1] "integer"
 #  
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "character"
 #  
 #  $z
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      p     w     x     y     z 
 #   TRUE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 3 5
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: sqlite 3.11.1 [:memory:]
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: sqlite 3.11.1 [:memory:]
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d3> [?? x 2]
 #  # Database: sqlite 3.11.1 [:memory:]
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
 #  # Source:   table<replyr_filter_aQ8P98B2bSushC5m6ZyS_0000000001> [?? x 2]
 #  # Database: sqlite 3.11.1 [:memory:]
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: sqlite 3.11.1 [:memory:]
 #        x     y match
 #    <chr> <int> <int>
 #  1     a     1     1
 #  2     a     2     1
 #  3     b     3     0
 #  4     b     4     0
 #  5     c     5     1
 #  6     c     6     1
 #  # Source:   table<d4> [?? x 1]
 #  # Database: sqlite 3.11.1 [:memory:]
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  # Source:   lazy query [?? x 2]
 #  # Database: sqlite 3.11.1 [:memory:]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: sqlite 3.11.1 [:memory:]
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  # Source:     table<replyr_coalesce_3d5pV0BhHm328AGng66i_0000000009> [?? x 3]
 #  # Database:   sqlite 3.11.1 [:memory:]
 #  # Ordered by: year, name
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010    NA     c
 #  [1] "coalesce example 2"
 #  # Source:     table<replyr_coalesce_tn6ye9Tvsts0KIS8YQNv_0000000007> [?? x 3]
 #  # Database:   sqlite 3.11.1 [:memory:]
 #  # Ordered by: year, name
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
 #  # Source:     table<replyr_bind_rows_k0UrDKR5xPdkxoLNQANp_0000000010> [?? x 3]
 #  # Database:   sqlite 3.11.1 [:memory:]
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  # Source:     table<replyr_gapply_LC78GF53epCCNrHmfEvE_0000000009> [?? x 2]
 #  # Database:   sqlite 3.11.1 [:memory:]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # Source:     table<replyr_moveValuesToColumns_sRlPXwTXrOnkyzIGUFWe_0000000003> [?? x 3]
 #  # Database:   sqlite 3.11.1 [:memory:]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # Source:     table<replyr_moveValuesToRows_xDssWP2k6bK8Aq2yeyUW_0000000007> [?? x 4]
 #  # Database:   sqlite 3.11.1 [:memory:]
 #  # Ordered by: index, meastype
 #    index  info meastype  meas
 #    <dbl> <chr>    <chr> <chr>
 #  1     1     a    meas1  m1_1
 #  2     1     a    meas2  m2_1
 #  3     2     b    meas1  m1_2
 #  4     2     b    meas2  m2_2
 #  5     3     c    meas1  m1_3
 #  6     3     c    meas2  m2_3
failingFrameIndices(resBase, resSQLite)
 #  integer(0)
if(!listsOfSameData(resBase, resSQLite)) {
  stop("SQLite result differs")
}
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  760215 40.6    1442291 77.1  1442291 77.1
 #  Vcells 1451453 11.1    2552219 19.5  1917828 14.7
```

MySQL example ("docker start mysql"). Kind of poor as at least the adapted MySql has a hard time with `NA`.

``` r
my_db <- dplyr::src_mysql('mysql','127.0.0.1',3306,'root','')
class(my_db)
 #  [1] "src_dbi" "src_sql" "src"
copyToRemote <- remoteCopy(my_db)

resMySQL <- runExample(copyToRemote)
 #  [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"     
 #  [1] "src_dbi" "src_sql" "src"    
 #  # Source:   table<d1> [?? x 5]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
 #        p     w     x     y     z
 #    <int> <int> <dbl> <chr> <chr>
 #  1     0     1    NA     3     a
 #  2     0     2     2     5     b
 #  3    NA     3     3    hi     z
 #  [1] "local: FALSE"
 #  [1] "MySQL: TRUE"
 #  [1] "Spark: FALSE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   integer    NA  NA      NA   0   0  0.0 0.0000000   <NA>   <NA>
 #  2      w     2   integer    NA  NA      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric    NA  NA      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character    NA  NA      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character    NA  NA      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $p
 #  [1] "integer"
 #  
 #  $w
 #  [1] "integer"
 #  
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "character"
 #  
 #  $z
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      p     w     x     y     z 
 #   TRUE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 3 5
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d3> [?? x 2]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
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
 #  # Source:   table<replyr_filter_RMuWoqlLCr1gFilE0YWO_0000000001> [?? x 2]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
 #        x     y match
 #    <chr> <int> <dbl>
 #  1     a     1     1
 #  2     a     2     1
 #  3     c     5     1
 #  4     c     6     1
 #  5     b     3     0
 #  6     b     4     0
 #  # Source:   table<d4> [?? x 1]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x")
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  # Source:   lazy query [?? x 2]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: mysql 5.7.18 [root@127.0.0.1:/mysql]
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
 #  # Source:     table<replyr_coalesce_azS2KhJBonoTF6JikKxo_0000000009> [?? x 3]
 #  # Database:   mysql 5.7.18 [root@127.0.0.1:/mysql]
 #  # Ordered by: year, name
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010    NA     c
 #  [1] "coalesce example 2"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 2 imported as numeric
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  # Source:     table<replyr_coalesce_fc0MmwLvCQQ5HoJTcyCV_0000000007> [?? x 3]
 #  # Database:   mysql 5.7.18 [root@127.0.0.1:/mysql]
 #  # Ordered by: year, name
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
 #  # Source:     table<replyr_bind_rows_reTmfnnYTVsdEcgR2zb1_0000000010> [?? x 3]
 #  # Database:   mysql 5.7.18 [root@127.0.0.1:/mysql]
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric

 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  # Source:     table<replyr_gapply_VA2dX0tGfp1hVVjhv8dL_0000000009> [?? x 2]
 #  # Database:   mysql 5.7.18 [root@127.0.0.1:/mysql]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #  # Source:     table<replyr_moveValuesToColumns_Ajewe7kOx6IISema1Jf3_0000000003> [?? x 3]
 #  # Database:   mysql 5.7.18 [root@127.0.0.1:/mysql]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # Source:     table<replyr_moveValuesToRows_MIpOSE7YmMZEfuFDoVSI_0000000007> [?? x 4]
 #  # Database:   mysql 5.7.18 [root@127.0.0.1:/mysql]
 #  # Ordered by: index, meastype
 #    index  info meastype  meas
 #    <dbl> <chr>    <chr> <chr>
 #  1     1     a    meas1  m1_1
 #  2     1     a    meas2  m2_1
 #  3     2     b    meas1  m1_2
 #  4     2     b    meas2  m2_2
 #  5     3     c    meas1  m1_3
 #  6     3     c    meas2  m2_3
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
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #  Auto-disconnecting MySQLConnection
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  799246 42.7    1442291 77.1  1442291 77.1
 #  Vcells 1496318 11.5    2552219 19.5  1983048 15.2
```

PostgreSQL example ("docker start pg").

``` r
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
 #  [1] "src_dbi" "src_sql" "src"
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
 #  [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"     
 #  [1] "src_dbi" "src_sql" "src"    
 #  # Source:   table<d1> [?? x 5]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        p     w     x     y     z
 #    <lgl> <int> <dbl> <chr> <chr>
 #  1  TRUE     1    NA     3     a
 #  2 FALSE     2     2     5     b
 #  3    NA     3     3    hi     z
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   logical    NA  NA      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer    NA  NA      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric    NA  NA      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character    NA  NA      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character    NA  NA      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $p
 #  [1] "logical"
 #  
 #  $w
 #  [1] "integer"
 #  
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "character"
 #  
 #  $z
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 3 5
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d3> [?? x 2]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
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
 #  # Source:   table<replyr_filter_w1TcgDFEZQXUOhG4Gjtg_0000000001> [?? x 2]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  # Source:   table<d4> [?? x 1]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  # Source:   lazy query [?? x 2]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     3                      2
 #  3     2                      1
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  # Source:     table<replyr_coalesce_FSrsJi4E8Bom39Djs3rb_0000000009> [?? x 3]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: year, name
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010    NA     c
 #  [1] "coalesce example 2"
 #  # Source:     table<replyr_coalesce_wF5nPSOUObJzwOVBxuHZ_0000000007> [?? x 3]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: year, name
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
 #  # Source:     table<replyr_bind_rows_drRJRSX9RItvdg27TJLK_0000000010> [?? x 3]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  # Source:     table<replyr_gapply_qqk3l0YtWGmiMcnUtP18_0000000009> [?? x 2]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # Source:     table<replyr_moveValuesToColumns_qhG0jrxXOyVQoojgocKW_0000000003> [?? x 3]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # Source:     table<replyr_moveValuesToRows_twPbTmTrTgVODg6eQ2Mq_0000000007> [?? x 4]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: index, meastype
 #    index  info meastype  meas
 #    <dbl> <chr>    <chr> <chr>
 #  1     1     a    meas1  m1_1
 #  2     1     a    meas2  m2_1
 #  3     2     b    meas1  m1_2
 #  4     2     b    meas2  m2_2
 #  5     3     c    meas1  m1_3
 #  6     3     c    meas2  m2_3
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("PostgreSQL result differs")
}
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #  Auto-disconnecting PostgreSQLConnection
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  834934 44.6    1442291 77.1  1442291 77.1
 #  Vcells 1535255 11.8    2552219 19.5  2024950 15.5
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
 #  # Source:   table<d1> [?? x 5]
 #  # Database: spark_connection
 #        p     w     x     y     z
 #    <lgl> <int> <dbl> <chr> <chr>
 #  1  TRUE     1   NaN     3     a
 #  2 FALSE     2     2     5     b
 #  3 FALSE     3     3    hi     z
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: TRUE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   logical     3   1      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer     3   0      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric     3   1      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character     3   0      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character     3   0      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $p
 #  [1] "logical"
 #  
 #  $w
 #  [1] "integer"
 #  
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "character"
 #  
 #  $z
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 3 5
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: spark_connection
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
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: spark_connection
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
 #  # Source:   table<d3> [?? x 2]
 #  # Database: spark_connection
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
 #  # Source:   table<replyr_filter_cA8oCNz9d4DCWzvKYtRd_0000000001> [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: spark_connection
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  # Source:   table<d4> [?? x 1]
 #  # Database: spark_connection
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  # Source:   lazy query [?? x 2]
 #  # Database: spark_connection
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     3                      2
 #  3     2                      1
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: spark_connection
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  # Source:     table<replyr_coalesce_0T3ayEZ21yLIi3wfKesm_0000000009> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year, name
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2006     0      
 #  3  2007     1     b
 #  4  2008     0      
 #  5  2009     0      
 #  6  2010   NaN     c
 #  [1] "coalesce example 2"
 #  # Source:     table<replyr_coalesce_Oa14QHgcgc36si7W5cAC_0000000007> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year, name
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
 #  # Source:     table<replyr_bind_rows_BvvO8w8gDvlX0EdCAYUG_0000000010> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010   NaN     c
 #  [1] "gapply"
 #  # Source:     table<replyr_gapply_btWAk6c6wMbkiHuKG9b8_0000000009> [?? x 2]
 #  # Database:   spark_connection
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # Source:     table<replyr_moveValuesToColumns_l4YyNK6SchY1z2U2zku0_0000000003> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # Source:     table<replyr_moveValuesToRows_XMm42YaZluiD9oTlAvaC_0000000007> [?? x 4]
 #  # Database:   spark_connection
 #  # Ordered by: index, meastype
 #    index  info meastype  meas
 #    <dbl> <chr>    <chr> <chr>
 #  1     1     a    meas1  m1_1
 #  2     1     a    meas2  m2_1
 #  3     2     b    meas1  m1_2
 #  4     2     b    meas2  m2_2
 #  5     3     c    meas1  m1_3
 #  6     3     c    meas2  m2_3
if(!listsOfSameData(resBase, resSpark)) {
  stop("Spark result differs")
}
spark_disconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  879599 47.0    1442291 77.1  1442291 77.1
 #  Vcells 1598986 12.2    2552219 19.5  2024950 15.5
```

``` r
print("all done")
 #  [1] "all done"
rm(list=ls())
gc(verbose = FALSE)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  878477 47.0    1442291 77.1  1442291 77.1
 #  Vcells 1595006 12.2    2552219 19.5  2024950 15.5
```
