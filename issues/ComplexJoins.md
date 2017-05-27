<!-- Generated from .Rmd. Please edit that file -->
Check complex join results.

``` r
suppressPackageStartupMessages(library('dplyr'))

runJoinExperiment <- function(prefix, sc, eagerCompute, uniqueColumns) {
  names <- paste('t', prefix, 1:10, sep= '_')
  joined <- NULL
  for(ni in names) {
    di <- data.frame(k= 1:3, 
                     v= paste(ni, 1:3, sep= '_'))
    if(uniqueColumns) {
      colnames(di)[[2]] <- paste('y', ni, sep= '_')
    }
    if(!is.null(sc)) {
      ti <- copy_to(sc, di, ni)
    } else {
      ti <- di
    }
    if('NULL' %in% class(joined)) {
      joined <- ti
    } else {
      joined <- left_join(joined, ti, by= 'k')
      if(eagerCompute) {
        joined <- compute(joined)
      }
    }
  }
  compute(joined)
}

# works as expected
runJoinExperiment('inmem', NULL, FALSE, FALSE)
```

    ##   k         v.x         v.y       v.x.x       v.y.y     v.x.x.x
    ## 1 1 t_inmem_1_1 t_inmem_2_1 t_inmem_3_1 t_inmem_4_1 t_inmem_5_1
    ## 2 2 t_inmem_1_2 t_inmem_2_2 t_inmem_3_2 t_inmem_4_2 t_inmem_5_2
    ## 3 3 t_inmem_1_3 t_inmem_2_3 t_inmem_3_3 t_inmem_4_3 t_inmem_5_3
    ##       v.y.y.y   v.x.x.x.x   v.y.y.y.y v.x.x.x.x.x  v.y.y.y.y.y
    ## 1 t_inmem_6_1 t_inmem_7_1 t_inmem_8_1 t_inmem_9_1 t_inmem_10_1
    ## 2 t_inmem_6_2 t_inmem_7_2 t_inmem_8_2 t_inmem_9_2 t_inmem_10_2
    ## 3 t_inmem_6_3 t_inmem_7_3 t_inmem_8_3 t_inmem_9_3 t_inmem_10_3

