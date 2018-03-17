Example trying most of the `replyr` functions on a few data sources.

``` r
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
 #  [1] '0.7.4'
# possibly need this https://github.com/tidyverse/dplyr/issues/3145
suppressPackageStartupMessages(library('dbplyr'))
packageVersion("dbplyr")
 #  [1] '1.2.1'
suppressPackageStartupMessages(library('sparklyr'))
packageVersion("sparklyr")
 #  [1] '0.7.0'
R.Version()$version.string
 #  [1] "R version 3.4.4 (2018-03-15)"
library("replyr")
 #  Loading required package: wrapr
packageVersion("replyr")
 #  [1] '0.9.3'
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
 #  1    1.                     1.
 #  2    2.                     1.
 #  3    3.                     2.
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
 #  Warning: 'pivotValuesToColumns' is deprecated.
 #  Use 'pivot_to_rowrecs' instead.
 #  See help("Deprecated")
 #    index meastype_meas1 meastype_meas2
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
 #  Warning: 'unpivotValuesToRows' is deprecated.
 #  Use 'unpivot_to_blocks' instead.
 #  See help("Deprecated")
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
 #    p         w     x y     z    
 #    <lgl> <int> <dbl> <fct> <chr>
 #  1 TRUE      1   NA  3     a    
 #  2 FALSE     2    2. 5     b    
 #  3 NA        3    3. hi    z    
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
 #        x     y z    
 #    <dbl> <dbl> <fct>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
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
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
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
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 b         3
 #  4 b         4
 #  5 c         5
 #  6 c         6
 #  [1] "a" "c"
 #  
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # A tibble: 4 x 2
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 c         5
 #  4 c         6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
 #  # A tibble: 6 x 3
 #    x         y match
 #    <chr> <int> <lgl>
 #  1 a         1 TRUE 
 #  2 a         2 TRUE 
 #  3 b         3 FALSE
 #  4 b         4 FALSE
 #  5 c         5 TRUE 
 #  6 c         6 TRUE 
 #  # A tibble: 4 x 1
 #        x
 #    <dbl>
 #  1    1.
 #  2    2.
 #  3    3.
 #  4    3.
 #  
 #  d4 %.>% replyr::replyr_uniqueValues(., "x") 
 #  # A tibble: 3 x 2
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1    1.                     1.
 #  2    2.                     1.
 #  3    3.                     2.
 #  [1] "let example"
 #  # A tibble: 2 x 4
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl> <fct>   <dbl>
 #  1         5.80        4.00 setosa     0.
 #  2         5.70        4.40 setosa     1.
 #  [1] "coalesce example 1"
 #  # A tibble: 6 x 3
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2006.    0. ""   
 #  3 2007.    1. b    
 #  4 2008.    0. ""   
 #  5 2009.    0. ""   
 #  6 2010.   NA  c    
 #  [1] "coalesce example 2"
 #  # A tibble: 24 x 3
 #      year count name 
 #     <dbl> <dbl> <chr>
 #   1 2005.    6. a    
 #   2 2005.    0. b    
 #   3 2005.    0. c    
 #   4 2005.    0. d    
 #   5 2006.    0. a    
 #   6 2006.    0. b    
 #   7 2006.    0. c    
 #   8 2006.    0. d    
 #   9 2007.    0. a    
 #  10 2007.    1. b    
 #  # ... with 14 more rows
 #  [1] "split re-join"
 #  # A tibble: 3 x 3
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2007.    1. b    
 #  3 2010.   NA  c    
 #  [1] "gapply"
 #  # A tibble: 2 x 2
 #       cv group
 #    <dbl> <dbl>
 #  1   20.    1.
 #  2    8.    2.
 #  [1] "moveValuesToColumnsQ"
 #  Warning: 'pivotValuesToColumns' is deprecated.
 #  Use 'pivot_to_rowrecs' instead.
 #  See help("Deprecated")
 #    index meastype_meas1 meastype_meas2
 #  1     1           m1_1           m2_1
 #  2     2           m1_2           m2_2
 #  3     3           m1_3           m2_3
 #  [1] "moveValuesToRowsQ"
 #  Warning: 'unpivotValuesToRows' is deprecated.
 #  Use 'unpivot_to_blocks' instead.
 #  See help("Deprecated")
 #    index info meastype meas
 #  1     1    a    meas1 m1_1
 #  2     1    a    meas2 m2_1
 #  3     2    b    meas1 m1_2
 #  4     2    b    meas2 m2_2
 #  5     3    c    meas1 m1_3
 #  6     3    c    meas2 m2_3
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
 #        p     w     x y     z    
 #    <int> <int> <dbl> <chr> <chr>
 #  1     1     1   NA  3     a    
 #  2     0     2    2. 5     b    
 #  3    NA     3    3. hi    z    
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
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
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
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
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
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 b         3
 #  4 b         4
 #  5 c         5
 #  6 c         6
 #  [1] "a" "c"
 #  
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_95674997989025564789_0000000001> [?? x 2]
 #  # Database: sqlite 3.19.3 [:memory:]
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 c         5
 #  4 c         6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: sqlite 3.19.3 [:memory:]
 #    x         y match
 #    <chr> <int> <int>
 #  1 a         1     1
 #  2 a         2     1
 #  3 b         3     0
 #  4 b         4     0
 #  5 c         5     1
 #  6 c         6     1
 #  # Source:   table<d4> [?? x 1]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x
 #    <dbl>
 #  1    1.
 #  2    2.
 #  3    3.
 #  4    3.
 #  
 #  d4 %.>% replyr::replyr_uniqueValues(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:   lazy query [?? x 2]
 #  # Database: sqlite 3.19.3 [:memory:]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1    1.                     1.
 #  2    2.                     1.
 #  3    3.                     2.
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: sqlite 3.19.3 [:memory:]
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl> <chr>   <dbl>
 #  1         5.80        4.00 setosa     0.
 #  2         5.70        4.40 setosa     1.
 #  [1] "coalesce example 1"
 #  # Source:     lazy query [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: year, name
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2006.    0. ""   
 #  3 2007.    1. b    
 #  4 2008.    0. ""   
 #  5 2009.    0. ""   
 #  6 2010.   NA  c    
 #  [1] "coalesce example 2"
 #  # Source:     lazy query [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: year, name
 #      year count name 
 #     <dbl> <dbl> <chr>
 #   1 2005.    6. a    
 #   2 2005.    0. b    
 #   3 2005.    0. c    
 #   4 2005.    0. d    
 #   5 2006.    0. a    
 #   6 2006.    0. b    
 #   7 2006.    0. c    
 #   8 2006.    0. d    
 #   9 2007.    0. a    
 #  10 2007.    1. b    
 #  # ... with more rows
 #  [1] "split re-join"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:     lazy query [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: year
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2007.    1. b    
 #  3 2010.   NA  c    
 #  [1] "gapply"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  # Source:     lazy query [?? x 2]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1   20.    1.
 #  2    8.    2.
 #  [1] "moveValuesToColumnsQ"
 #  Warning: 'buildPivotControlTableN' is deprecated.
 #  Use 'build_pivot_control_q' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToColumnsN' is deprecated.
 #  Use 'blocks_to_rowrecs_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtcq_10609802984139325486_0000000001> [?? x 3]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl> <chr>          <chr>         
 #  1    1. m1_1           m2_1          
 #  2    2. m1_2           m2_2          
 #  3    3. m1_3           m2_3          
 #  [1] "moveValuesToRowsQ"
 #  Warning: 'buildUnPivotControlTable' is deprecated.
 #  Use 'build_unpivot_control' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToRowsN' is deprecated.
 #  Use 'rowrecs_to_blocks_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtrq_88457624043151960123_0000000001> [?? x 4]
 #  # Database:   sqlite 3.19.3 [:memory:]
 #  # Ordered by: index, meastype
 #    index info  meastype meas 
 #    <dbl> <chr> <chr>    <chr>
 #  1    1. a     meas1    m1_1 
 #  2    1. a     meas2    m2_1 
 #  3    2. b     meas1    m1_2 
 #  4    2. b     meas2    m2_2 
 #  5    3. c     meas1    m1_3 
 #  6    3. c     meas2    m2_3
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
failingFrameIndices(resBase, resSQLite)
 #  integer(0)
if(!listsOfSameData(resBase, resSQLite)) {
  stop("SQLite result differs")
}
DBI::dbDisconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  915939 49.0    1442291 77.1  1442291 77.1
 #  Vcells 1749208 13.4    3142662 24.0  2060183 15.8
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

PostgreSQL example.

``` r
library('RPostgreSQL')
 #  Loading required package: DBI
