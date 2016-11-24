Copy issue with `sparklyr` 2.0.0.

<!-- Generated from .Rmd. Please edit that file -->
Below is why we re-try joins against local data without using the `copy=TRUE` feature.

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
 #  [1] '0.4'
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
 #  $config$sparklyr.defaultPackages
 #  [1] "com.databricks:spark-csv_2.11:1.3.0"    "com.amazonaws:aws-java-sdk-pom:1.10.34"
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
 #  "->localhost:49383"          "sockconn"                "wb"            "binary"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $monitor
 #          description               class                mode                text              opened 
 #  "->localhost:49384"          "sockconn"                "a+"              "text"            "opened" 
 #             can read           can write 
 #                "yes"               "yes" 
 #  
 #  $output_file
 #  [1] "/var/folders/6t/x_r4km317f3gdmnvlcwb349w0000gn/T//RtmpcdDpxr/file2974382d1e31_spark.log"
 #  
 #  $spark_context
 #  <jobj[4]>
 #    class org.apache.spark.SparkContext
 #    org.apache.spark.SparkContext@4217d224
 #  
 #  $java_context
 #  <jobj[5]>
 #    class org.apache.spark.api.java.JavaSparkContext
 #    org.apache.spark.api.java.JavaSparkContext@3903e95a
 #  
 #  $hive_context
 #  <jobj[8]>
 #    class org.apache.spark.sql.SparkSession
 #    org.apache.spark.sql.SparkSession@695089fb
 #  
 #  attr(,"class")
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
d1 <- copy_to(my_db,data.frame(x=c(1,2),y=c('a','b')),'d1')
d2 <- data.frame(y=c('a','b'),z=c(3,4))
d1 %>% dplyr::inner_join(d2,by='y',copy=TRUE)
 #  Error: org.apache.spark.sql.catalyst.parser.ParseException: 
 #  CREATE TEMPORARY TABLE is not supported yet. Please use CREATE TEMPORARY VIEW as an alternative.(line 1, pos 0)
 #  
 #  == SQL ==
 #  CREATE TEMPORARY TABLE `btpjsnuchy` (`y` TEXT, `z` REAL)
 #  ^^^
 #  
 #      at org.apache.spark.sql.execution.SparkSqlAstBuilder$$anonfun$visitCreateTable$1.apply(SparkSqlParser.scala:905)
 #      at org.apache.spark.sql.execution.SparkSqlAstBuilder$$anonfun$visitCreateTable$1.apply(SparkSqlParser.scala:901)
 #      at org.apache.spark.sql.catalyst.parser.ParserUtils$.withOrigin(ParserUtils.scala:96)
 #      at org.apache.spark.sql.execution.SparkSqlAstBuilder.visitCreateTable(SparkSqlParser.scala:901)
 #      at org.apache.spark.sql.execution.SparkSqlAstBuilder.visitCreateTable(SparkSqlParser.scala:53)
 #      at org.apache.spark.sql.catalyst.parser.SqlBaseParser$CreateTableContext.accept(SqlBaseParser.java:474)
 #      at org.antlr.v4.runtime.tree.AbstractParseTreeVisitor.visit(AbstractParseTreeVisitor.java:42)
 #      at org.apache.spark.sql.catalyst.parser.AstBuilder$$anonfun$visitSingleStatement$1.apply(AstBuilder.scala:64)
 #      at org.apache.spark.sql.catalyst.parser.AstBuilder$$anonfun$visitSingleStatement$1.apply(AstBuilder.scala:64)
 #      at org.apache.spark.sql.catalyst.parser.ParserUtils$.withOrigin(ParserUtils.scala:96)
 #      at org.apache.spark.sql.catalyst.parser.AstBuilder.visitSingleStatement(AstBuilder.scala:63)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser$$anonfun$parsePlan$1.apply(ParseDriver.scala:54)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser$$anonfun$parsePlan$1.apply(ParseDriver.scala:53)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parse(ParseDriver.scala:82)
 #      at org.apache.spark.sql.execution.SparkSqlParser.parse(SparkSqlParser.scala:46)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parsePlan(ParseDriver.scala:53)
 #      at org.apache.spark.sql.SparkSession.sql(SparkSession.scala:582)
 #      at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
 #      at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
 #      at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
 #      at java.lang.reflect.Method.invoke(Method.java:497)
 #      at sparklyr.Handler.handleMethodCall(handler.scala:118)
 #      at sparklyr.Handler.channelRead0(handler.scala:63)
 #      at sparklyr.Handler.channelRead0(handler.scala:15)
 #      at io.netty.channel.SimpleChannelInboundHandler.channelRead(SimpleChannelInboundHandler.java:105)
 #      at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:308)
 #      at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:294)
 #      at io.netty.handler.codec.MessageToMessageDecoder.channelRead(MessageToMessageDecoder.java:103)
 #      at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:308)
 #      at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:294)
 #      at io.netty.handler.codec.ByteToMessageDecoder.channelRead(ByteToMessageDecoder.java:244)
 #      at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:308)
 #      at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:294)
 #      at io.netty.channel.DefaultChannelPipeline.fireChannelRead(DefaultChannelPipeline.java:846)
 #      at io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:131)
 #      at io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:511)
 #      at io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:468)
 #      at io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:382)
 #      at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:354)
 #      at io.netty.util.concurrent.SingleThreadEventExecutor$2.run(SingleThreadEventExecutor.java:111)
 #      at io.netty.util.concurrent.DefaultThreadFactory$DefaultRunnableDecorator.run(DefaultThreadFactory.java:137)
 #      at java.lang.Thread.run(Thread.java:745)
```
