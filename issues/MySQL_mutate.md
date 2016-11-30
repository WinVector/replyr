Issues with `dplyr::mutate` and `RMySQL`.

<!-- Generated from .Rmd. Please edit that file -->
Can not prevent the warning.

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
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('RMySQL')
 #  [1] '0.10.9'

my_db <- src_mysql('mysql','127.0.0.1',3306,'root','passwd')
d4 <- copy_to(my_db,data.frame(x=c(1.1,2,3,3)),'d4')
suppressWarnings(
  d4 %>% mutate(z=1) %>% compute() -> d4
)
print(d4)
 #  Source:   query [?? x 2]
 #  Database: mysql 5.6.34 [root@127.0.0.1:/mysql]
 #  Warning in .local(conn, statement, ...): Decimal MySQL column 1 imported as numeric
 #        x     z
 #    <dbl> <dbl>
 #  1   1.1     1
 #  2   2.0     1
 #  3   3.0     1
 #  4   3.0     1
```

Submitted as [RMySQL 176](https://github.com/rstats-db/RMySQL/issues/176).

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
