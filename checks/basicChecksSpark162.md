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
source('CheckFns.R')
```

Spark 1.6.2 example (failing, no longer supporting Spark 1.6.2).

``` r
# Can't easilly override Spark version once it is up.
my_db <- sparklyr::spark_connect(version='1.6.2', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-1.6.2-bin-hadoop2.6"
copyToRemote <- remoteCopy(my_db)
runExample(copyToRemote)
 #  [1] "tbl_spark" "tbl_sql"   "tbl_lazy"  "tbl"      
 #  [1] "src_spark"
 #  Source:   query [2 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
 #  2     2     b
 #  
 #  d1 %>% replyr::replyr_colClasses() 
 #  $x
 #  [1] "numeric"
 #  
 #  $y
 #  [1] "character"
 #  
 #  
 #  d1 %>% replyr::replyr_testCols(is.numeric) 
 #      x     y 
 #   TRUE FALSE 
 #  
 #  d1 %>% replyr::replyr_dim() 
 #  [1] 2 2
 #  
 #  d1 %>% replyr::replyr_nrow() 
 #  [1] 2
 #  
 #  d1 %>% replyr::replyr_str() 
 #  nrows: 2
 #  Observations: 2
 #  Variables: 2
 #  $ x <dbl> 1, 2
 #  $ y <chr> "a", "b"NULL
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3   NaN     z
 #  
 #  d2 %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2 %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
 #  Source:   query [3 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y     z
 #    <dbl> <dbl> <chr>
 #  1     1     3     a
 #  2     2     5     a
 #  3     3   NaN     z
 #  
 #  d2b %>% replyr::replyr_quantile("x") 
 #     0 0.25  0.5 0.75    1 
 #  1.00 1.00 1.75 2.75 3.00 
 #  
 #  d2b %>% replyr::replyr_summary() 
 #    column index     class nrows nna nunique min max mean       sd lexmin lexmax
 #  1      x     1   numeric     3   0       3   1   3    2 1.000000   <NA>   <NA>
 #  2      y     2   numeric     3   1       2   3   5    4 1.414214   <NA>   <NA>
 #  3      z     3 character     3   0       2  NA  NA   NA       NA      a      z
 #  Source:   query [6 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     b     3
 #  4     b     4
 #  5     c     5
 #  6     c     6
 #  [1] "a" "c"
 #  
 #  d3 %>% replyr::replyr_filter("x",values,verbose=FALSE) 
 #  Source:   query [4 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y
 #    <chr> <int>
 #  1     a     1
 #  2     a     2
 #  3     c     5
 #  4     c     6
 #  
 #  d3 %>% replyr::replyr_inTest("x",values,"match",verbose=FALSE) 
 #  Source:   query [6 x 3]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     y match
 #    <chr> <int> <lgl>
 #  1     a     1  TRUE
 #  2     a     2  TRUE
 #  3     b     3 FALSE
 #  4     b     4 FALSE
 #  5     c     5  TRUE
 #  6     c     6  TRUE
 #  Source:   query [4 x 1]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x
 #    <dbl>
 #  1     1
 #  2     2
 #  3     3
 #  4     3
 #  
 #  d4 %>% replyr::replyr_uniqueValues("x") 
 #  Source:   query [3 x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #        x     n
 #    <dbl> <dbl>
 #  1     1     1
 #  2     2     1
 #  3     3     2
 #  [1] "let example"
 #  Source:   query [2 x 4]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  
 #    Sepal_Length Sepal_Width Species  rank
 #           <dbl>       <dbl>   <chr> <dbl>
 #  1          5.8         4.0  setosa     0
 #  2          5.7         4.4  setosa     1
 #  [1] "coalesce example"
 #  Error: org.apache.spark.sql.AnalysisException: 
 #  Unsupported language features in query: SELECT *
 #  FROM (SELECT * FROM `support` AS `_LEFT`
 #  
 #  WHERE NOT EXISTS (
 #    SELECT 1 FROM `dcoalesce` AS `_RIGHT`
 #    WHERE (`_LEFT`.`year` = `_RIGHT`.`year`)
 #  )) `rqntvnexiq`
 #  LIMIT 6
 #  TOK_QUERY 2, 0,65, 20
 #    TOK_FROM 2, 4,61, 20
 #      TOK_SUBQUERY 2, 6,61, 20
 #        TOK_QUERY 2, 7,58, 20
 #          TOK_FROM 2, 11,17, 20
 #            TOK_TABREF 2, 13,17, 20
 #              TOK_TABNAME 2, 13,13, 20
 #                support 2, 13,13, 20
 #              _LEFT 2, 17,17, 33
 #          TOK_INSERT 0, -1,58, 0
 #            TOK_DESTINATION 0, -1,-1, 0
 #              TOK_DIR 0, -1,-1, 0
 #                TOK_TMP_FILE 0, -1,-1, 0
 #            TOK_SELECT 0, 7,9, 0
 #              TOK_SELEXPR 0, 9,9, 0
 #                TOK_ALLCOLREF 0, 9,9, 0
 #            TOK_WHERE 4, 20,58, 6
 #              NOT 4, 22,58, 6
 #                TOK_SUBQUERY_EXPR 4, 24,58, 10
 #                  TOK_SUBQUERY_OP 4, 24,24, 10
 #                    EXISTS 4, 24,24, 10
 #                  TOK_QUERY 5, 26,58, 16
 #                    TOK_FROM 5, 34,40, 16
 #                      TOK_TABREF 5, 36,40, 16
 #                        TOK_TABNAME 5, 36,36, 16
 #                          dcoalesce 5, 36,36, 16
 #                        _RIGHT 5, 40,40, 31
 #                    TOK_INSERT 0, -1,56, 0
 #                      TOK_DESTINATION 0, -1,-1, 0
 #                        TOK_DIR 0, -1,-1, 0
 #                          TOK_TMP_FILE 0, -1,-1, 0
 #                      TOK_SELECT 5, 30,32, 9
 #                        TOK_SELEXPR 5, 32,32, 9
 #                          1 5, 32,32, 9
 #                      TOK_WHERE 6, 44,56, 24
 #                        = 6, 46,56, 24
 #                          . 6, 47,49, 16
 #                            TOK_TABLE_OR_COL 6, 47,47, 9
 #                              _LEFT 6, 47,47, 9
 #                            year 6, 49,49, 17
 #                          . 6, 53,55, 34
 #                            TOK_TABLE_OR_COL 6, 53,53, 26
 #                              _RIGHT 6, 53,53, 26
 #                            year 6, 55,55, 35
 #        rqntvnexiq 7, 61,61, 3
 #    TOK_INSERT 0, -1,65, 0
 #      TOK_DESTINATION 0, -1,-1, 0
 #        TOK_DIR 0, -1,-1, 0
 #          TOK_TMP_FILE 0, -1,-1, 0
 #      TOK_SELECT 0, 0,2, 0
 #        TOK_SELEXPR 0, 2,2, 0
 #          TOK_ALLCOLREF 0, 2,2, 0
 #      TOK_LIMIT 8, 63,65, 6
 #        6 8, 65,65, 6
 #  
 #  scala.NotImplementedError: No parse rules for ASTNode type: 864, text: TOK_SUBQUERY_EXPR :
 #  TOK_SUBQUERY_EXPR 4, 24,58, 10
 #    TOK_SUBQUERY_OP 4, 24,24, 10
 #      EXISTS 4, 24,24, 10
 #    TOK_QUERY 5, 26,58, 16
 #      TOK_FROM 5, 34,40, 16
 #        TOK_TABREF 5, 36,40, 16
 #          TOK_TABNAME 5, 36,36, 16
 #            dcoalesce 5, 36,36, 16
 #          _RIGHT 5, 40,40, 31
 #      TOK_INSERT 0, -1,56, 0
 #        TOK_DESTINATION 0, -1,-1, 0
 #          TOK_DIR 0, -1,-1, 0
 #            TOK_TMP_FILE 0, -1,-1, 0
 #        TOK_SELECT 5, 30,32, 9
 #          TOK_SELEXPR 5, 32,32, 9
 #            1 5, 32,32, 9
 #        TOK_WHERE 6, 44,56, 24
 #          = 6, 46,56, 24
 #            . 6, 47,49, 16
 #              TOK_TABLE_OR_COL 6, 47,47, 9
 #                _LEFT 6, 47,47, 9
 #              year 6, 49,49, 17
 #            . 6, 53,55, 34
 #              TOK_TABLE_OR_COL 6, 53,53, 26
 #                _RIGHT 6, 53,53, 26
 #              year 6, 55,55, 35
 #  " +
 #           
 #  org.apache.spark.sql.hive.HiveQl$.nodeToExpr(HiveQl.scala:1721)
 #            ;
 #      at org.apache.spark.sql.hive.HiveQl$.createPlan(HiveQl.scala:326)
 #      at org.apache.spark.sql.hive.ExtendedHiveQlParser$$anonfun$hiveQl$1.apply(ExtendedHiveQlParser.scala:41)
 #      at org.apache.spark.sql.hive.ExtendedHiveQlParser$$anonfun$hiveQl$1.apply(ExtendedHiveQlParser.scala:40)
 #      at scala.util.parsing.combinator.Parsers$Success.map(Parsers.scala:136)
 #      at scala.util.parsing.combinator.Parsers$Success.map(Parsers.scala:135)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$map$1.apply(Parsers.scala:242)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$map$1.apply(Parsers.scala:242)
 #      at scala.util.parsing.combinator.Parsers$$anon$3.apply(Parsers.scala:222)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1$$anonfun$apply$2.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1$$anonfun$apply$2.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$Failure.append(Parsers.scala:202)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$$anon$3.apply(Parsers.scala:222)
 #      at scala.util.parsing.combinator.Parsers$$anon$2$$anonfun$apply$14.apply(Parsers.scala:891)
 #      at scala.util.parsing.combinator.Parsers$$anon$2$$anonfun$apply$14.apply(Parsers.scala:891)
 #      at scala.util.DynamicVariable.withValue(DynamicVariable.scala:57)
 #      at scala.util.parsing.combinator.Parsers$$anon$2.apply(Parsers.scala:890)
 #      at scala.util.parsing.combinator.PackratParsers$$anon$1.apply(PackratParsers.scala:110)
 #      at org.apache.spark.sql.catalyst.AbstractSparkSQLParser.parse(AbstractSparkSQLParser.scala:34)
 #      at org.apache.spark.sql.hive.HiveQl$.parseSql(HiveQl.scala:295)
 #      at org.apache.spark.sql.hive.HiveQLDialect$$anonfun$parse$1.apply(HiveContext.scala:66)
 #      at org.apache.spark.sql.hive.HiveQLDialect$$anonfun$parse$1.apply(HiveContext.scala:66)
 #      at org.apache.spark.sql.hive.client.ClientWrapper$$anonfun$withHiveState$1.apply(ClientWrapper.scala:290)
 #      at org.apache.spark.sql.hive.client.ClientWrapper.liftedTree1$1(ClientWrapper.scala:237)
 #      at org.apache.spark.sql.hive.client.ClientWrapper.retryLocked(ClientWrapper.scala:236)
 #      at org.apache.spark.sql.hive.client.ClientWrapper.withHiveState(ClientWrapper.scala:279)
 #      at org.apache.spark.sql.hive.HiveQLDialect.parse(HiveContext.scala:65)
 #      at org.apache.spark.sql.SQLContext$$anonfun$2.apply(SQLContext.scala:211)
 #      at org.apache.spark.sql.SQLContext$$anonfun$2.apply(SQLContext.scala:211)
 #      at org.apache.spark.sql.execution.SparkSQLParser$$anonfun$org$apache$spark$sql$execution$SparkSQLParser$$others$1.apply(SparkSQLParser.scala:114)
 #      at org.apache.spark.sql.execution.SparkSQLParser$$anonfun$org$apache$spark$sql$execution$SparkSQLParser$$others$1.apply(SparkSQLParser.scala:113)
 #      at scala.util.parsing.combinator.Parsers$Success.map(Parsers.scala:136)
 #      at scala.util.parsing.combinator.Parsers$Success.map(Parsers.scala:135)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$map$1.apply(Parsers.scala:242)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$map$1.apply(Parsers.scala:242)
 #      at scala.util.parsing.combinator.Parsers$$anon$3.apply(Parsers.scala:222)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1$$anonfun$apply$2.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1$$anonfun$apply$2.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$Failure.append(Parsers.scala:202)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$Parser$$anonfun$append$1.apply(Parsers.scala:254)
 #      at scala.util.parsing.combinator.Parsers$$anon$3.apply(Parsers.scala:222)
 #      at scala.util.parsing.combinator.Parsers$$anon$2$$anonfun$apply$14.apply(Parsers.scala:891)
 #      at scala.util.parsing.combinator.Parsers$$anon$2$$anonfun$apply$14.apply(Parsers.scala:891)
 #      at scala.util.DynamicVariable.withValue(DynamicVariable.scala:57)
 #      at scala.util.parsing.combinator.Parsers$$anon$2.apply(Parsers.scala:890)
 #      at scala.util.parsing.combinator.PackratParsers$$anon$1.apply(PackratParsers.scala:110)
 #      at org.apache.spark.sql.catalyst.AbstractSparkSQLParser.parse(AbstractSparkSQLParser.scala:34)
 #      at org.apache.spark.sql.SQLContext$$anonfun$1.apply(SQLContext.scala:208)
 #      at org.apache.spark.sql.SQLContext$$anonfun$1.apply(SQLContext.scala:208)
 #      at org.apache.spark.sql.execution.datasources.DDLParser.parse(DDLParser.scala:43)
 #      at org.apache.spark.sql.SQLContext.parseSql(SQLContext.scala:231)
 #      at org.apache.spark.sql.hive.HiveContext.parseSql(HiveContext.scala:331)
 #      at org.apache.spark.sql.SQLContext.sql(SQLContext.scala:817)
 #      at sun.reflect.GeneratedMethodAccessor44.invoke(Unknown Source)
 #      at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
 #      at java.lang.reflect.Method.invoke(Method
my_db <- NULL; gc() # disconnect
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 535309 28.6     940480 50.3   940480 50.3
 #  Vcells 792015  6.1    1650153 12.6  1016102  7.8
```

``` r
rm(list=ls())
gc()
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 534667 28.6     940480 50.3   940480 50.3
 #  Vcells 792538  6.1    1650153 12.6  1016102  7.8
```
