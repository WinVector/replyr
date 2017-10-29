split/apply/combine on Spark
================

``` r
library('dplyr')
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library('sparklyr')
library('replyr')
```

    ## Loading required package: seplyr

    ## Loading required package: wrapr

    ## Loading required package: cdata

``` r
sc <- sparklyr::spark_connect(version='2.2.0', 
                              master = "local")

d <- copy_to(sc, 
             data.frame(x=1:7, group=floor((1:7)/3)),
             name= 'd')

print(d)
```

    ## # Source:   table<d> [?? x 2]
    ## # Database: spark_connection
    ##       x group
    ##   <int> <dbl>
    ## 1     1     0
    ## 2     2     0
    ## 3     3     1
    ## 4     4     1
    ## 5     5     1
    ## 6     6     2
    ## 7     7     2

``` r
pieces <- replyr_split(d, 'group', partitionMethod = 'extract')
print(pieces)
```

    ## $`0`
    ## # Source:   table<replyr_gapply_izjfbvmvaiobp2dpesfu_0000000001> [?? x 2]
    ## # Database: spark_connection
    ##       x group
    ##   <int> <dbl>
    ## 1     1     0
    ## 2     2     0
    ## 
    ## $`1`
    ## # Source:   table<replyr_gapply_izjfbvmvaiobp2dpesfu_0000000003> [?? x 2]
    ## # Database: spark_connection
    ##       x group
    ##   <int> <dbl>
    ## 1     3     1
    ## 2     4     1
    ## 3     5     1
    ## 
    ## $`2`
    ## # Source:   table<replyr_gapply_izjfbvmvaiobp2dpesfu_0000000005> [?? x 2]
    ## # Database: spark_connection
    ##       x group
    ##   <int> <dbl>
    ## 1     6     2
    ## 2     7     2

``` r
f <- function(pi) {
  ni <- replyr_nrow(pi)
  mutate(pi, n=ni)
}

pieces <- lapply(pieces, f)
print(pieces)
```

    ## $`0`
    ## # Source:   lazy query [?? x 3]
    ## # Database: spark_connection
    ##       x group     n
    ##   <int> <dbl> <dbl>
    ## 1     1     0     2
    ## 2     2     0     2
    ## 
    ## $`1`
    ## # Source:   lazy query [?? x 3]
    ## # Database: spark_connection
    ##       x group     n
    ##   <int> <dbl> <dbl>
    ## 1     3     1     3
    ## 2     4     1     3
    ## 3     5     1     3
    ## 
    ## $`2`
    ## # Source:   lazy query [?? x 3]
    ## # Database: spark_connection
    ##       x group     n
    ##   <int> <dbl> <dbl>
    ## 1     6     2     2
    ## 2     7     2     2

``` r
recovered <- replyr_bind_rows(pieces) %>%
  arrange(x)
print(recovered)
```

    ## # Source:     table<sparklyr_tmp_1750248f0771e> [?? x 3]
    ## # Database:   spark_connection
    ## # Ordered by: x
    ##       x group     n
    ##   <int> <dbl> <dbl>
    ## 1     1     0     2
    ## 2     2     0     2
    ## 3     3     1     3
    ## 4     4     1     3
    ## 5     5     1     3
    ## 6     6     2     2
    ## 7     7     2     2

``` r
r2 <- d %>%
  gapply('group', f, partitionMethod = 'extract') %>%
  arrange(x)
print(r2)
```

    ## # Source:     table<sparklyr_tmp_17502231c77fb> [?? x 3]
    ## # Database:   spark_connection
    ## # Ordered by: x
    ##       x group     n
    ##   <int> <dbl> <dbl>
    ## 1     1     0     2
    ## 2     2     0     2
    ## 3     3     1     3
    ## 4     4     1     3
    ## 5     5     1     3
    ## 6     6     2     2
    ## 7     7     2     2

``` r
spark_disconnect(sc)
rm(list=ls()); gc() # disconnect
```

    ##           used (Mb) gc trigger (Mb) max used (Mb)
    ## Ncells  809178 43.3    1442291 77.1  1168576 62.5
    ## Vcells 1525986 11.7    2552219 19.5  1947608 14.9
