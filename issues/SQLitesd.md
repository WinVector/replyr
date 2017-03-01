Standard deviation with `SQLite` is zero when there is one data item, not the expected `NA`. Nocie the `sd()` calculation agrees with `R`'s local calculation when `n`&gt;1 so this isn't just a sample variance versus population variance issue.

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

# confirm sqlite can represent NA
d <- data.frame(x = c(1,NA,3))
dbData <- dplyr::copy_to(my_db, d, name='d', 
                           create=TRUE, overwrite=TRUE)
print(dbData)
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #        x
 #    <dbl>
 #  1     1
 #  2    NA
 #  3     3

for(n in 1:3) {
  print("***********")
  print(paste('n',n))
  dplyr::db_drop_table(my_db$con, 'd')
  d <- data.frame(x= seq_len(n))
  print("local")
  print(dplyr::summarise_all(d, dplyr::funs(sd)))
  dbData <- dplyr::copy_to(my_db, d, name='d', 
                           create=TRUE, overwrite=TRUE)
  print("RSQLite")
  print(dplyr::summarise_all(dbData, dplyr::funs(sd)))
  print("***********")
}
 #  [1] "***********"
 #  [1] "n 1"
 #  [1] "local"
 #     x
 #  1 NA
 #  [1] "RSQLite"
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #        x
 #    <dbl>
 #  1     0
 #  [1] "***********"
 #  [1] "***********"
 #  [1] "n 2"
 #  [1] "local"
 #            x
 #  1 0.7071068
 #  [1] "RSQLite"
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #            x
 #        <dbl>
 #  1 0.7071068
 #  [1] "***********"
 #  [1] "***********"
 #  [1] "n 3"
 #  [1] "local"
 #    x
 #  1 1
 #  [1] "RSQLite"
 #  Source:   query [?? x 1]
 #  Database: sqlite 3.11.1 [:memory:]
 #  
 #        x
 #    <dbl>
 #  1     1
 #  [1] "***********"
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
 #  Ncells 469545 25.1     750400 40.1   592000 31.7
 #  Vcells 657764  5.1    1308461 10.0   914785  7.0
```
