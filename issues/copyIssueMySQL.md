Copy issue with `MySQL`.

<!-- Generated from .Rmd. Please edit that file -->
`MySQL` doesn't obey `overwrite=TRUE`, but since that is in the `...` region it is hard to say what correct behavior would be. `replyr` already works around it, this is just to explain why we take the trouble.

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
library('RMySQL')
 #  Loading required package: DBI
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('RMySQL')
 #  [1] '0.10.9'
my_db <- dplyr::src_sqlite("replyr_sqliteEx.sqlite3", create = TRUE)
d <- dplyr::copy_to(my_db,data.frame(x=c(1,2)),'d',overwrite=TRUE)
d <- dplyr::copy_to(my_db,data.frame(x=c(1,2)),'d',overwrite=TRUE)
 #  Error: Table d already exists.
```

``` r
version
 #                 _                           
 #  platform       x86_64-apple-darwin13.4.0   
 #  arch           x86_64                      
 #  os             darwin13.4.0                
 #  system         x86_64, darwin13.4.0        
 #  status                                     
 #  major          3                           
 #  minor          3.2                         
 #  year           2016                        
 #  month          10                          
 #  day            31                          
 #  svn rev        71607                       
 #  language       R                           
 #  version.string R version 3.3.2 (2016-10-31)
 #  nickname       Sincere Pumpkin Patch
```
