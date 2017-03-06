`mutate` issue while using `sparklyr`, `Spark2`, and the dev version of `dplyr` (‘0.5.0.9000’, <https://github.com/hadley/dplyr> commit f39db50921110c3d23612cc81a7b3e027c0b3d1c ).

<!-- Generated from .Rmd. Please edit that file -->
``` r
library(sparklyr)
library(dplyr)
 #  
 #  Attaching package: 'dplyr'
 #  The following objects are masked from 'package:stats':
 #  
 #      filter, lag
 #  The following objects are masked from 'package:base':
 #  
 #      intersect, setdiff, setequal, union
library(nycflights13)
sc <- spark_connect(version='2.0.0', master = "local")
flts <- replyr::replyr_copy_to(sc, flights)
```

Ok:

``` r
flights %>% mutate(zzz=1)
 #  # A tibble: 336,776 × 20
 #      year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time arr_delay carrier
 #     <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>     <dbl>   <chr>
 #  1   2013     1     1      517            515         2      830            819        11      UA
 #  2   2013     1     1      533            529         4      850            830        20      UA
 #  3   2013     1     1      542            540         2      923            850        33      AA
 #  4   2013     1     1      544            545        -1     1004           1022       -18      B6
 #  5   2013     1     1      554            600        -6      812            837       -25      DL
 #  6   2013     1     1      554            558        -4      740            728        12      UA
 #  7   2013     1     1      555            600        -5      913            854        19      B6
 #  8   2013     1     1      557            600        -3      709            723       -14      EV
 #  9   2013     1     1      557            600        -3      838            846        -8      B6
 #  10  2013     1     1      558            600        -2      753            745         8      AA
 #  # ... with 336,766 more rows, and 10 more variables: flight <int>, tailnum <chr>, origin <chr>,
 #  #   dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>,
 #  #   zzz <dbl>
```

Throws:

``` r
flts %>% mutate(zzz=1)
 #  Source:     lazy query [?? x 20]
 #  Database:   spark connection master=local[4] app=sparklyr local=TRUE
 #  Error in UseMethod("escape"): no applicable method for 'escape' applied to an object of class "lazy"
```

``` r
R.Version()$version.string
 #  [1] "R version 3.3.2 (2016-10-31)"
packageVersion('dplyr')
 #  [1] '0.5.0.9000'
packageVersion('lazyeval')
 #  [1] '0.2.0'
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
 #  "->localhost:51499"          "sockconn"                "wb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $monitor
 #         description              class               mode               text             opened 
 #  "->localhost:8880"         "sockconn"               "rb"           "binary"           "opened" 
 #            can read          can write 
 #               "yes"              "yes" 
 #  
 #  $output_file
 #  [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//RtmpopGA2j/file12dd82d06e23f_spark.log"
 #  
 #  $spark_context
 #  <jobj[5]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@d47c549
 #  
 #  $java_context
 #  <jobj[6]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@3e64cd38
 #  
 #  $hive_context
 #  <jobj[9]>
 #    class org.apache.spark.sql.SparkSession
 #    org.apache.spark.sql.SparkSession@7b1e1d1d
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
