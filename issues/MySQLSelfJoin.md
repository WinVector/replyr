<!-- Generated from .Rmd. Please edit that file -->
MySQL fails on self-join
------------------------

Submitted as [`dplyr` issue 2777](https://github.com/tidyverse/dplyr/issues/2777).

``` r
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github('tidyverse/dbplyr')
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
packageVersion("RMySQL")
```

    ## [1] '0.10.11'

``` r
packageVersion("dplyr")
```

    ## [1] '0.5.0'

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

``` r
suppressPackageStartupMessages(library('dplyr'))
sc <- src_mysql('mysql', '127.0.0.1', 3306,
                'root', '')
d <- copy_to(sc, data.frame(x=1:3), 'd')

# copy
d2 <- d %>% 
  filter(TRUE) %>% 
  compute()

# works
left_join(d, d2, by='x')
```

    ## Source:   query [?? x 1]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]
    ## 
    ## # A tibble: ?? x 1
    ##       x
    ##   <int>
    ## 1     1
    ## 2     2
    ## 3     3

``` r
# throws
left_join(d, d, by='x')
```

    ## Source:   query [?? x 1]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]

    ## Error in .local(conn, statement, ...): could not run statement: Not unique table/alias: 'd'
