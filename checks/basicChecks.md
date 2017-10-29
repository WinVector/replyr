Example trying most of the `replyr` functions on a few data sources.

``` r
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
 #  [1] '0.7.4'
# possibly need this https://github.com/tidyverse/dplyr/issues/3145
suppressPackageStartupMessages(library('dbplyr'))
packageVersion("dbplyr")
 #  [1] '1.1.0'
suppressPackageStartupMessages(library('sparklyr'))
packageVersion("sparklyr")
 #  [1] '0.6.3'
R.Version()$version.string
 #  [1] "R version 3.4.2 (2017-09-28)"
library("replyr")
 #  Loading required package: seplyr
 #  Loading required package: wrapr
 #  Loading required package: cdata
packageVersion("replyr")
 #  [1] '0.8.2'
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
 #  d1 %.>% replyr::replyr_colClasses(.) 
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
 #  d1 %.>% replyr::replyr_testCols(., is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %.>% replyr::replyr_dim(.) 
 #  [1] 3 5
 #  
 #  d1 %.>% replyr::replyr_nrow(.) 
 #  [1] 3
 #    x  y z
 #  1 1  3 a
 #  2 2  5 a
 #  3 3 NA z
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
 #    column index   class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1 numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2 numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3  factor     3   0      NA  NA  NA   NA       NA      a      z
 #    x  y z
 #  1 1  3 a
 #  2 2  5 a
 #  3 3 NA z
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
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
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #    x y
 #  1 a 1
 #  2 a 2
 #  3 c 5
 #  4 c 6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
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
 #  d4 %.>% replyr::replyr_uniqueValues(., "x") 
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
 #  [1] "moveValuesToColumnsQ"
 #    index meastype_meas1 meastype_meas2
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
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
 #  d1 %.>% replyr::replyr_colClasses(.) 
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
 #  d1 %.>% replyr::replyr_testCols(., is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %.>% replyr::replyr_dim(.) 
 #  [1] 3 5
 #  
 #  d1 %.>% replyr::replyr_nrow(.) 
 #  [1] 3
 #  # A tibble: 3 x 3
 #        x     y      z
 #    <dbl> <dbl> <fctr>
 #  1     1     3      a
 #  2     2     5      a
 #  3     3    NA      z
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
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
 #  d2b %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
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
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # A tibble: 4 x 2
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
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
 #  d4 %.>% replyr::replyr_uniqueValues(., "x") 
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
 #  [1] "moveValuesToColumnsQ"
 #  # A tibble: 3 x 3
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
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
my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
RSQLite::initExtension(my_db) # filed as dplyr issue https://github.com/tidyverse/dplyr/issues/3150
# my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
class(my_db)
 #  [1] "SQLiteConnection"
 #  attr(,"package")
 #  [1] "RSQLite"
copyToRemote <- remoteCopy(my_db)
resSQLite <- runExample(copyToRemote)
 #  [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"     
 #  [1] "src_dbi" "src_sql" "src"    
 #  # Source:   table<d1> [?? x 5]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        p     w     x     y     z
 #    <int> <int> <dbl> <chr> <chr>
 #  1     1     1    NA     3     a
 #  2     0     2     2     5     b
 #  3    NA     3     3    hi     z
 #  [1] "local: FALSE"
 #  [1] "MySQL: FALSE"
 #  [1] "Spark: FALSE"
 #    column index     class nrows nna nunique min max mean        sd lexmin lexmax
 #  1      p     1   integer     3   1      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer     3   0      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric     3   1      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character     3   0      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character     3   0      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %.>% replyr::replyr_colClasses(.) 
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
 #  d1 %.>% replyr::replyr_testCols(., is.numeric) 
 #      p     w     x     y     z 
 #   TRUE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %.>% replyr::replyr_dim(.) 
 #  [1] 3 5
 #  
 #  d1 %.>% replyr::replyr_nrow(.) 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d3> [?? x 2]
 #  # Database: sqlite 3.19.3 [:memory:]
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
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_dfrhuit3k6kvnsbgqzib_0000000001> [?? x 2]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x     y match
 #    <chr> <int> <int>
 #  1     a     1     1
 #  2     a     2     1
 #  3     b     3     0
 #  4     b     4     0
 #  5     c     5     1
 #  6     c     6     1
 #  # Source:   table<d4> [?? x 1]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %.>% replyr::replyr_uniqueValues(., "x") 
 #  # Source:   lazy query [?? x 2]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1     1                      1
 #  2     2                      1
 #  3     3                      2
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: sqlite 3.19.3 [:memory:]
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example 1"
 #  # Source:     table<replyr_coalesce_nwodq1oh3i9rnymrja0x_0000000008> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
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
 #  # Source:     table<replyr_coalesce_e8ofnjeuhvgekjme4yrx_0000000006> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
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
 #  # Source:     table<replyr_bind_rows_sf0lixrd8tjzucv6sepd_0000000003> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  # Source:     table<replyr_gapply_l2zywxf1vwy2cmrxefr9_0000000006> [?? x 2]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "moveValuesToColumnsQ"
 #  # Source:     table<mvtcq_fbwet6cpu6pyunt38kl6_0000000001> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
 #  # Source:     table<mvtrq_awyboh021nhdowpsprlk_0000000001> [?? x 4]
 #  # Database:   sqlite 3.19.3 [:memory:]
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
DBI::dbDisconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  873621 46.7    1442291 77.1  1442291 77.1
 #  Vcells 1661415 12.7    3142662 24.0  2060182 15.8
```

MySQL example ("docker start mysql"). Kind of a poor results as the adapted MySql has a hard time with `NA`.

