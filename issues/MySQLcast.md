<!-- Generated from .Rmd. Please edit that file -->
Problem with MySQL cast
-----------------------

Simple cast emits `SQL` not accepted by `MySQL`.

Submitted as [`dplyr` issue 2775](https://github.com/tidyverse/dplyr/issues/2775) as `dbplyr` currently asks that issues be filed there.

``` r
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github('tidyverse/dbplyr')
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
```

    ## [1] '0.5.0.9004'

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
sc <- dplyr::src_mysql('mysql', 
                       '127.0.0.1', 
                       3306, 
                       'root', 'passwd')
d1 <- copy_to(sc, data.frame(x=1:3), 'd1')

# works, Note PostgreSQL needs this form 
# or it doesn't know type of newCol
mutate(d1, newCol= 'a')
```

    ## Source:     lazy query [?? x 2]
    ## Database:   mysql 5.6.34 [root@127.0.0.1:/mysql]
    ## 
    ## # A tibble: ?? x 2
    ##       x newCol
    ##   <int>  <chr>
    ## 1     1      a
    ## 2     2      a
    ## 3     3      a

``` r
# throws
mutate(d1, newCol= as.character('a'))
```

    ## Source:     lazy query [?? x 2]
    ## Database:   mysql 5.6.34 [root@127.0.0.1:/mysql]

    ## Error in .local(conn, statement, ...): could not run statement: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'TEXT) AS `newCol`
    ## FROM `d1`
    ## LIMIT 10' at line 1

``` r
rm(list=ls())
gc(verbose = FALSE)
```

    ## Auto-disconnecting MySQLConnection

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  627439 33.6    1168576 62.5   940480 50.3
    ## Vcells 1091446  8.4    2060183 15.8  1316802 10.1
