Copy issue with `sparklyr` 1.6.2.

<!-- Generated from .Rmd. Please edit that file -->
logical to numeric clobber
--------------------------

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
d <- data.frame(x=c(1,2,2),y=c(3,5,NA),z=c(NA,'a','b'),
                rowNum=1:3,
                stringsAsFactors = FALSE)
print(d)
 #    x  y    z rowNum
 #  1 1  3 <NA>      1
 #  2 2  5    a      2
 #  3 2 NA    b      3

fnam <- tempfile(pattern = "dplyr_doc_narm", tmpdir = tempdir(), fileext = "sqlite3")
my_db <- dplyr::src_sqlite(fnam, create = TRUE)
class(my_db)
 #  [1] "src_sqlite" "src_sql"    "src"
dRemote <- copy_to(my_db,d,'d',rowNumberColumn='rowNum',overwrite=TRUE)


# correct calculation
dRemote %>% mutate(nna=0) %>%
  mutate(nna=nna+ifelse(is.na(x),1,0)) %>% 
  mutate(nna=nna+ifelse(is.na(y),1,0)) %>% 
  mutate(nna=nna+ifelse(is.na(z),1,0))  
 #  Source:   query [?? x 5]
 #  Database: sqlite 3.8.6 [/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//RtmpIEbtbD/dplyr_doc_narm9634188713ccsqlite3]
 #  
 #        x     y     z rowNum   nna
 #    <dbl> <dbl> <chr>  <int> <dbl>
 #  1     1     3  <NA>      1     1
 #  2     2     5     a      2     0
 #  3     2    NA     b      3     1
 
# incorrect calculation (last step seems to always clobber the previous result)
dRemote %>% mutate(nna=0) %>%
  mutate(nna=nna+is.na(x)) %>% 
  mutate(nna=nna+is.na(y)) %>% 
  mutate(nna=nna+is.na(z))
 #  Source:   query [?? x 5]
 #  Database: sqlite 3.8.6 [/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//RtmpIEbtbD/dplyr_doc_narm9634188713ccsqlite3]
 #  
 #        x     y     z rowNum   nna
 #    <dbl> <dbl> <chr>  <int> <int>
 #  1     1     3  <NA>      1     1
 #  2     2     5     a      2     0
 #  3     2    NA     b      3     0

# clean up
rm(list=setdiff(ls(),'fnam'))
if(!is.null(fnam)) {
  file.remove(fnam)
}
 #  [1] TRUE
gc()
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 464057 24.8     750400 40.1   592000 31.7
 #  Vcells 656572  5.1    1308461 10.0   920492  7.1
```
