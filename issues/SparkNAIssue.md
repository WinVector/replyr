<!-- Generated from .Rmd. Please edit that file -->
`NA` issue while using `sparklyr`, `Spark2`, and `dplyr`. It also looks like several places `NA` and `""` are confused and reversed, confuses, or suppressed.

Submitted as [`sparklyr` issue 528](https://github.com/rstudio/sparklyr/issues/528) and [`sparklyr` issue 680](https://github.com/rstudio/sparklyr/issues/680).

``` r
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
 #  [1] '0.5.0'
library('sparklyr')
packageVersion("sparklyr")
 #  [1] '0.5.4'
sc <- sparklyr::spark_connect(version='2.0.2', 
                              master = "local")
d1 <- data.frame(x= c('a',NA), 
                 stringsAsFactors= FALSE)
# Notice d1s appears truncated to 1 row
ds1 <- dplyr::copy_to(sc,d1)
print(ds1)
 #  Source:   query [1 x 1]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #  # A tibble: 1 x 1
 #        x
 #    <chr>
 #  1     a
nrow(ds1)
 #  [1] 1
```
