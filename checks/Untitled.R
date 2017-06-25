
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github("tidyverse/dbplyr")
# devtools::install_github("rstudio/sparklyr")
# See also: https://github.com/rstudio/sparklyr/issues/721
suppressPackageStartupMessages(library("dplyr"))

devtools::session_info()

# Session info ---------------------------------------------------------------------------------------------------------------------------------------
#  setting  value
#  version  R version 3.4.0 (2017-04-21)
#  system   x86_64, darwin15.6.0
#  ui       RStudio (1.0.143)
#  language (EN)
#  collate  en_US.UTF-8
#  tz       America/Los_Angeles
#  date     2017-06-25
#
# Packages -------------------------------------------------------------------------------------------------------------------------------------------
#  package    * version    date       source
#  assertthat   0.2.0      2017-04-11 CRAN (R 3.4.0)
#  backports    1.1.0      2017-05-22 CRAN (R 3.4.0)
#  base       * 3.4.0      2017-04-21 local
#  base64enc    0.1-3      2015-07-28 CRAN (R 3.4.0)
#  bindr        0.1        2016-11-13 cran (@0.1)
#  bindrcpp     0.2        2017-06-17 CRAN (R 3.4.0)
#  broom        0.4.2      2017-02-13 CRAN (R 3.4.0)
#  compiler     3.4.0      2017-04-21 local
#  curl         2.6        2017-04-27 CRAN (R 3.4.0)
#  datasets   * 3.4.0      2017-04-21 local
#  DBI          0.7        2017-06-18 CRAN (R 3.4.0)
#  dbplyr       1.0.0.9000 2017-06-25 Github (tidyverse/dbplyr@59875c3)
#  devtools     1.13.2     2017-06-02 CRAN (R 3.4.0)
#  digest       0.6.12     2017-01-27 CRAN (R 3.4.0)
#  dplyr        0.7.1.9000 2017-06-24 Github (tidyverse/dplyr@4bb35fb)
#  foreign      0.8-69     2017-06-21 CRAN (R 3.4.0)
#  git2r        0.18.0     2017-01-01 CRAN (R 3.4.0)
#  glue         1.1.1      2017-06-21 CRAN (R 3.4.0)
#  graphics   * 3.4.0      2017-04-21 local
#  grDevices  * 3.4.0      2017-04-21 local
#  grid         3.4.0      2017-04-21 local
#  htmltools    0.3.6      2017-04-28 CRAN (R 3.4.0)
#  httpuv       1.3.3      2015-08-04 CRAN (R 3.4.0)
#  httr         1.2.1      2016-07-03 CRAN (R 3.4.0)
#  jsonlite     1.5        2017-06-01 CRAN (R 3.4.0)
#  knitr        1.16       2017-05-18 CRAN (R 3.4.0)
#  lattice      0.20-35    2017-03-25 CRAN (R 3.4.0)
#  lazyeval     0.2.0      2016-06-12 CRAN (R 3.4.0)
#  magrittr     1.5        2014-11-22 CRAN (R 3.4.0)
#  memoise      1.1.0      2017-04-21 CRAN (R 3.4.0)
#  methods    * 3.4.0      2017-04-21 local
#  mime         0.5        2016-07-07 CRAN (R 3.4.0)
#  mnormt       1.5-5      2016-10-15 CRAN (R 3.4.0)
#  nlme         3.1-131    2017-02-06 CRAN (R 3.4.0)
#  parallel     3.4.0      2017-04-21 local
#  pkgconfig    2.0.1      2017-03-21 cran (@2.0.1)
#  plyr         1.8.4      2016-06-08 CRAN (R 3.4.0)
#  psych        1.7.5      2017-05-03 CRAN (R 3.4.0)
#  R6           2.2.2      2017-06-17 CRAN (R 3.4.0)
#  Rcpp         0.12.11    2017-05-22 CRAN (R 3.4.0)
#  reshape2     1.4.2      2016-10-22 CRAN (R 3.4.0)
#  rlang        0.1.1.9000 2017-06-22 Github (tidyverse/rlang@a97e7fa)
#  rprojroot    1.2        2017-01-16 CRAN (R 3.4.0)
#  rstudioapi   0.6        2016-06-27 CRAN (R 3.4.0)
#  shiny        1.0.3      2017-04-26 CRAN (R 3.4.0)
#  sparklyr     0.5.6-9004 2017-06-25 Github (rstudio/sparklyr@faaeb68)
#  stats      * 3.4.0      2017-04-21 local
#  stringi      1.1.5      2017-04-07 CRAN (R 3.4.0)
#  stringr      1.2.0      2017-02-18 CRAN (R 3.4.0)
#  tibble       1.3.3      2017-05-28 CRAN (R 3.4.0)
#  tidyr        0.6.3      2017-05-15 CRAN (R 3.4.0)
#  tools        3.4.0      2017-04-21 local
#  utils      * 3.4.0      2017-04-21 local
#  withr        1.0.2      2016-06-20 CRAN (R 3.4.0)
#  xtable       1.8-2      2016-02-05 CRAN (R 3.4.0)

