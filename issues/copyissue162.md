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
 #  [1] '0.4'
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
 #  $config$sparklyr.defaultPackages
 #  [1] "com.databricks:spark-csv_2.11:1.3.0"    "com.amazonaws:aws-java-sdk-pom:1.10.34"
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
 #  "->localhost:49818"          "sockconn"                "wb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $monitor
 #          description               class                mode                text              opened 
 #  "->localhost:49819"          "sockconn"                "a+"              "text"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $output_file
 #  [1] "/var/folders/6t/x_r4km317f3gdmnvlcwb349w0000gn/T//RtmpZ107OV/file3cf9563de116_spark.log"
 #  
 #  $spark_context
 #  <jobj[4]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@54379b45
 #  
 #  $java_context
 #  <jobj[5]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@653eb971
 #  
 #  $hive_context
 #  <jobj[6]>
 #    class org.apache.spark.sql.hive.HiveContext
 #    org.apache.spark.sql.hive.HiveContext@2294bd5
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
