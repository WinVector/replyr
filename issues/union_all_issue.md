`union_all` issue with `SQLite`. Submitted as [dplyr issue 2270](https://github.com/hadley/dplyr/issues/2270).

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
packageVersion('dplyr')
 #  [1] '0.5.0'
my_db <- dplyr::src_sqlite("replyr_sqliteEx.sqlite3", create = TRUE)
dr <- dplyr::copy_to(my_db,
                     data.frame(x=c(1,2),y=c('a','b'),stringsAsFactors = FALSE),'dr',
                     overwrite=TRUE)
dr <- head(dr,1)
# dr <- compute(dr)
print(dr)
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  
 #        x     y
 #    <dbl> <chr>
 #  1     1     a
print(dplyr::union_all(dr,dr))
 #  Source:   query [?? x 2]
 #  Database: sqlite 3.8.6 [replyr_sqliteEx.sqlite3]
 #  Error in sqliteSendQuery(conn, statement): error in statement: LIMIT clause should come after UNION ALL not before
```

``` r
rm(list=ls())
gc()
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 456066 24.4     750400 40.1   592000 31.7
 #  Vcells 648174  5.0    1308461 10.0   882972  6.8
```

Note calling `compute` doesn't always fix the problem in my more complicated production example. Also `union` seems to not have the same issue as `union_all`. It also seems like nested function calls exhebriate the issue, perhaps a reference to a necissary structure goes out of scope and allows sub-table collection too soon? To trigger the full error in `replyr` force use of `union_all` in `replyr_bind_rows` and then try knitting `basicChecksSpark200.Rmd`.

``` r
library('dplyr')
library('sparklyr')
packageVersion('dplyr')
 #  [1] '0.5.0'
packageVersion('sparklyr')
 #  [1] '0.4.26'
my_db <- sparklyr::spark_connect(version='2.0.0', 
   master = "local")
class(my_db)
 #  [1] "spark_connection"       "spark_shell_connection" "DBIConnection"
my_db$spark_home
 #  [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.0-bin-hadoop2.7"
da <- dplyr::copy_to(my_db,
                     data.frame(x=c(1,2),y=c('a','b'),stringsAsFactors = FALSE),'dr',
                     overwrite=TRUE)
da <- head(da,1)
db <- dplyr::copy_to(my_db,
                     data.frame(x=c(3,4),y=c('c','d'),stringsAsFactors = FALSE),'dr',
                     overwrite=TRUE)
db <- head(db,1)
#da <- compute(da)
db <- compute(db)
res <- dplyr::union_all(da,db)
res <- dplyr::compute(res)
 #  Error: org.apache.spark.sql.catalyst.parser.ParseException: 
 #  mismatched input 'FROM' expecting {<EOF>, 'WHERE', 'GROUP', 'ORDER', 'HAVING', 'LIMIT', 'LATERAL', 'WINDOW', 'UNION', 'EXCEPT', 'INTERSECT', 'SORT', 'CLUSTER', 'DISTRIBUTE'}(line 2, pos 0)
 #  
 #  == SQL ==
 #  SELECT `x` AS `x`, `y` AS `y`
 #  FROM (SELECT *
 #  ^^^
 #  FROM (SELECT *
 #  FROM `dr`) `vpwtolrnus`
 #  LIMIT 1
 #  UNION ALL
 #  SELECT *
 #  FROM `jubjxmvcjo`) `jmkborjaqk`
 #  
 #      at org.apache.spark.sql.catalyst.parser.ParseException.withCommand(ParseDriver.scala:197)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parse(ParseDriver.scala:99)
 #      at org.apache.spark.sql.execution.SparkSqlParser.parse(SparkSqlParser.scala:46)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parsePlan(ParseDriver.scala:53)
 #      at org.apache.spark.sql.SparkSession.sql(SparkSession.scala:582)
 #      at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
 #      at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
 #      at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
 #      at java.lang.reflect.Method.invoke(Method.java:497)
 #      at sparklyr.Handler.handleMethodCall(handler.scala:124)
 #      at sparklyr.Handler.channelRead0(handler.scala:69)
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
print(res)
 #  Source:   query [?? x 2]
 #  Database: spark connection master=local[4] app=sparklyr local=TRUE
 #  Error: org.apache.spark.sql.catalyst.parser.ParseException: 
 #  mismatched input 'FROM' expecting {<EOF>, 'WHERE', 'GROUP', 'ORDER', 'HAVING', 'LIMIT', 'LATERAL', 'WINDOW', 'UNION', 'EXCEPT', 'INTERSECT', 'SORT', 'CLUSTER', 'DISTRIBUTE'}(line 2, pos 0)
 #  
 #  == SQL ==
 #  SELECT *
 #  FROM (SELECT *
 #  ^^^
 #  FROM (SELECT *
 #  FROM `dr`) `urdjffrbxd`
 #  LIMIT 1
 #  UNION ALL
 #  SELECT *
 #  FROM `jubjxmvcjo`) `eyrpbffyjd`
 #  LIMIT 10
 #  
 #      at org.apache.spark.sql.catalyst.parser.ParseException.withCommand(ParseDriver.scala:197)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parse(ParseDriver.scala:99)
 #      at org.apache.spark.sql.execution.SparkSqlParser.parse(SparkSqlParser.scala:46)
 #      at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parsePlan(ParseDriver.scala:53)
 #      at org.apache.spark.sql.SparkSession.sql(SparkSession.scala:582)
 #      at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
 #      at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
 #      at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
 #      at java.lang.reflect.Method.invoke(Method.java:497)
 #      at sparklyr.Handler.handleMethodCall(handler.scala:124)
 #      at sparklyr.Handler.channelRead0(handler.scala:69)
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

``` r
rm(list=ls())
gc()
 #           used (Mb) gc trigger (Mb) max used (Mb)
 #  Ncells 527156 28.2     940480 50.3   750400 40.1
 #  Vcells 713789  5.5    1308461 10.0  1027150  7.9
```

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
