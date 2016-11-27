Be aware different `dplyr` back-ends represent `NA` much differently. Expect numeric `NA` to be presented as `NaN` quite often, and expect database based implementations to use `NULL` (in their sense of `NULL`, *not* in R's sense) especially in character types. Also some `dplyr` back-ends may not have a currently accessible `NULL` concept for character types (such as Spark).

`dplyr` `0.5.0` with `RMySQL` `0.10.9` (both current on [Cran](https://cran.r-project.org) 11-27-2016) failing to insert `NULL` into `MySQL` (filed as [dplyr issue 2259](https://github.com/hadley/dplyr/issues/2259), status moved to duplicate of [dplyr issue 2256](https://github.com/hadley/dplyr/issues/2256)).

``` r
library('dplyr')
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library('nycflights13')
packageVersion('dplyr')
```

    ## [1] '0.5.0'

``` r
packageVersion('RMySQL')
```

    ## [1] '0.10.9'

``` r
mysql <- src_mysql('mysql','127.0.0.1',3306,'root','passwd')
flts <- flights
flights_mysql <- copy_to(mysql,flts,
  temporary = TRUE,overwrite = TRUE,
  indexes = list(c("year", "month", "day"), "carrier", "tailnum"))
```

    ## Error in if (n <= 65535) {: missing value where TRUE/FALSE needed

`Spark` `2.0.0` with `sparklyr` `0.4.26` not faithful to `NA` values in character or factor columns of `data.frame`. As we see below they get converted to blank in a round trip between local `data.frame`s and `Spark` representations. Obviously the round trip can not be fully faithful (we fully expect factors types to become character types, and can live with numeric `NA` becoming `NaN`) due to differences in representation. But `Spark` can represent missing values in character columns (for example see [here](http://stackoverflow.com/questions/32067467/create-new-dataframe-with-empty-null-field-values)).

Filed as [sparklyr issue 340](https://github.com/rstudio/sparklyr/issues/340).

``` r
library('sparklyr')
packageVersion('sparklyr')
```

    ## [1] '0.4.26'

``` r
s200 <- my_db <- sparklyr::spark_connect(version='2.0.0', 
   master = "local")

d2 <- data.frame(x=factor(c('z1',NA,'z3')),y=c(3,5,NA),z=c(NA,'a','z'),
                 stringsAsFactors = FALSE)
print(d2)
```

    ##      x  y    z
    ## 1   z1  3 <NA>
    ## 2 <NA>  5    a
    ## 3   z3 NA    z

``` r
d2r <- copy_to(s200,d2,'d2',
               temporary = FALSE,overwrite = TRUE)
print(d2r)
```

    ## Source:   query [?? x 3]
    ## Database: spark connection master=local[4] app=sparklyr local=TRUE
    ## 
    ##       x     y     z
    ##   <chr> <dbl> <chr>
    ## 1    z1     3      
    ## 2           5     a
    ## 3    z3   NaN     z

``` r
d2x <- as.data.frame(d2r)
print(d2x)
```

    ##    x   y z
    ## 1 z1   3  
    ## 2      5 a
    ## 3 z3 NaN z

``` r
summary(d2x)
```

    ##       x                   y            z            
    ##  Length:3           Min.   :3.0   Length:3          
    ##  Class :character   1st Qu.:3.5   Class :character  
    ##  Mode  :character   Median :4.0   Mode  :character  
    ##                     Mean   :4.0                     
    ##                     3rd Qu.:4.5                     
    ##                     Max.   :5.0                     
    ##                     NA's   :1

``` r
str(d2x)
```

    ## 'data.frame':    3 obs. of  3 variables:
    ##  $ x: chr  "z1" "" "z3"
    ##  $ y: num  3 5 NaN
    ##  $ z: chr  "" "a" "z"

``` r
version
```

    ##                _                           
    ## platform       x86_64-apple-darwin13.4.0   
    ## arch           x86_64                      
    ## os             darwin13.4.0                
    ## system         x86_64, darwin13.4.0        
    ## status                                     
    ## major          3                           
    ## minor          3.2                         
    ## year           2016                        
    ## month          10                          
    ## day            31                          
    ## svn rev        71607                       
    ## language       R                           
    ## version.string R version 3.3.2 (2016-10-31)
    ## nickname       Sincere Pumpkin Patch
