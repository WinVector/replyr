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
 #  [1] '0.7.1.9000'
library('sparklyr')
 #  
 #  Attaching package: 'sparklyr'
 #  The following object is masked from 'package:dplyr':
 #  
 #      top_n
packageVersion("sparklyr")
 #  [1] '0.5.6.9012'
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
 #  [1] '1.1.0.9000'
R.Version()$version.string
 #  [1] "R version 3.4.0 (2017-04-21)"
library("replyr")
packageVersion("replyr")
 #  [1] '0.5.0'
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
 #  1      p     1   integer    NA  NA      NA   0   1  0.5 0.7071068   <NA>   <NA>
 #  2      w     2   integer    NA  NA      NA   1   3  2.0 1.0000000   <NA>   <NA>
 #  3      x     3   numeric    NA  NA      NA   2   3  2.5 0.7071068   <NA>   <NA>
 #  4      y     4 character    NA  NA      NA  NA  NA   NA        NA      3     hi
 #  5      z     5 character    NA  NA      NA  NA  NA   NA        NA      a      z
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
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
 #  1      x     1   numeric    NA  NA      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric    NA  NA      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character    NA  NA      NA  NA  NA   NA       NA      a      z
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
 #  # Source:   table<replyr_filter_J9w6N9tGvIikvZIWriZl_0000000001> [?? x 2]
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
 #  # Source:     table<llgjfmwhub> [?? x 3]
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
 #  # Source:     table<hcdrdzwcdc> [?? x 3]
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
 #  # Source:     table<ulrqbftqib> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010    NA     c
 #  [1] "gapply"
 #  # Source:     table<jphzbfsvak> [?? x 2]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # Source:     table<replyr_moveValuesToColumns_NXtyoNS5QL4pSWrLTKOS_0000000003> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # Source:     table<gwsfxwctqf> [?? x 4]
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
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #  Auto-disconnecting SQLiteConnection
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  854422 45.7    1442291 77.1  1442291 77.1
 #  Vcells 1609166 12.3    2552219 19.5  2059406 15.8
```

MySQL example ("docker start mysql"). Kind of poor as at least the adapted MySql has a hard time with `NA`.

Taking MySQL check out, too much trouble to maintain the testing database.

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
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
```

PostgreSQL example ("docker start pg").

``` r
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("PostgreSQL result differs")
}
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
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
 #  # Source:   table<replyr_filter_j5n6p165sHeWlsZTS7nU_0000000001> [?? x 2]
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
 #  # Source:     table<sparklyr_tmp_16bb76e9e1660> [?? x 3]
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
 #  # Source:     table<sparklyr_tmp_16bb74ccf315c> [?? x 3]
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
 #  # Source:     table<sparklyr_tmp_16bb736b1b669> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year
 #     year count  name
 #    <dbl> <dbl> <chr>
 #  1  2005     6     a
 #  2  2007     1     b
 #  3  2010   NaN     c
 #  [1] "gapply"
 #  # Source:     table<sparklyr_tmp_16bb74d3ec38c> [?? x 2]
 #  # Database:   spark_connection
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1    20     1
 #  2     8     2
 #  [1] "replyr_moveValuesToColumns"
 #  # Source:     table<replyr_moveValuesToColumns_MCKBFJaEO8qJJxN2Bf7q_0000000003> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl>          <chr>          <chr>
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "replyr_moveValuesToRows"
 #  # Source:     table<sparklyr_tmp_16bb7539843f2> [?? x 4]
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
 #  Ncells  905870 48.4    1442291 77.1  1442291 77.1
 #  Vcells 1678210 12.9    3142662 24.0  2091509 16.0
```

``` r
print("all done")
 #  [1] "all done"
rm(list=ls())
gc(verbose = FALSE)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  905076 48.4    1442291 77.1  1442291 77.1
 #  Vcells 1675722 12.8    3142662 24.0  2091509 16.0
```