my_db <- DBI::dbConnect(dbDriver("PostgreSQL"), 
                        host = 'localhost',
                        port = 5432,
                        user = 'johnmount',
                        password = '')

class(my_db)
 #  [1] "PostgreSQLConnection"
 #  attr(,"package")
 #  [1] "RPostgreSQL"
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
 #  [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"     
 #  [1] "src_dbi" "src_sql" "src"    
 #  # Source:   table<d1> [?? x 5]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #    p         w     x y     z    
 #    <lgl> <int> <dbl> <chr> <chr>
 #  1 TRUE      1   NA  3     a    
 #  2 FALSE     2    2. 5     b    
 #  3 NA        3    3. hi    z    
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
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d3> [?? x 2]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 b         3
 #  4 b         4
 #  5 c         5
 #  6 c         6
 #  [1] "a" "c"
 #  
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_33942794466505049329_0000000001> [?? x 2]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 c         5
 #  4 c         6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #    x         y match
 #    <chr> <int> <lgl>
 #  1 a         1 TRUE 
 #  2 a         2 TRUE 
 #  3 b         3 FALSE
 #  4 b         4 FALSE
 #  5 c         5 TRUE 
 #  6 c         6 TRUE 
 #  # Source:   table<d4> [?? x 1]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #        x
 #    <dbl>
 #  1    1.
 #  2    2.
 #  3    3.
 #  4    3.
 #  
 #  d4 %.>% replyr::replyr_uniqueValues(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:   lazy query [?? x 2]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1    3.                     2.
 #  2    2.                     1.
 #  3    1.                     1.
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl> <chr>   <dbl>
 #  1         5.80        4.00 setosa     0.
 #  2         5.70        4.40 setosa     1.
 #  [1] "coalesce example 1"
 #  # Source:     lazy query [?? x 3]
 #  # Database:   postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #  # Ordered by: year, name
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2006.    0. ""   
 #  3 2007.    1. b    
 #  4 2008.    0. ""   
 #  5 2009.    0. ""   
 #  6 2010.   NA  c    
 #  [1] "coalesce example 2"
 #  # Source:     lazy query [?? x 3]
 #  # Database:   postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #  # Ordered by: year, name
 #      year count name 
 #     <dbl> <dbl> <chr>
 #   1 2005.    6. a    
 #   2 2005.    0. b    
 #   3 2005.    0. c    
 #   4 2005.    0. d    
 #   5 2006.    0. a    
 #   6 2006.    0. b    
 #   7 2006.    0. c    
 #   8 2006.    0. d    
 #   9 2007.    0. a    
 #  10 2007.    1. b    
 #  # ... with more rows
 #  [1] "split re-join"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:     lazy query [?? x 3]
 #  # Database:   postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #  # Ordered by: year
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2007.    1. b    
 #  3 2010.   NA  c    
 #  [1] "gapply"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  # Source:     lazy query [?? x 2]
 #  # Database:   postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1   20.    1.
 #  2    8.    2.
 #  [1] "moveValuesToColumnsQ"
 #  Warning: 'buildPivotControlTableN' is deprecated.
 #  Use 'build_pivot_control_q' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToColumnsN' is deprecated.
 #  Use 'blocks_to_rowrecs_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtcq_45890429850114047756_0000000001> [?? x 3]
 #  # Database:   postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #  # Ordered by: index
 #    index meastype_meas2 meastype_meas1
 #    <dbl> <chr>          <chr>         
 #  1    1. m2_1           m1_1          
 #  2    2. m2_2           m1_2          
 #  3    3. m2_3           m1_3          
 #  [1] "moveValuesToRowsQ"
 #  Warning: 'buildUnPivotControlTable' is deprecated.
 #  Use 'build_unpivot_control' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToRowsN' is deprecated.
 #  Use 'rowrecs_to_blocks_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtrq_65122406339624246044_0000000001> [?? x 4]
 #  # Database:   postgres 10.0.2 [johnmount@localhost:5432/johnmount]
 #  # Ordered by: index, meastype
 #    index info  meastype meas 
 #    <dbl> <chr> <chr>    <chr>
 #  1    1. a     meas1    m1_1 
 #  2    1. a     meas2    m2_1 
 #  3    2. b     meas1    m1_2 
 #  4    2. b     meas2    m2_2 
 #  5    3. c     meas1    m1_3 
 #  6    3. c     meas2    m2_3
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("PostgreSQL result differs")
}
DBI::dbDisconnect(my_db)
 #  [1] TRUE
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  956092 51.1    1770749 94.6  1770749 94.6
 #  Vcells 1795185 13.7    3142662 24.0  2319878 17.7
