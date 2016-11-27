Copy issue with `sparklyr` 1.6.2.

<!-- Generated from .Rmd. Please edit that file -->
Below is why we use a new column name in joins.

OSX 10.11.6. Spark installed as described at <http://spark.rstudio.com>

    library('sparklyr')
    spark_install(version = "1.6.2")

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
 #  [1] '0.4.26'
my_db <- sparklyr::spark_connect(version='1.6.2', master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-1.6.2-bin-hadoop2.6"
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
 #  [1] "1.*"
 #  
 #  attr(,"config")
 #  [1] "default"
 #  attr(,"file")
 #  [1] "/Library/Frameworks/R.framework/Versions/3.3/Resources/library/sparklyr/conf/config-template.yml"
 #  
 #  $spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-1.6.2-bin-hadoop2.6"
 #  
 #  $backend
 #          description               class                mode                text              opened 
 #  "->localhost:65205"          "sockconn"                "wb"            "binary"            "opened" 
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
 #  [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//Rtmp9CLaR1/filebaf31ce93d7_spark.log"
 #  
 #  $spark_context
 #  <jobj[4]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@3de7466a
 #  
 #  $java_context
 #  <jobj[5]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@f8e6ad4
 #  
 #  $hive_context
 #  <jobj[6]>
 #    class org.apache.spark.sql.hive.HiveContext
 #    org.apache.spark.sql.hive.HiveContext@768ed13
 #  
 #  attr(,"class")
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
d1 <- copy_to(my_db,data.frame(x=c(1,2),y=c('a','b')),'d1')
d2 <- copy_to(my_db,data.frame(y=c('a','b'),z=c(3,4)),'d2')
d1 %>% dplyr::inner_join(d2,by='y')
 #  Source:   query [?? x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  Error in sql_join.spark_connection(con, from_x, from_y, type = query$type, : This dplyr operation requires a feature not supported in Spark 1.6.2 . Try Spark 2.0.0 instead or avoid using same-column names in joins.
```

Submitted as [sparklyr issue 338](https://github.com/rstudio/sparklyr/issues/338).

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
