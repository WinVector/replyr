<!-- Generated from .Rmd. Please edit that file -->
`dplyr` and `sparklyr`
----------------------

Run DEV version of `dplyr` (appears to be CRAN release candidate) and DEV `sparklyr` as of 5-19-2017.

``` r
# devtools::install_github('tidyverse/dbplyr')
# devtools::install_github('rstudio/sparklyr')
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
```

    ## [1] '0.6.0'

``` r
library('sparklyr')
packageVersion("sparklyr")
```

    ## [1] '0.5.4.9003'

``` r
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
```

    ## [1] '0.0.0.9001'

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

``` r
base::date()
```

    ## [1] "Fri May 19 13:04:39 2017"

``` r
sc <- sparklyr::spark_connect(version='2.0.2', 
   master = "local")
```

``` r
d1 <- copy_to(sc, data.frame(x=1:3, y=4:6), 'd1',
              overwrite = TRUE)
d2 <- copy_to(sc, data.frame(x=1:3, y=7:9), 'd2',
              overwrite = TRUE)

left_join(d1, d2, by='x')
```

    ## # Source:   lazy query [?? x 3]
    ## # Database: spark_connection
    ##       x   y.x   y.y
    ##   <int> <int> <int>
    ## 1     1     4     7
    ## 2     2     5     8
    ## 3     3     6     9

``` r
dLocal <- data.frame(x = 1:2,
                     origCol = c('a', 'b'),
                     stringsAsFactors = FALSE)

d <- copy_to(sc, dLocal, 'd',
             overwrite = TRUE)

# local
rename(dLocal, x2 = x, origCol2 = origCol)
```

    ##   x2 origCol2
    ## 1  1        a
    ## 2  2        b

``` r
# Spark
rename(d, x2 = x, origCol2 = origCol)
```

    ## Error in names(select)[match(old_vars, vars)] <- new_vars: NAs are not allowed in subscripted assignments

``` r
spark_disconnect(sc)
rm(list=ls())
gc(verbose = FALSE)
```

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  710275 38.0    1168576 62.5  1168576 62.5
    ## Vcells 1208556  9.3    2060183 15.8  1511861 11.6