sc <- sparklyr::spark_connect(version='2.0.2',
                              master = "local")
print(sc)


# $master
# [1] "local[4]"
#
# $method
# [1] "shell"
#
# $app_name
# [1] "sparklyr"
#
# $config
# $config$sparklyr.cores.local
# [1] 4
#
# $config$spark.sql.shuffle.partitions.local
# [1] 4
#
# $config$spark.env.SPARK_LOCAL_IP.local
# [1] "127.0.0.1"
#
# $config$sparklyr.csv.embedded
# [1] "^1.*"
#
# $config$`sparklyr.shell.driver-class-path`
# [1] ""
#
# attr(,"config")
# [1] "default"
# attr(,"file")
# [1] "/Library/Frameworks/R.framework/Versions/3.4/Resources/library/sparklyr/conf/config-template.yml"
#
# $spark_home
# [1] "/Users/johnmount/Library/Caches/spark/spark-2.0.2-bin-hadoop2.7"
#
# $backend
# A connection with
# description "->localhost:49632"
# class       "sockconn"
# mode        "wb"
# text        "binary"
# opened      "opened"
# can read    "yes"
# can write   "yes"
#
# $monitor
# A connection with
# description "->localhost:8880"
# class       "sockconn"
# mode        "rb"
# text        "binary"
# opened      "opened"
# can read    "yes"
# can write   "yes"
#
# $output_file
# [1] "/var/folders/7q/h_jp2vj131g5799gfnpzhdp80000gn/T//Rtmp3oin5Z/file5f5591c5712_spark.log"
#
# $spark_context
# <jobj[6]>
#   class org.apache.spark.SparkContext
#   org.apache.spark.SparkContext@284b61f2
#
# $java_context
# <jobj[7]>
#   class org.apache.spark.api.java.JavaSparkContext
#   org.apache.spark.api.java.JavaSparkContext@45f23727
#
# attr(,"class")
# [1] "spark_connection"       "spark_shell_connection" "DBIConnection"



#' Compute union_all of tables.  Cut down from \code{replyr::replyr_union_all()} for debugging.
#'
#' @param sc remote data source tables are on (and where to copy-to and work), NULL for local tables.
#' @param tabA not-NULL table with at least 1 row on sc data source, and columns \code{c("car", "fact", "value")}.
#' @param tabB not-NULL table with at least 1 row on same data source as tabA and columns \code{c("car", "fact", "value")}.
#' @return table with all rows of tabA and tabB (union_all).
#'
#' @export
example_union_all <- function(sc, tabA, tabB) {
  cols <- intersect(colnames(tabA), colnames(tabB))
  expectedCols <- c("car", "fact", "value")
  if((length(cols)!=length(expectedCols)) ||
     (!all.equal(cols, expectedCols))) {
    stop(paste("example_union_all: column set must be exactly",
               paste(expectedCols, collapse = ', ')))
  }
  mergeColName <- 'exampleunioncol'
  # build a 2-row table to control the union
  controlTable <- data.frame(exampleunioncol= c('a', 'b'),
                             stringsAsFactors = FALSE)
  if(!is.null(sc)) {
    controlTable <- copy_to(sc, controlTable,
                            temporary=TRUE)
  }
  # decorate left and right tables for the merge
  tabA <- tabA %>%
    select(one_of(cols)) %>%
    mutate(exampleunioncol = as.character('a'))
  tabB <- tabB %>%
    select(one_of(cols)) %>%
    mutate(exampleunioncol = as.character('b'))
  # do the merges
  joined <- controlTable %>%
    left_join(tabA, by=mergeColName) %>%
    left_join(tabB, by=mergeColName, suffix = c('_a', '_b'))
  # coalesce the values
  joined <- joined %>%
    mutate(car = ifelse(exampleunioncol=='a', car_a, car_b))
  joined <- joined %>%
    mutate(fact = ifelse(exampleunioncol=='a', fact_a, fact_b))
  joined <- joined %>%
    mutate(value = ifelse(exampleunioncol=='a', value_a, value_b))
  joined %>%
    select(one_of(cols))
}