Taking MySQL check out, too much trouble to maintain the testing database (docker now not sharing ports on the container for MySQL).

``` r
my_db <- dplyr::src_mysql('mysql','127.0.0.1',3306,'root','')
class(my_db)
copyToRemote <- remoteCopy(my_db)

resMySQL <- runExample(copyToRemote)

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
DBI::dbDisconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
```

PostgreSQL example ("docker start pg").

``` r
library('RPostgreSQL')
 #  Loading required package: DBI
my_db <- DBI::dbConnect(dbDriver("PostgreSQL"), 
                        host = 'localhost',
                        port = 5432,
                        user = 'postgres',
                        password = 'pg')

class(my_db)
 #  [1] "PostgreSQLConnection"
 #  attr(,"package")
 #  [1] "RPostgreSQL"
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
 #  1      p     1   logical     3   1      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer     3   0      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric     3   1      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character     3   0      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character     3   0      NA  NA  NA   NA        NA      a      z
 #  
 #  d1 %.>% replyr::replyr_colClasses(.) 
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
 #  d1 %.>% replyr::replyr_testCols(., is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %.>% replyr::replyr_dim(.) 
 #  [1] 3 5
 #  
 #  d1 %.>% replyr::replyr_nrow(.) 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3    NA     z
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
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
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_7kxdv1ubgili3kxbqevh_0000000001> [?? x 2]
 #  # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
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
 #  d4 %.>% replyr::replyr_uniqueValues(., "x") 
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
 #  # Source:     table<replyr_coalesce_kx1kk4f9cyez2ihes8na_0000000008> [?? x 3]
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
 #  # Source:     table<replyr_coalesce_r8mkcmhbxa7mossvf9y3_0000000006> [?? x 3]
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
 #  # Source:     table<replyr_bind_rows_0qtqb1lufvnjqlze1czc_0000000003> [?? x 3]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  # Source:     table<replyr_gapply_9tde07s2xqlslq5jm5st_0000000006> [?? x 2]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "moveValuesToColumnsQ"
 #  # Source:     table<mvtcq_mqtulrlmryr1cdtim4xo_0000000001> [?? x 3]
 #  # Database:   postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
 #  # Source:     table<mvtrq_xry6omzpdze9kr6jj0h9_0000000001> [?? x 4]
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
DBI::dbDisconnect(my_db)
 #  [1] TRUE
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  912510 48.8    1442291 77.1  1442291 77.1
 #  Vcells 1705367 13.1    3142662 24.0  2237797 17.1
```

Another PostgreSQL example [`devtools::install_github('rstats-db/RPostgres')`](https://github.com/r-dbi/RPostgres). Doesn't seem to work with `dplyr` yet. The following fails:

``` r
library("RPostgres")
my_db <- DBI::dbConnect(RPostgres::Postgres(),
  host = 'localhost',
  port = 5432,
  user = 'postgres',
  password = 'pg')
dplyr::copy_to(my_db, data.frame(x=1), 'tmpnm')
DBI::dbDisconnect(my_db)
```

``` r
library("RPostgres")
my_db <- DBI::dbConnect(RPostgres::Postgres(),
  host = 'localhost',
  port = 5432,
  user = 'postgres',
  password = 'pg')
class(my_db)
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("RPostgres result differs")
}
DBI::dbDisconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
```

Spark 2. example (lowest version of Spark we are supporting).

``` r
# Can't easilly override Spark version once it is up.
my_db <- sparklyr::spark_connect(version='2.2.0', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/spark/spark-2.2.0-bin-hadoop2.7"
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
 #  d1 %.>% replyr::replyr_colClasses(.) 
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
 #  d1 %.>% replyr::replyr_testCols(., is.numeric) 
 #      p     w     x     y     z 
 #  FALSE  TRUE  TRUE FALSE FALSE 
 #  
 #  d1 %.>% replyr::replyr_dim(.) 
 #  [1] 3 5
 #  
 #  d1 %.>% replyr::replyr_nrow(.) 
 #  [1] 3
 #  # Source:   table<d2> [?? x 3]
 #  # Database: spark_connection
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3   NaN     z
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
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
 #  d2b %.>% replyr::replyr_quantile(., "x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
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
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_ca2pwv8agpahgca26rim_0000000001> [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
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
 #  d4 %.>% replyr::replyr_uniqueValues(., "x") 
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
 #  # Source:     table<sparklyr_tmp_f3ce5792c0d7> [?? x 3]
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
 #  # Source:     table<sparklyr_tmp_f3ce63b2902b> [?? x 3]
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
 #  # ... with more rows
 #  [1] "split re-join"
 #  # Source:     table<sparklyr_tmp_f3ce60172a2f> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010   NaN     c
 #  [1] "gapply"
 #  # Source:     table<sparklyr_tmp_f3ce10d2a4f2> [?? x 2]
 #  # Database:   spark_connection
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "moveValuesToColumnsQ"
 #  # Source:     table<mvtcq_ghoczlbrhhpkleuvbpcc_0000000001> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
 #  # Source:     table<mvtrq_4jtpmv2gisfunxyni9fv_0000000001> [?? x 4]
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
 #  Ncells  968683 51.8    1770749 94.6  1442291 77.1
 #  Vcells 1778119 13.6    3142662 24.0  2237797 17.1
```

``` r
print("all done")
 #  [1] "all done"
rm(list=ls())
gc(verbose = FALSE)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  967174 51.7    1770749 94.6  1442291 77.1
 #  Vcells 1772198 13.6    3142662 24.0  2237797 17.1
```
