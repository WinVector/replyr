Factor with R data.frame.

<!-- Generated from .Rmd. Please edit that file -->
Some issues with `summarize_each` and factors.

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
R.Version()$version.string
 #  [1] "R version 3.3.2 (2016-10-31)"
packageVersion('dplyr')
 #  [1] '0.5.0'
d1 <- data.frame(y=c('a','b'),stringsAsFactors = FALSE)
d1 %>% dplyr::summarise_each(dplyr::funs(lexmin = min,lexmax = max))
 #    lexmin lexmax
 #  1      a      b
d2 <- data.frame(y=c('a','b'),stringsAsFactors = TRUE)
d2 %>% dplyr::summarise_each(dplyr::funs(lexmin = min,lexmax = max))
 #  Error in eval(expr, envir, enclos): 'min' not meaningful for factors
```

Submitted as [dplyr issue 2269](https://github.com/hadley/dplyr/issues/2269). Closed as "expected behavior" as this is what `min(factor(letters))` does. That is a correct determination, but be aware many `dplyr` backends do support comparison, min, and max on characters types.

``` r
my_db <- dplyr::src_sqlite("replyr_sqliteEx.sqlite3", create = TRUE)
dplyr::copy_to(dest=my_db,df=d1,name='d1',overwrite=TRUE) %>% 
  dplyr::summarise_each(dplyr::funs(lexmin = min,lexmax = max))
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #    lexmin lexmax
 #     <chr>  <chr>
 #  1      a      b
dplyr::copy_to(dest=my_db,df=d2,name='d2',overwrite=TRUE) %>% 
  dplyr::summarise_each(dplyr::funs(lexmin = min,lexmax = max))
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #    lexmin lexmax
 #     <chr>  <chr>
 #  1      a      b
```
