``` r
# 4-15-2017
# commit 58fcd949d7709b4be44e2789a1c5355a6bd148f3
# devtools::install_github("rstudio/sparklyr") 
# commit d7d2f10167b4ac919e876eb9a891fd53345be985
# devtools::install_github("tidyverse/dplyr")

library("sparklyr")
library("dplyr")
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library("nycflights13")
sc <- spark_connect(version='2.0.0', master = "local")
flts <- dplyr::copy_to(sc, flights)
```

``` r
packageVersion("sparklyr")
```

    ## [1] '0.5.3.9005'

``` r
packageVersion("dplyr")
```

    ## [1] '0.5.0.9002'

``` r
packageVersion("DBI")
```

    ## [1] '0.6.1'

``` r
flts %>% mutate(zzz=1)  # works with dev version of Sparklyr
```

    ## Source:     lazy query [?? x 20]
    ## Database:   spark_connection
    ## 
    ##     year month   day dep_time sched_dep_time dep_delay arr_time
    ##    <int> <int> <int>    <int>          <int>     <dbl>    <int>
    ## 1   2013     1     1      517            515         2      830
    ## 2   2013     1     1      533            529         4      850
    ## 3   2013     1     1      542            540         2      923
    ## 4   2013     1     1      544            545        -1     1004
    ## 5   2013     1     1      554            600        -6      812
    ## 6   2013     1     1      554            558        -4      740
    ## 7   2013     1     1      555            600        -5      913
    ## 8   2013     1     1      557            600        -3      709
    ## 9   2013     1     1      557            600        -3      838
    ## 10  2013     1     1      558            600        -2      753
    ## # ... with 3.368e+05 more rows, and 13 more variables:
    ## #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
    ## #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
    ## #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dbl>, zzz <dbl>

``` r
# used to fail 
#  https://github.com/tidyverse/dplyr/issues/2495
#  https://github.com/rstudio/sparklyr/issues/572 
#  https://github.com/rstudio/sparklyr/issues/577 
```

``` r
rm(list=ls())
gc()
```

    ##           used (Mb) gc trigger  (Mb) max used  (Mb)
    ## Ncells  564135 30.2    1731918  92.5  2107719 112.6
    ## Vcells 6243249 47.7   18183908 138.8 18823014 143.7
