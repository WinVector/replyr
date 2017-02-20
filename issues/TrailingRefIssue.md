<!-- Generated from .Rmd. Please edit that file -->
OSX 10.11.6. Spark installed as described at <http://spark.rstudio.com>

    library('sparklyr')
    spark_install(version = "2.0.0")

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
R.Version()$version.string
 #  [1] "R version 3.3.2 (2016-10-31)"
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('sparklyr')
 #  [1] '0.5.2'
my_db <- sparklyr::spark_connect(version='2.0.0', master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
print(my_db)
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
 #  "->localhost:58964"          "sockconn"                "wb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $monitor
 #          description               class                mode                text              opened 
 #  "->localhost:58961"          "sockconn"                "rb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $output_file
 #  [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//Rtmpxkn3Al/filefeb634813b11_spark.log"
 #  
 #  $spark_context
 #  <jobj[5]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@73d0c0e5
 #  
 #  $java_context
 #  <jobj[6]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@4e527f99
 #  
 #  $hive_context
 #  <jobj[9]>
 #    class org.apache.spark.sql.SparkSession
 #    org.apache.spark.sql.SparkSession@1346ee7
 #  
 #  attr(,"class")
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
```

-   Expected outcome: `s1` has the same value
-   Observed outcome: changing varaible v changes `s1` column.

``` r
support <- copy_to(my_db,
                   data.frame(year=2005:2010),
                   'support')
v <- 0
s1 <- dplyr::mutate(support,count=v)

print(s1) # print 1
 #  Source:   query [6 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #     year count
 #    <int> <dbl>
 #  1  2005     0
 #  2  2006     0
 #  3  2007     0
 #  4  2008     0
 #  5  2009     0
 #  6  2010     0

# s1 <- dplyr::compute(s1) # likely work-around
v <- ''

print(s1) # print 2
 #  Source:   query [6 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #     year count
 #    <int> <chr>
 #  1  2005      
 #  2  2006      
 #  3  2007      
 #  4  2008      
 #  5  2009      
 #  6  2010
```

Notice `s1` changed its value (like due to lazy evaluation and having captured a reference to `v`).

To submit as a dplyr issue.

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
