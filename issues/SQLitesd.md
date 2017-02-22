Standard deviation with `SQLite` is zero when there is one data item, not the expected `NA`.

<!-- Generated from .Rmd. Please edit that file -->
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
library('RSQLite')
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('RSQLite')
 #  [1] '1.1.2'

my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
d <- data.frame(x=1)
dplyr::summarise_all(d, dplyr::funs(sd))
 #     x
 #  1 NA
dbData <- dplyr::copy_to(my_db, d, create=TRUE)
dplyr::summarise_all(dbData, dplyr::funs(sd))
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #        x
 #    <dbl>
 #  1     0
```

Filed as [RSQLite 201](https://github.com/rstats-db/RSQLite/issues/201).

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

``` r
rm(list=ls())
gc()
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 470262 25.2     750400 40.1   592000 31.7
 #  Vcells 657577  5.1    1308461 10.0   906295  7.0
```
