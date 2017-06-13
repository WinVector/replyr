`union_all` issue with `SQLite`. Submitted as [dplyr issue 2270](https://github.com/hadley/dplyr/issues/2270).

<!-- Generated from .Rmd. Please edit that file -->
``` r
suppressPackageStartupMessages(library('dplyr'))
packageVersion('dplyr')
 #  [1] '0.7.0'
packageVersion('dbplyr')
 #  [1] '1.0.0'
my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
dr <- dplyr::copy_to(my_db,
                     data.frame(x=c(1,2), y=c('a','b'),
                                stringsAsFactors = FALSE),
                     'dr',
                     overwrite=TRUE)
dr <- head(dr,1)
# dr <- compute(dr)
print(dr)
 #  # Source:   lazy query [?? x 2]
 #  # Database: sqlite 3.11.1 [:memory:]
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
print(dplyr::union_all(dr,dr))
 #  Error: SQLite does not support set operations on LIMITs
```

Filed as [RSQLite 215](https://github.com/rstats-db/RSQLite/issues/215) and [dplyr 2858](https://github.com/tidyverse/dplyr/issues/2858).

``` r
rm(list=ls())
gc()
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  620852 33.2    1168576 62.5   940480 50.3
 #  Vcells 1095786  8.4    2060183 15.8  1388772 10.6
```

Note calling `compute` doesn't always fix the problem in my more complicated production example. Also `union` seems to not have the same issue as `union_all`. It also seems like nested function calls exacerbating the issue, perhaps a reference to a necissary structure goes out of scope and allows sub-table collection too soon? To trigger the full error in `replyr` force use of `union_all` in `replyr_bind_rows` and then try knitting `basicChecksSpark200.Rmd`.

The following now works:

``` r
suppressPackageStartupMessages(library('dplyr'))
suppressPackageStartupMessages(library('sparklyr'))
packageVersion('dplyr')
 #  [1] '0.7.0'
packageVersion('dbplyr')
 #  [1] '1.0.0'
packageVersion('sparklyr')
 #  [1] '0.5.6'
my_db <- sparklyr::spark_connect(version='2.0.0', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
da <- dplyr::copy_to(my_db,
                     data.frame(x=c(1,2),y=c('a','b'),
                                stringsAsFactors = FALSE),
                     'da',
                     overwrite=TRUE)
da <- head(da,1)
print(da)
 #  # Source:   lazy query [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
db <- dplyr::copy_to(my_db,
                     data.frame(x=c(3,4),y=c('c','d'),
                                stringsAsFactors = FALSE),
                     'db',
                     overwrite=TRUE)
db <- head(db,1)
#da <- compute(da)
db <- compute(db)
print(db)
 #  # Source:   table<xdpgkdmlpt> [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <dbl> <chr>
 #  1     3     c
res <- dplyr::union_all(da,db)
res <- dplyr::compute(res)
print(res)
 #  # Source:   table<omfsgngwxz> [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     3     c
print(da)
 #  # Source:   lazy query [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
print(db)
 #  # Source:   table<xdpgkdmlpt> [?? x 2]
 #  # Database: spark_connection
 #        x     y
 #    <dbl> <chr>
 #  1     3     c
```

``` r
rm(list=ls())
gc()
 #            used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells  751959 40.2    1442291 77.1  1168576 62.5
 #  Vcells 1258380  9.7    2060183 15.8  1793341 13.7
```

``` r
version
 #                 _                           
 #  platform       x86_64-apple-darwin15.6.0   
 #  arch           x86_64                      
 #  os             darwin15.6.0                
 #  system         x86_64, darwin15.6.0        
 #  status                                     
 #  major          3                           
 #  minor          4.0                         
 #  year           2017                        
 #  month          04                          
 #  day            21                          
 #  svn rev        72570                       
 #  language       R                           
 #  version.string R version 3.4.0 (2017-04-21)
 #  nickname       You Stupid Darkness
```
