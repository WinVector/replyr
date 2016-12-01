Check durability of `dplyr::arrange` through `dplyr::compute`.

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
library('RPostgreSQL')
 #  Loading required package: DBI
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('RPostgreSQL')
 #  [1] '0.4.1'
my_db <- dplyr::src_postgres(host = 'localhost',port = 5432,user = 'postgres',password = 'pg')
class(my_db)
 #  [1] "src_postgres" "src_sql"      "src"
set.seed(32525)
dz <- dplyr::copy_to(my_db,data.frame(x=runif(1000)),'dz99',overwrite=TRUE)
```

Notice below: no warnings in frame or runtime.

``` r
dz %>% arrange(x) %>% mutate(ccol=1) %>% mutate(rank=cumsum(ccol))  -> dz1
print(dz1)
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  
 #               x  ccol  rank
 #           <dbl> <dbl> <dbl>
 #  1  0.002176207     1     1
 #  2  0.003543465     1     2
 #  3  0.004778773     1     3
 #  4  0.005225066     1     4
 #  5  0.005311800     1     5
 #  6  0.005833068     1     6
 #  7  0.006158232     1     7
 #  8  0.006178999     1     8
 #  9  0.006268262     1     9
 #  10 0.007748033     1    10
 #  # ... with more rows
warnings()
 #  NULL
```

Notice below: warning "Warning: Windowed expression 'sum("ccol")' does not have explicit order.". Result may appear the same, but we do not seem to be able to depend on that.

``` r
dz %>% arrange(x) %>% compute() %>% mutate(ccol=1) %>% mutate(rank=cumsum(ccol))  -> dz2
print(dz2)
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  Warning: Windowed expression 'sum("ccol")' does not have explicit order.
 #  Please use arrange() to make determinstic.
 #               x  ccol  rank
 #           <dbl> <dbl> <dbl>
 #  1  0.002176207     1     1
 #  2  0.003543465     1     2
 #  3  0.004778773     1     3
 #  4  0.005225066     1     4
 #  5  0.005311800     1     5
 #  6  0.005833068     1     6
 #  7  0.006158232     1     7
 #  8  0.006178999     1     8
 #  9  0.006268262     1     9
 #  10 0.007748033     1    10
 #  # ... with more rows
warnings()
 #  NULL
```

Notice below: warning "Warning: Windowed expression 'sum("ccol")' does not have explicit order.". Result may appear the same, but we do not seem to be able to depend on that.

``` r
dz %>% arrange(x) %>% collapse() %>% mutate(ccol=1) %>% mutate(rank=cumsum(ccol))  -> dz3
print(dz3)
 #  Source:   query [?? x 3]
 #  Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
 #  Warning: Windowed expression 'sum("ccol")' does not have explicit order.
 #  Please use arrange() to make determinstic.
 #               x  ccol  rank
 #           <dbl> <dbl> <dbl>
 #  1  0.002176207     1     1
 #  2  0.003543465     1     2
 #  3  0.004778773     1     3
 #  4  0.005225066     1     4
 #  5  0.005311800     1     5
 #  6  0.005833068     1     6
 #  7  0.006158232     1     7
 #  8  0.006178999     1     8
 #  9  0.006268262     1     9
 #  10 0.007748033     1    10
 #  # ... with more rows
warnings()
 #  NULL
```

Submitted as [dplyr issue 2281](https://github.com/hadley/dplyr/issues/2281).

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