```

RPostgres example.

``` r
library("RPostgres")
 #  Warning: multiple methods tables found for 'dbQuoteLiteral'
 #  
 #  Attaching package: 'RPostgres'
 #  The following object is masked from 'package:DBI':
 #  
 #      dbQuoteLiteral
my_db <- DBI::dbConnect(RPostgres::Postgres(),
  host = 'localhost',
  port = 5432,
  user = 'johnmount',
  password = '')
class(my_db)
 #  [1] "PqConnection"
 #  attr(,"package")
 #  [1] "RPostgres"
copyToRemote <- remoteCopy(my_db)
resPostgreSQL <- runExample(copyToRemote)
 #  [1] "tbl_dbi"  "tbl_sql"  "tbl_lazy" "tbl"     
 #  [1] "src_dbi" "src_sql" "src"    
 #  # Source:   table<d1> [?? x 5]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #    p         w     x y     z    
 #    <lgl> <int> <dbl> <chr> <chr>
 #  1 TRUE      1   NA  3     a    
 #  2 FALSE     2    2. 5     b    
 #  3 NA        3    3. hi    z    
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
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d2b> [?? x 3]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.   NA  z    
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %.>% replyr::replyr_summary(.) 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0      NA   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1      NA   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0      NA  NA  NA   NA       NA      a      z
 #  # Source:   table<d3> [?? x 2]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 b         3
 #  4 b         4
 #  5 c         5
 #  6 c         6
 #  [1] "a" "c"
 #  
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_23557807208847877441_0000000001> [?? x 2]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 c         5
 #  4 c         6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #    x         y match
 #    <chr> <int> <lgl>
 #  1 a         1 TRUE 
 #  2 a         2 TRUE 
 #  3 b         3 FALSE
 #  4 b         4 FALSE
 #  5 c         5 TRUE 
 #  6 c         6 TRUE 
 #  # Source:   table<d4> [?? x 1]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #        x
 #    <dbl>
 #  1    1.
 #  2    2.
 #  3    3.
 #  4    3.
 #  
 #  d4 %.>% replyr::replyr_uniqueValues(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:   lazy query [?? x 2]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1    3.                     2.
 #  2    2.                     1.
 #  3    1.                     1.
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: postgres [johnmount@localhost:5432/johnmount]
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl> <chr>   <dbl>
 #  1         5.80        4.00 setosa     0.
 #  2         5.70        4.40 setosa     1.
 #  [1] "coalesce example 1"
 #  # Source:     lazy query [?? x 3]
 #  # Database:   postgres [johnmount@localhost:5432/johnmount]
 #  # Ordered by: year, name
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2006.    0. ""   
 #  3 2007.    1. b    
 #  4 2008.    0. ""   
 #  5 2009.    0. ""   
 #  6 2010.   NA  c    
 #  [1] "coalesce example 2"
 #  # Source:     lazy query [?? x 3]
 #  # Database:   postgres [johnmount@localhost:5432/johnmount]
 #  # Ordered by: year, name
 #      year count name 
 #     <dbl> <dbl> <chr>
 #   1 2005.    6. a    
 #   2 2005.    0. b    
 #   3 2005.    0. c    
 #   4 2005.    0. d    
 #   5 2006.    0. a    
 #   6 2006.    0. b    
 #   7 2006.    0. c    
 #   8 2006.    0. d    
 #   9 2007.    0. a    
 #  10 2007.    1. b    
 #  # ... with more rows
 #  [1] "split re-join"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:     lazy query [?? x 3]
 #  # Database:   postgres [johnmount@localhost:5432/johnmount]
 #  # Ordered by: year
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2007.    1. b    
 #  3 2010.   NA  c    
 #  [1] "gapply"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  # Source:     lazy query [?? x 2]
 #  # Database:   postgres [johnmount@localhost:5432/johnmount]
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1   20.    1.
 #  2    8.    2.
 #  [1] "moveValuesToColumnsQ"
 #  Warning: 'buildPivotControlTableN' is deprecated.
 #  Use 'build_pivot_control_q' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToColumnsN' is deprecated.
 #  Use 'blocks_to_rowrecs_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtcq_59704491202297011109_0000000001> [?? x 3]
 #  # Database:   postgres [johnmount@localhost:5432/johnmount]
 #  # Ordered by: index
 #    index meastype_meas2 meastype_meas1
 #    <dbl> <chr>          <chr>         
 #  1    1. m2_1           m1_1          
 #  2    2. m2_2           m1_2          
 #  3    3. m2_3           m1_3          
 #  [1] "moveValuesToRowsQ"
 #  Warning: 'buildUnPivotControlTable' is deprecated.
 #  Use 'build_unpivot_control' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToRowsN' is deprecated.
 #  Use 'rowrecs_to_blocks_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtrq_20996552756165041193_0000000001> [?? x 4]
 #  # Database:   postgres [johnmount@localhost:5432/johnmount]
 #  # Ordered by: index, meastype
 #    index info  meastype meas 
 #    <dbl> <chr> <chr>    <chr>
 #  1    1. a     meas1    m1_1 
 #  2    1. a     meas2    m2_1 
 #  3    2. b     meas1    m1_2 
 #  4    2. b     meas2    m2_2 
 #  5    3. c     meas1    m1_3 
 #  6    3. c     meas2    m2_3
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
if(!listsOfSameData(resBase, resPostgreSQL)) {
  stop("RPostgres result differs")
}
DBI::dbDisconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  993222 53.1    1770749 94.6  1770749 94.6
 #  Vcells 1836590 14.1    3142662 24.0  2442305 18.7
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
 #    p         w     x y     z    
 #    <lgl> <int> <dbl> <chr> <chr>
 #  1 TRUE      1  NaN  3     a    
 #  2 FALSE     2    2. 5     b    
 #  3 FALSE     3    3. hi    z    
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
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.  NaN  z    
 #  
 #  d2 %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
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
 #        x     y z    
 #    <dbl> <dbl> <chr>
 #  1    1.    3. a    
 #  2    2.    5. a    
 #  3    3.  NaN  z    
 #  
 #  d2b %.>% replyr::replyr_quantile(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MIN(x, na.rm = TRUE)` to silence this warning
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
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 b         3
 #  4 b         4
 #  5 c         5
 #  6 c         6
 #  [1] "a" "c"
 #  
 #  d3 %.>% replyr::replyr_filter(., "x",values,verbose=FALSE) 
 #  # Source:   table<replyr_filter_91133044417888552062_0000000001> [?? x 2]
 #  # Database: spark_connection
 #    x         y
 #    <chr> <int>
 #  1 a         1
 #  2 a         2
 #  3 c         5
 #  4 c         6
 #  
 #  d3 %.>% replyr::replyr_inTest(., "x",values,"match",verbose=FALSE) 
 #  # Source:   lazy query [?? x 3]
 #  # Database: spark_connection
 #    x         y match
 #    <chr> <int> <lgl>
 #  1 a         1 TRUE 
 #  2 a         2 TRUE 
 #  3 b         3 FALSE
 #  4 b         4 FALSE
 #  5 c         5 TRUE 
 #  6 c         6 TRUE 
 #  # Source:   table<d4> [?? x 1]
 #  # Database: spark_connection
 #        x
 #    <dbl>
 #  1    1.
 #  2    2.
 #  3    3.
 #  4    3.
 #  
 #  d4 %.>% replyr::replyr_uniqueValues(., "x")
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:   lazy query [?? x 2]
 #  # Database: spark_connection
 #        x replyr_private_value_n
 #    <dbl>                  <dbl>
 #  1    1.                     1.
 #  2    3.                     2.
 #  3    2.                     1.
 #  [1] "let example"
 #  # Source:   lazy query [?? x 4]
 #  # Database: spark_connection
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl> <chr>   <dbl>
 #  1         5.80        4.00 setosa     0.
 #  2         5.70        4.40 setosa     1.
 #  [1] "coalesce example 1"
 #  # Source:     table<sparklyr_tmp_e5a44ea09528> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year, name
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2006.    0. ""   
 #  3 2007.    1. b    
 #  4 2008.    0. ""   
 #  5 2009.    0. ""   
 #  6 2010.  NaN  c    
 #  [1] "coalesce example 2"
 #  # Source:     table<sparklyr_tmp_e5a410a09d6c> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year, name
 #      year count name 
 #     <dbl> <dbl> <chr>
 #   1 2005.    6. a    
 #   2 2005.    0. b    
 #   3 2005.    0. c    
 #   4 2005.    0. d    
 #   5 2006.    0. a    
 #   6 2006.    0. b    
 #   7 2006.    0. c    
 #   8 2006.    0. d    
 #   9 2007.    0. a    
 #  10 2007.    1. b    
 #  # ... with more rows
 #  [1] "split re-join"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  # Source:     table<sparklyr_tmp_e5a420bf25fb> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: year
 #     year count name 
 #    <dbl> <dbl> <chr>
 #  1 2005.    6. a    
 #  2 2007.    1. b    
 #  3 2010.  NaN  c    
 #  [1] "gapply"
 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `SUM(x, na.rm = TRUE)` to silence this warning
 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning

 #  Warning: Missing values are always removed in SQL.
 #  Use `MAX(x, na.rm = TRUE)` to silence this warning
 #  # Source:     table<sparklyr_tmp_e5a465569288> [?? x 2]
 #  # Database:   spark_connection
 #  # Ordered by: group
 #       cv group
 #    <dbl> <dbl>
 #  1   20.    1.
 #  2    8.    2.
 #  [1] "moveValuesToColumnsQ"
 #  Warning: 'buildPivotControlTableN' is deprecated.
 #  Use 'build_pivot_control_q' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToColumnsN' is deprecated.
 #  Use 'blocks_to_rowrecs_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtcq_16558064860594359970_0000000001> [?? x 3]
 #  # Database:   spark_connection
 #  # Ordered by: index
 #    index meastype_meas1 meastype_meas2
 #    <dbl> <chr>          <chr>         
 #  1    1. m1_1           m2_1          
 #  2    2. m1_2           m2_2          
 #  3    3. m1_3           m2_3          
 #  [1] "moveValuesToRowsQ"
 #  Warning: 'buildUnPivotControlTable' is deprecated.
 #  Use 'build_unpivot_control' instead.
 #  See help("Deprecated")
 #  Warning: 'moveValuesToRowsN' is deprecated.
 #  Use 'rowrecs_to_blocks_q' instead.
 #  See help("Deprecated")
 #  # Source:     table<mvtrq_48453938392767669441_0000000001> [?? x 4]
 #  # Database:   spark_connection
 #  # Ordered by: index, meastype
 #    index info  meastype meas 
 #    <dbl> <chr> <chr>    <chr>
 #  1    1. a     meas1    m1_1 
 #  2    1. a     meas2    m2_1 
 #  3    2. b     meas1    m1_2 
 #  4    2. b     meas2    m2_2 
 #  5    3. c     meas1    m1_3 
 #  6    3. c     meas2    m2_3
if(!listsOfSameData(resBase, resSpark)) {
  stop("Spark result differs")
}
spark_disconnect(my_db)
rm(list=c('my_db','copyToRemote')); gc(verbose = FALSE) # disconnect
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 1049479 56.1    1770749 94.6  1770749 94.6
 #  Vcells 1908344 14.6    3142662 24.0  2442305 18.7
```

``` r
print("all done")
 #  [1] "all done"
rm(list=ls())
gc(verbose = FALSE)
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 1047849 56.0    1770749 94.6  1770749 94.6
 #  Vcells 1903614 14.6    3142662 24.0  2442305 18.7
```
