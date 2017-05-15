<!-- Generated from .Rmd. Please edit that file -->
`dplyr` and `sparklyr`
----------------------

Run DEV version of `dplyr` and DEV `sparklyr` as of 5-14-2017.

``` r
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github('tidyverse/dbplyr')
# devtools::install_github('rstudio/sparklyr')
suppressPackageStartupMessages(library('dplyr'))
packageVersion("dplyr")
```

    ## [1] '0.5.0.9005'

``` r
library('sparklyr')
packageVersion("sparklyr")
```

    ## [1] '0.5.4.9002'

``` r
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
```

    ## [1] '0.0.0.9001'

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

``` r
base::date()
```

    ## [1] "Mon May 15 14:54:51 2017"

``` r
sc <- sparklyr::spark_connect(version='2.0.2', 
   master = "local")
```

``` r
d1 <- copy_to(sc, data.frame(x=1:3, y=4:6), 'd1',
              overwrite = TRUE)
d2 <- copy_to(sc, data.frame(x=1:3, y=7:9), 'd2',
              overwrite = TRUE)

left_join(d1, d2, by='x')
```

    ## Source:     lazy query [?? x 3]
    ## Database:   spark_connection

    ## Error: org.apache.spark.sql.catalyst.parser.ParseException: 
    ## extraneous input '.' expecting {<EOF>, ',', 'FROM', 'WHERE', 'GROUP', 'ORDER', 'HAVING', 'LIMIT', 'LATERAL', 'WINDOW', 'UNION', 'EXCEPT', 'INTERSECT', 'SORT', 'CLUSTER', 'DISTRIBUTE'}(line 1, pos 77)
    ## 
    ## == SQL ==
    ## SELECT `TBL_LEFT`.`x` AS `x`, `TBL_LEFT`.`y` AS `y.x`, `TBL_RIGHT`.`y` AS `y`.`y`
    ## -----------------------------------------------------------------------------^^^
    ##   FROM `d1` AS `TBL_LEFT`
    ##   LEFT JOIN `d2` AS `TBL_RIGHT`
    ##   ON (`TBL_LEFT`.`x` = `TBL_RIGHT`.`x`)
    ## 
    ##  at org.apache.spark.sql.catalyst.parser.ParseException.withCommand(ParseDriver.scala:197)
    ##  at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parse(ParseDriver.scala:99)
    ##  at org.apache.spark.sql.execution.SparkSqlParser.parse(SparkSqlParser.scala:45)
    ##  at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parsePlan(ParseDriver.scala:53)
    ##  at org.apache.spark.sql.SparkSession.sql(SparkSession.scala:582)
    ##  at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
    ##  at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
    ##  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    ##  at java.lang.reflect.Method.invoke(Method.java:497)
    ##  at sparklyr.Invoke$.invoke(invoke.scala:96)
    ##  at sparklyr.StreamHandler$.handleMethodCall(stream.scala:89)
    ##  at sparklyr.StreamHandler$.read(stream.scala:55)
    ##  at sparklyr.BackendHandler.channelRead0(handler.scala:49)
    ##  at sparklyr.BackendHandler.channelRead0(handler.scala:14)
    ##  at io.netty.channel.SimpleChannelInboundHandler.channelRead(SimpleChannelInboundHandler.java:105)
    ##  at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:308)
    ##  at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:294)
    ##  at io.netty.handler.codec.MessageToMessageDecoder.channelRead(MessageToMessageDecoder.java:103)
    ##  at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:308)
    ##  at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:294)
    ##  at io.netty.handler.codec.ByteToMessageDecoder.channelRead(ByteToMessageDecoder.java:244)
    ##  at io.netty.channel.AbstractChannelHandlerContext.invokeChannelRead(AbstractChannelHandlerContext.java:308)
    ##  at io.netty.channel.AbstractChannelHandlerContext.fireChannelRead(AbstractChannelHandlerContext.java:294)
    ##  at io.netty.channel.DefaultChannelPipeline.fireChannelRead(DefaultChannelPipeline.java:846)
    ##  at io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:131)
    ##  at io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:511)
    ##  at io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:468)
    ##  at io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:382)
    ##  at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:354)
    ##  at io.netty.util.concurrent.SingleThreadEventExecutor$2.run(SingleThreadEventExecutor.java:111)
    ##  at io.netty.util.concurrent.DefaultThreadFactory$DefaultRunnableDecorator.run(DefaultThreadFactory.java:137)
    ##  at java.lang.Thread.run(Thread.java:745)

``` r
dLocal <- data.frame(x = 1:2,
                     origCol = c('a', 'b'),
                     stringsAsFactors = FALSE)

d <- copy_to(sc, dLocal, 'd',
             overwrite = TRUE)

# local
rename(dLocal, x2 = x, origCol2 = origCol)
```

    ##   x2 origCol2
    ## 1  1        a
    ## 2  2        b

``` r
# Spark
rename(d, x2 = x, origCol2 = origCol)
```

    ## Source:     lazy query [?? x 2]
    ## Database:   spark_connection

    ## Error in names(select)[match(old_vars, vars)] <- new_vars: NAs are not allowed in subscripted assignments

``` r
spark_disconnect(sc)
rm(list=ls())
gc(verbose = FALSE)
```

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  702646 37.6    1168576 62.5  1168576 62.5
    ## Vcells 1193190  9.2    2060183 15.8  1473196 11.3