Using `RSQLite` through `dplyr` loses columns. This has been submitted as [RSQLite issue 214](https://github.com/rstats-db/RSQLite/issues/214) and [dplyr issue 2823](https://github.com/tidyverse/dplyr/issues/2823).

``` r
sc <- src_sqlite(":memory:", create = TRUE)

# throws
tryCatch(
  runJoinExperiment('sqlitea', sc, FALSE, FALSE),
  error = function(e) print(e)
)
```

    ## <Rcpp::exception in rsqlite_send_query(conn@ptr, statement): parser stack overflow>

``` r
# incorrect result (missing columns)
runJoinExperiment('sqliteb', sc, TRUE, FALSE)
```

    ## Source:   query [?? x 3]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 3
    ##       k           v.x           v.y
    ##   <int>         <chr>         <chr>
    ## 1     1 t_sqliteb_1_1 t_sqliteb_2_1
    ## 2     2 t_sqliteb_1_2 t_sqliteb_2_2
    ## 3     3 t_sqliteb_1_3 t_sqliteb_2_3

Using `Spark` through `sparklyr`/`dplyr` doesn't disambiguate columns as the local process does.

``` r
sc <- sparklyr::spark_connect(version='2.0.2', 
   master = "local")
```

``` r
# throws
tryCatch(
  runJoinExperiment('sparka', sc, FALSE, FALSE),
  error = function(e) print(e)
)
```

    ## <simpleError: org.apache.spark.sql.AnalysisException: Reference '`v.x`' is ambiguous, could be: v.x#935, v.x#937.; line 4 pos 55
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolve(LogicalPlan.scala:264)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveChildren(LogicalPlan.scala:148)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5$$anonfun$31.apply(Analyzer.scala:609)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5$$anonfun$31.apply(Analyzer.scala:609)
    ##  at org.apache.spark.sql.catalyst.analysis.package$.withPosition(package.scala:48)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5.applyOrElse(Analyzer.scala:609)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5.applyOrElse(Analyzer.scala:605)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$transformUp$1.apply(TreeNode.scala:308)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$transformUp$1.apply(TreeNode.scala:308)
    ##  at org.apache.spark.sql.catalyst.trees.CurrentOrigin$.withOrigin(TreeNode.scala:69)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformUp(TreeNode.scala:307)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$4.apply(TreeNode.scala:305)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$4.apply(TreeNode.scala:305)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformUp(TreeNode.scala:305)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.transformExpressionUp$1(QueryPlan.scala:269)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.org$apache$spark$sql$catalyst$plans$QueryPlan$$recursiveTransform$2(QueryPlan.scala:279)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan$$anonfun$org$apache$spark$sql$catalyst$plans$QueryPlan$$recursiveTransform$2$1.apply(QueryPlan.scala:283)
    ##  at scala.collection.TraversableLike$$anonfun$map$1.apply(TraversableLike.scala:234)
    ##  at scala.collection.TraversableLike$$anonfun$map$1.apply(TraversableLike.scala:234)
    ##  at scala.collection.immutable.List.foreach(List.scala:381)
    ##  at scala.collection.TraversableLike$class.map(TraversableLike.scala:234)
    ##  at scala.collection.immutable.List.map(List.scala:285)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.org$apache$spark$sql$catalyst$plans$QueryPlan$$recursiveTransform$2(QueryPlan.scala:283)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan$$anonfun$8.apply(QueryPlan.scala:288)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.transformExpressionsUp(QueryPlan.scala:288)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9.applyOrElse(Analyzer.scala:605)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9.applyOrElse(Analyzer.scala:547)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$resolveOperators$2.apply(LogicalPlan.scala:65)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$resolveOperators$2.apply(LogicalPlan.scala:65)
    ##  at org.apache.spark.sql.catalyst.trees.CurrentOrigin$.withOrigin(TreeNode.scala:69)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:64)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$1.apply(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:58)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$>

``` r
# throws
tryCatch(
  runJoinExperiment('sparkb', sc, TRUE, FALSE),
   error = function(e) print(e)
)
```

    ## <simpleError: org.apache.spark.sql.AnalysisException: Reference '`v.x`' is ambiguous, could be: v.x#1424, v.x#1426.; line 1 pos 19
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolve(LogicalPlan.scala:264)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveChildren(LogicalPlan.scala:148)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5$$anonfun$31.apply(Analyzer.scala:609)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5$$anonfun$31.apply(Analyzer.scala:609)
    ##  at org.apache.spark.sql.catalyst.analysis.package$.withPosition(package.scala:48)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5.applyOrElse(Analyzer.scala:609)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9$$anonfun$applyOrElse$5.applyOrElse(Analyzer.scala:605)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$transformUp$1.apply(TreeNode.scala:308)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$transformUp$1.apply(TreeNode.scala:308)
    ##  at org.apache.spark.sql.catalyst.trees.CurrentOrigin$.withOrigin(TreeNode.scala:69)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformUp(TreeNode.scala:307)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$4.apply(TreeNode.scala:305)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$4.apply(TreeNode.scala:305)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode$$anonfun$5.apply(TreeNode.scala:328)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformChildren(TreeNode.scala:326)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.transformUp(TreeNode.scala:305)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.transformExpressionUp$1(QueryPlan.scala:269)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.org$apache$spark$sql$catalyst$plans$QueryPlan$$recursiveTransform$2(QueryPlan.scala:279)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan$$anonfun$org$apache$spark$sql$catalyst$plans$QueryPlan$$recursiveTransform$2$1.apply(QueryPlan.scala:283)
    ##  at scala.collection.TraversableLike$$anonfun$map$1.apply(TraversableLike.scala:234)
    ##  at scala.collection.TraversableLike$$anonfun$map$1.apply(TraversableLike.scala:234)
    ##  at scala.collection.immutable.List.foreach(List.scala:381)
    ##  at scala.collection.TraversableLike$class.map(TraversableLike.scala:234)
    ##  at scala.collection.immutable.List.map(List.scala:285)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.org$apache$spark$sql$catalyst$plans$QueryPlan$$recursiveTransform$2(QueryPlan.scala:283)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan$$anonfun$8.apply(QueryPlan.scala:288)
    ##  at org.apache.spark.sql.catalyst.trees.TreeNode.mapProductIterator(TreeNode.scala:186)
    ##  at org.apache.spark.sql.catalyst.plans.QueryPlan.transformExpressionsUp(QueryPlan.scala:288)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9.applyOrElse(Analyzer.scala:605)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$$anonfun$apply$9.applyOrElse(Analyzer.scala:547)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$resolveOperators$2.apply(LogicalPlan.scala:65)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan$$anonfun$resolveOperators$2.apply(LogicalPlan.scala:65)
    ##  at org.apache.spark.sql.catalyst.trees.CurrentOrigin$.withOrigin(TreeNode.scala:69)
    ##  at org.apache.spark.sql.catalyst.plans.logical.LogicalPlan.resolveOperators(LogicalPlan.scala:64)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$.apply(Analyzer.scala:547)
    ##  at org.apache.spark.sql.catalyst.analysis.Analyzer$ResolveReferences$.apply(Analyzer.scala:484)
    ##  at org.apache.spark.sql.catalyst.rules.RuleExecutor$$anonfun$execute$1$$anonfun$apply$1.apply(RuleExecutor.scala:85)
    ##  at org.apache.spark.sql.catalyst.rules.RuleExecutor$$anonfun$execute$1$$anonfun$apply$1.apply(RuleExecutor.scala:82)
    ##  at scala.collection.LinearSeqOptimized$class.foldLeft(LinearSeqOptimized.scala:124)
    ##  at scala.collection.immutable.List.foldLeft(List.scala:84)
    ##  at org.apache.spark.sql.catalyst.rules.RuleExecutor$$anonfun$execute$1.apply(RuleExecutor.scala:82)
    ##  at org.apache.spark.sql.catalyst.rules.RuleExecutor$$anonfun$execute$1.apply(RuleExecutor.scala:74)
    ##  at scala.collection.immutable.List.foreach(List.scala:381)
    ##  at org.apache.spark.sql.catalyst.rules.RuleExecutor.execute(RuleExecutor.scala:74)
    ##  at org.apache.spark.sql.execution.QueryExecution.analyzed$lzycompute(QueryExecution.scala:65)
    ##  at org.apache.spark.sql.execution.QueryExecution.analyzed(QueryExecution.scala:63)
    ##  at org.apache.spark.sql.execution.QueryExecution.assertAnalyzed(QueryExecution.scala:51)
    ##  at org.apache.spark.sql.Dataset$.ofRows(Dataset.scala:64)
    ##  at org.apache.spark.sql.SparkSession.sql(SparkSession.scala:582)
    ##  at sun.reflect.GeneratedMethodAccessor32.invoke(Unknown Source)
    ##  at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
    ##  at java.lang.reflect.Method.invoke(Method.java:497)
    ##  at sparklyr.Invoke$.invoke(invoke.scala:94)
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
    ## >

We can try this again with unambiguous columns, which works. I am assuming that this is [dplyr issue 2773](https://github.com/tidyverse/dplyr/issues/2774), [sparklyr issue 677](https://github.com/rstudio/sparklyr/issues/677).

``` r
# throws
runJoinExperiment('spark2a', sc, FALSE, TRUE)
```

    ## Source:   query [3 x 11]
    ## Database: spark connection master=local[4] app=sparklyr local=TRUE
    ## 
    ## # A tibble: 3 x 11
    ##       k y_t_spark2a_1 y_t_spark2a_2 y_t_spark2a_3 y_t_spark2a_4
    ##   <int>         <chr>         <chr>         <chr>         <chr>
    ## 1     1 t_spark2a_1_1 t_spark2a_2_1 t_spark2a_3_1 t_spark2a_4_1
    ## 2     2 t_spark2a_1_2 t_spark2a_2_2 t_spark2a_3_2 t_spark2a_4_2
    ## 3     3 t_spark2a_1_3 t_spark2a_2_3 t_spark2a_3_3 t_spark2a_4_3
    ## # ... with 6 more variables: y_t_spark2a_5 <chr>, y_t_spark2a_6 <chr>,
    ## #   y_t_spark2a_7 <chr>, y_t_spark2a_8 <chr>, y_t_spark2a_9 <chr>,
    ## #   y_t_spark2a_10 <chr>

``` r
runJoinExperiment('spark2b', sc, TRUE, TRUE)
```

    ## Source:   query [3 x 11]
    ## Database: spark connection master=local[4] app=sparklyr local=TRUE
    ## 
    ## # A tibble: 3 x 11
    ##       k y_t_spark2b_1 y_t_spark2b_2 y_t_spark2b_3 y_t_spark2b_4
    ##   <int>         <chr>         <chr>         <chr>         <chr>
    ## 1     1 t_spark2b_1_1 t_spark2b_2_1 t_spark2b_3_1 t_spark2b_4_1
    ## 2     2 t_spark2b_1_2 t_spark2b_2_2 t_spark2b_3_2 t_spark2b_4_2
    ## 3     3 t_spark2b_1_3 t_spark2b_2_3 t_spark2b_3_3 t_spark2b_4_3
    ## # ... with 6 more variables: y_t_spark2b_5 <chr>, y_t_spark2b_6 <chr>,
    ## #   y_t_spark2b_7 <chr>, y_t_spark2b_8 <chr>, y_t_spark2b_9 <chr>,
    ## #   y_t_spark2b_10 <chr>

``` r
sparklyr::spark_disconnect(sc)
```

``` r
packageVersion("dplyr")
```

    ## [1] '0.5.0'

``` r
packageVersion("sparklyr")
```

    ## [1] '0.5.4'

``` r
if(requireNamespace("dbplyr", quietly = TRUE)) {
  packageVersion("dbplyr")
}
if(requireNamespace("RSQLite", quietly = TRUE)) {
  packageVersion("RSQLite")
}
```

    ## [1] '1.1.2'

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

``` r
rm(list=ls())
gc()
```

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  704833 37.7    1168576 62.5   940480 50.3
    ## Vcells 1201826  9.2    2060183 15.8  1552517 11.9
