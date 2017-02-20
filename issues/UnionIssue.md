### Union order issue

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
 #  "->localhost:53247"          "sockconn"                "wb"            "binary"            "opened" 
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
 #  [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//Rtmpz5ZYCx/file126507d7ca72e_spark.log"
 #  
 #  $spark_context
 #  <jobj[5]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@8dbf495
 #  
 #  $java_context
 #  <jobj[6]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@a7cdca2
 #  
 #  $hive_context
 #  <jobj[9]>
 #    class org.apache.spark.sql.SparkSession
 #    org.apache.spark.sql.SparkSession@56ebcf45
 #  
 #  attr(,"class")
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
```

-   Expected outcome: dplyr::union and dplyr::union\_all should match columns.
-   Observed outcome: matches columns on local data frames, matches positions on spark2.0.0.

``` r
d1 <- data.frame(year=2005:2010,
                 name='a',
                 stringsAsFactors = FALSE)
d2 <- data.frame(name='b',
                 year=2005:2010,
                 stringsAsFactors = FALSE)

# local frames: uses names on union
dplyr::union(d1, d2)
 #     year name
 #  1  2010    b
 #  2  2009    b
 #  3  2008    b
 #  4  2007    b
 #  5  2006    b
 #  6  2005    b
 #  7  2010    a
 #  8  2009    a
 #  9  2008    a
 #  10 2007    a
 #  11 2006    a
 #  12 2005    a
dplyr::union_all(d1, d2)
 #     year name
 #  1  2005    a
 #  2  2006    a
 #  3  2007    a
 #  4  2008    a
 #  5  2009    a
 #  6  2010    a
 #  7  2005    b
 #  8  2006    b
 #  9  2007    b
 #  10 2008    b
 #  11 2009    b
 #  12 2010    b


s1 <- copy_to(my_db, d1, 's1')
s2 <- copy_to(my_db, d2, 's2')

# remore frames: uses position, co-mingline different types
dplyr::union(s1,s2)
 #  Source:   query [12 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #      year  name
 #     <chr> <chr>
 #  1   2007     a
 #  2      b  2008
 #  3      b  2010
 #  4   2006     a
 #  5   2008     a
 #  6      b  2006
 #  7   2009     a
 #  8   2010     a
 #  9   2005     a
 #  10     b  2005
 #  11     b  2007
 #  12     b  2009
dplyr::union_all(s1,s2)
 #  Source:   query [12 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #      year  name
 #     <chr> <chr>
 #  1   2005     a
 #  2   2006     a
 #  3   2007     a
 #  4   2008     a
 #  5   2009     a
 #  6   2010     a
 #  7      b  2005
 #  8      b  2006
 #  9      b  2007
 #  10     b  2008
 #  11     b  2009
 #  12     b  2010
```

To submit as a sparklyr issue.

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
