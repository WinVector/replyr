<!-- Generated from .Rmd. Please edit that file -->
`dplyr` and `sparklyr`
----------------------

Run CRAN version of `dplyr` and CRAN `sparklyr` as of 5-14-2017.

``` r
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github('tidyverse/dbplyr')
# devtools::install_github('rstudio/sparklyr')
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
```

    ## [1] '0.5.0'

``` r
library('sparklyr')
packageVersion("sparklyr")
```

    ## [1] '0.5.4'

``` r
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

``` r
base::date()
```

    ## [1] "Mon May 15 15:14:01 2017"

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

    ## Source:   query [3 x 3]
    ## Database: spark connection master=local[4] app=sparklyr local=TRUE
    ## 
    ## # A tibble: 3 x 3
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

    ## Source:   query [2 x 2]
    ## Database: spark connection master=local[4] app=sparklyr local=TRUE
    ## 
    ## # A tibble: 2 x 2
    ##      x2 origCol2
    ##   <int>    <chr>
    ## 1     1        a
    ## 2     2        b

``` r
spark_disconnect(sc)
rm(list=ls())
gc(verbose = FALSE)
```

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  669821 35.8    1168576 62.5  1168576 62.5
    ## Vcells 1163675  8.9    2060183 15.8  1395946 10.7
