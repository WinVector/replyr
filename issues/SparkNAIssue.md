`NA` issue while using `sparklyr`, `Spark2`, and `dplyr`. It also looks like several places `NA` and `""` are confused and reversed.

It thank `NA`'s can be represented in Spark2, they are definitely behaving as something different than a blank string. They are also erroring-out.

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
library('sparklyr')
sc <- sparklyr::spark_connect(version='2.0.0', 
                              master = "local")
```

``` r
d1 <- data.frame(x= c('a',NA), 
                 stringsAsFactors= FALSE)
print(d1)
 #       x
 #  1    a
 #  2 <NA>
nrow(d1)
 #  [1] 2

# Notice d1 appears truncated to 1 row
ds1 <- dplyr::copy_to(sc,d1)
print(ds1)
 #  Source:   query [1 x 1]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x
 #    <chr>
 #  1     a
nrow(ds1)
 #  [1] 1
```

``` r
# this block is just repeating expected behavior
# without NA
d2 <- data.frame(x= c('a','b'),
                 y= 1:2,
                 stringsAsFactors= FALSE)
print(d2)
 #    x y
 #  1 a 1
 #  2 b 2
nrow(d2)
 #  [1] 2

ds2 <- dplyr::copy_to(sc,d2)
print(ds2)
 #  Source:   query [2 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     b     2
nrow(ds2)
 #  [1] 2
ds2 %>% summarize_each(funs(min))
 #  Source:   query [1 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
```

``` r
# this block is showing behavior different than
# previous block due to NA
d3 <- data.frame(x= c('a', '', NA),
                 y= 1:3,
                 stringsAsFactors= FALSE)
print(d3)
 #       x y
 #  1    a 1
 #  2      2
 #  3 <NA> 3
nrow(d3)
 #  [1] 3
d3 %>% summarize_each(funs(min))
 #       x y
 #  1 <NA> 1
d3 %>% mutate(isna= is.na(x))
 #       x y  isna
 #  1    a 1 FALSE
 #  2      2 FALSE
 #  3 <NA> 3  TRUE

ds3 <- dplyr::copy_to(sc,d3)
print(ds3) # Note NA and '' are reversed
 #  Source:   query [3 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2  <NA>     2
 #  3           3
nrow(ds3)
 #  [1] 3
# errors
ds3 %>% summarize_each(funs(min))
 #  Source:   query [1 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  Error: Variables must be length 1 or 1.
 #  Problem variables: 'x'
ds3 %>% mutate(xb=paste0('|',x,'|'))
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y    xb
 #    <chr> <int> <chr>
 #  1     a     1   |a|
 #  2  <NA>     2  <NA>
 #  3           3    ||
ds3 %>% mutate(xn=nchar(x))
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y    xn
 #    <chr> <int> <int>
 #  1     a     1     1
 #  2  <NA>     2    NA
 #  3           3     0
```

``` r
# errors
ds3 %>% mutate(isna= is.na(x))
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y  isna
 #    <chr> <int> <lgl>
 #  1     a     1 FALSE
 #  2  <NA>     2  TRUE
 #  3           3 FALSE
```

``` r
# works
ds3 %>% filter(y==1)
 #  Source:   query [1 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
# works
ds3 %>% filter(y==2)
 #  Source:   query [1 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1  <NA>     2
# errors out
ds3 %>% filter(y==3)
 #  Source:   query [1 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  Error: Variables must be length 1 or 1.
 #  Problem variables: 'x'
```


``` r
R.Version()$version.string
 #  [1] "R version 3.3.2 (2016-10-31)"
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('sparklyr')
 #  [1] '0.5.2'
class(sc)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
sc$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
print(sc)
 #  $master
 #  [1] "local[4]"
 #  
 #  $method
 #  [1] "shell"
 #  
 #  $app_name
 #  [1] "sparklyr"
 #  
 #  $config
 #  $config$sparklyr.cores.local
 #  [1] 4
 #  
 #  $config$spark.sql.shuffle.partitions.local
 #  [1] 4
 #  
 #  $config$spark.env.SPARK_LOCAL_IP.local
 #  [1] "127.0.0.1"
 #  
 #  $config$sparklyr.csv.embedded
 #  [1] "^1.*"
 #  
 #  $config$`sparklyr.shell.driver-class-path`
 #  [1] ""
 #  
 #  attr(,"config")
 #  [1] "default"
 #  attr(,"file")
 #  [1] "/Library/Frameworks/R.framework/Versions/3.3/Resources/library/sparklyr/conf/config-template.yml"
 #  
 #  $spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
 #  
 #  $backend
 #          description               class                mode                text              opened 
 #  "->localhost:53768"          "sockconn"                "wb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $monitor
 #          description               class                mode                text              opened 
 #  "->localhost:53765"          "sockconn"                "rb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $output_file
 #  [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//Rtmp9l32j3/filedd9c3245161d_spark.log"
 #  
 #  $spark_context
 #  <jobj[5]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@552b139a
 #  
 #  $java_context
 #  <jobj[6]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@4a2064c5
 #  
 #  $hive_context
 #  <jobj[9]>
 #    class org.apache.spark.sql.SparkSession
 #    org.apache.spark.sql.SparkSession@33761221
 #  
 #  attr(,"class")
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
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
