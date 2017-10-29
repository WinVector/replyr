Big Data Transforms
================
John Mount, Win-Vector LLC
10/29/2017

As part of our consulting practice [Win-Vector LLC](http://www.win-vector.com/) has been helping a few clients stand-up advanced analytics and machine learning stacks using [`R`](https://www.r-project.org/) and substantial data stores (such as relational database variants such as `PostgreSQL` or big data systems such as `Spark`).

Often we come to a point where we or a partner realize: "the design would be a whole lot easier if we could phrase it in terms of higher order data operators."

The `R` package [`DBI`](https://CRAN.R-project.org/package=DBI) gives us direct access to `SQL` and the package [`dplyr`](https://CRAN.R-project.org/package=dplyr) gives us access to a transform grammar that can either be executed or translated into `SQL`.

But, as we point out in the [`replyr`](https://winvector.github.io/replyr/) [`README`](https://cran.r-project.org/web/packages/replyr/README.html): moving from in-memory `R` to large data systems is always a bit of a shock as you lose a lot of your higher order data operators or transformations. Missing operators include:

-   union (binding by rows many data frames into a single data frame).
-   split (splitting a single data frame into many data frames).
-   pivot (moving row values into columns).
-   un-pivot (moving column values to rows).

I can repeat this. If you are an `R` user used to using one of `dplyr::bind_rows()` , `base::split()`, `tidyr::spread()`, or `tidyr::gather()`: you will find these functions do not work on remote data sources, but have replacement implementations in the `replyr` package.

For example:

``` r
library("RPostgreSQL")
```

    ## Loading required package: DBI

``` r
suppressPackageStartupMessages(library("dplyr"))
isSpark <- FALSE

# Can work with PostgreSQL
my_db <- DBI::dbConnect(dbDriver("PostgreSQL"),
                        host = 'localhost',
                        port = 5432,
                        user = 'postgres',
                        password = 'pg')
 
# # Can work with Sparklyr
# my_db <-  sparklyr::spark_connect(version='2.2.0', 
#                                   master = "local")
# isSpark <- TRUE

d <- dplyr::copy_to(my_db, data.frame(x =  c(1,5), 
                                      group = c('g1', 'g2'),
                                      stringsAsFactors = FALSE), 
                    'd')
print(d)
```

    ## # Source:   table<d> [?? x 2]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x group
    ##   <dbl> <chr>
    ## 1     1    g1
    ## 2     5    g2

``` r
# show dplyr::bind_rows() fails.
dplyr::bind_rows(list(d, d))
```

    ## Error in bind_rows_(x, .id): Argument 1 must be a data frame or a named atomic vector, not a tbl_dbi/tbl_sql/tbl_lazy/tbl

The `replyr` package supplies `R` accessible implementations of these missing operators for large data systems such as `PostgreSQL` and `Spark`.

For example:

``` r
# using the development version of replyr https://github.com/WinVector/replyr
library("replyr") 
```

    ## Loading required package: seplyr

    ## Loading required package: wrapr

    ## Loading required package: cdata

``` r
packageVersion("replyr")
```

    ## [1] '0.8.2'

``` r
# binding rows
dB <- replyr_bind_rows(list(d, d))
print(dB)
```

    ## # Source:   table<replyr_bind_rows_jke6fkxtgqc0flj6edix_0000000002> [?? x
    ## #   2]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x group
    ##   <dbl> <chr>
    ## 1     1    g1
    ## 2     5    g2
    ## 3     1    g1
    ## 4     5    g2

``` r
# splitting frames
replyr_split(dB, 'group')
```

    ## $g2
    ## # Source:   table<replyr_gapply_bogqnrfrzfi7m9amnhcz_0000000001> [?? x 2]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x group
    ##   <dbl> <chr>
    ## 1     5    g2
    ## 2     5    g2
    ## 
    ## $g1
    ## # Source:   table<replyr_gapply_bogqnrfrzfi7m9amnhcz_0000000003> [?? x 2]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x group
    ##   <dbl> <chr>
    ## 1     1    g1
    ## 2     1    g1

``` r
# pivoting
pivotControl <-  buildPivotControlTable(d, 
                                        columnToTakeKeysFrom = 'group', 
                                        columnToTakeValuesFrom = 'x',
                                        sep = '_')
dW <- moveValuesToColumnsQ(keyColumns = NULL,
                           controlTable = pivotControl,
                           tallTableName = 'd',
                           my_db = my_db, strict = FALSE) %>%
  compute(name = 'dW')
print(dW)
```

    ## # Source:   table<dW> [?? x 2]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##   group_g1 group_g2
    ##      <dbl>    <dbl>
    ## 1        1        5

``` r
# un-pivoting
unpivotControl <- buildUnPivotControlTable(nameForNewKeyColumn = 'group',
                                           nameForNewValueColumn = 'x',
                                           columnsToTakeFrom = colnames(dW))
moveValuesToRowsQ(controlTable = unpivotControl,
                  wideTableName = 'dW',
                  my_db = my_db)
```

    ## # Source:   table<mvtrq_j0vu8nto5jw38f3xmcec_0000000001> [?? x 2]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##      group     x
    ##      <chr> <dbl>
    ## 1 group_g1     1
    ## 2 group_g2     5

The point is: using the `replyr` package you *can* design in terms of higher-order data transforms, even when working with big data in `R`. Designs in terms of these operators tend to be succinct, powerful, performant, and maintainable.

To master the terms `moveValuesToRows` and `moveValuesToColumns` I suggest trying the following two articles:

-   [Theory of coordinatized data](https://winvector.github.io/cdata/).
-   [Fluid data transforms](https://winvector.github.io/replyr/articles/FluidData.html).

``` r
if(isSpark) {
  status <- sparklyr::spark_disconnect(my_db)
} else {
  status <- DBI::dbDisconnect(my_db)
}
my_db <- NULL
```
