<!-- Generated from .Rmd. Please edit that file -->
Rename fails in Sparlyr
-----------------------

Renaim fails in Sparklyr, think it depends on verison of dplyr. Definitely seeing it in the dev version of dplyr as of 5-14-2017.

Submitted as [`Sparklyr` issue]() and [`dplyr` issue]().

``` r
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github('tidyverse/dbplyr')
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
```

    ## [1] '0.5.0.9004'

``` r
library('sparklyr')
packageVersion("sparklyr")
```

    ## [1] '0.5.4'

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
dLocal <- data.frame(x = 1:2,
                     origCol = c('a', 'b'),
                     stringsAsFactors = FALSE)

sc <- sparklyr::spark_connect(version='2.0.2', 
   master = "local")

d <- copy_to(sc, dLocal, 'd')

# works
rename(dLocal, x2 = x, origCol2 = origCol)
```

    ##   x2 origCol2
    ## 1  1        a
    ## 2  2        b

``` r
# throws
rename(d, x2 = x, origCol2 = origCol)
```

    ## Source:     lazy query [?? x 2]
    ## Database:   spark_connection

    ## Error in names(select)[match(old_vars, vars)] <- new_vars: NAs are not allowed in subscripted assignments

``` r
spark_disconnect(sc)
rm(list=ls())
gc(verbose = FALSE)
```

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  673129 36.0    1168576 62.5   940480 50.3
    ## Vcells 1157434  8.9    2060183 15.8  1364755 10.5
