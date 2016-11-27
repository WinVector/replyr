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

Submitted as [dplyr issue 2269](https://github.com/hadley/dplyr/issues/2269).
