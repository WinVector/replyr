### binding rows on spark

It would be nice if `dplyr::bind_rows` could be a used on `Sparklyr` data handles.

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
 #  "->localhost:59749"          "sockconn"                "wb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $monitor
 #          description               class                mode                text              opened 
 #  "->localhost:59746"          "sockconn"                "rb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $output_file
 #  [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//Rtmp53Q24W/file1028369792a5f_spark.log"
 #  
 #  $spark_context
 #  <jobj[5]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@4fc20fe9
 #  
 #  $java_context
 #  <jobj[6]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@5ca96df5
 #  
 #  $hive_context
 #  <jobj[9]>
 #    class org.apache.spark.sql.SparkSession
 #    org.apache.spark.sql.SparkSession@279bd0b6
 #  
 #  attr(,"class")
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
```

-   Expected outcome: dplyr::bind\_rows to work with `Sparklyr` data reference.
-   Observed outcome: can't bind.

``` r
support <- copy_to(my_db,
                   data.frame(year=2005:2010),
                   'support')

# This form doesn't work.
dplyr::bind_rows(support, support)
 #  # A tibble: 24 × 4
 #                  con    src     x  vars
 #               <list> <list> <chr> <chr>
 #  1         <chr [1]> <NULL>  <NA>  <NA>
 #  2         <chr [1]> <NULL>  <NA>  <NA>
 #  3         <chr [1]> <NULL>  <NA>  <NA>
 #  4        <list [5]> <NULL>  <NA>  <NA>
 #  5         <chr [1]> <NULL>  <NA>  <NA>
 #  6    <S3: sockconn> <NULL>  <NA>  <NA>
 #  7    <S3: sockconn> <NULL>  <NA>  <NA>
 #  8         <chr [1]> <NULL>  <NA>  <NA>
 #  9  <S3: spark_jobj> <NULL>  <NA>  <NA>
 #  10 <S3: spark_jobj> <NULL>  <NA>  <NA>
 #  # ... with 14 more rows

# This form doesn't work.
dplyr::bind_rows(list(support, support))
 #  Error in eval(expr, envir, enclos): incompatible sizes (1 != 3)
```

To submit as sparklyr issue.

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