mtcars2 <- mtcars %>%
  mutate(car = row.names(mtcars))

frameList <- mtcars2 %>%
  tidyr::gather(key='fact', value='value', -car) %>%
  split(., .$fact)

frameListS <- lapply(names(frameList),
                     function(ni) {
                       copy_to(sc, frameList[[ni]], ni)
                     }
)

count <- 1
for(rep in 1:20) {
  print(paste('start rep', rep, base::date()))
  nm <- paste('tmp', count, sep='_')
  count <- count + 1
  res <- compute(frameListS[[1]], name=nm)
  for(i in (2:length(frameListS))) {
    print(paste(' start phase', rep, i, base::date()))
    oi <- frameListS[[i]]
    res <- example_union_all(sc, res, oi)
    prevNM <- nm
    nm <- paste('tmp', count, sep='_')
    count <- count + 1
    res <- compute(res, name=nm)
    dplyr::db_drop_table(sc, prevNM)
    print(paste(' done phase', rep, i, base::date()))
  }
  print(head(res))
  dplyr::db_drop_table(sc, nm)
  print(paste('done rep', rep, base::date()))
}

# Code above should have no resource leaks (the db_drop_tables should match the computes).
# It is only building a final table of 352 rows (essentially binding rows on a remote source).

# Hard-locked Spark cluster on rep 10 step 9 or so (so may need more reps!).

# HTTP ERROR 500
#
# Problem accessing /jobs/. Reason:
#
#     Server Error
# Caused by:
#
# java.lang.OutOfMemoryError: GC overhead limit exceeded
# 	at java.util.Arrays.copyOfRange(Arrays.java:3664)
# 	at java.lang.String.<init>(String.java:207)
# 	at java.lang.StringBuilder.toString(StringBuilder.java:407)
# 	at java.net.URLStreamHandler.parseURL(URLStreamHandler.java:249)
# 	at sun.net.www.protocol.file.Handler.parseURL(Handler.java:67)
# 	at java.net.URL.<init>(URL.java:615)
# 	at java.net.URL.<init>(URL.java:483)
# 	at sun.misc.URLClassPath$FileLoader.getResource(URLClassPath.java:1222)
# 	at sun.misc.URLClassPath$FileLoader.findResource(URLClassPath.java:1212)
# 	at sun.misc.URLClassPath.findResource(URLClassPath.java:188)
# 	at java.net.URLClassLoader$2.run(URLClassLoader.java:569)
# 	at java.net.URLClassLoader$2.run(URLClassLoader.java:567)
# 	at java.security.AccessController.doPrivileged(Native Method)
# 	at java.net.URLClassLoader.findResource(URLClassLoader.java:566)
# 	at java.lang.ClassLoader.getResource(ClassLoader.java:1093)
# 	at java.lang.ClassLoader.getResource(ClassLoader.java:1088)
# 	at java.net.URLClassLoader.getResourceAsStream(URLClassLoader.java:232)
# 	at org.apache.xerces.parsers.SecuritySupport$6.run(Unknown Source)
# 	at java.security.AccessController.doPrivileged(Native Method)
# 	at org.apache.xerces.parsers.SecuritySupport.getResourceAsStream(Unknown Source)
# 	at org.apache.xerces.parsers.ObjectFactory.findJarServiceProvider(Unknown Source)
# 	at org.apache.xerces.parsers.ObjectFactory.createObject(Unknown Source)
# 	at org.apache.xerces.parsers.ObjectFactory.createObject(Unknown Source)
# 	at org.apache.xerces.parsers.SAXParser.<init>(Unknown Source)
# 	at org.apache.xerces.parsers.SAXParser.<init>(Unknown Source)
# 	at org.apache.xerces.jaxp.SAXParserImpl$JAXPSAXParser.<init>(Unknown Source)
# 	at org.apache.xerces.jaxp.SAXParserImpl.<init>(Unknown Source)
# 	at org.apache.xerces.jaxp.SAXParserFactoryImpl.newSAXParser(Unknown Source)
# 	at scala.xml.factory.XMLLoader$class.parser(XMLLoader.scala:30)
# 	at scala.xml.XML$.parser(XML.scala:60)
# 	at scala.xml.factory.XMLLoader$class.loadString(XMLLoader.scala:60)
# 	at scala.xml.XML$.loadString(XML.scala:60)
# Powered by Jetty://

