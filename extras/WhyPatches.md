Why To Use Patches
==================

#### Introduction

One of the big selling points of the [`R`](https://cran.r-project.org) package [`dplyr`](https://CRAN.R-project.org/package=dplyr) is it lets you use the a grammar of data manipulation to work with data from a variety of data sources:

-   local `data.frame`s.
-   Databases (`SQLite`, `PostgreSQL`, `MySQL`, and more).
-   [`Spark`](http://spark.apache.org) (via [`SparklyR`](https://CRAN.R-project.org/package=sparklyr)).

This yields the *expectation* that the same code will have similar results on these multiple data sources. This in fact not quite the case. One has the weaker circumstance that while some `dplyr` code will often work with each of these data sources.

That is one may have to adapt or patch a `dplyr` workflows to the particular data source you are working with. The [`replyr` package](https://CRAN.R-project.org/package=replyr) includes a collection of patches that attempt to make it possible to write code that will run correctly on a variety of data sources. Our current emphasis is running correctly on [`RPostgreSQL`](https://CRAN.R-project.org/package=RPostgreSQL) and [`Sparklyr`](https://CRAN.R-project.org/package=sparklyr) as this adds significant medium data and big data capabilities to [`R`](https://cran.r-project.org).

#### Example

The above is much clearer if we work a concrete example.

Let's first start up an `R` instance.

``` r
base::date()
```

    ## [1] "Wed Jun 14 15:45:02 2017"

``` r
suppressPackageStartupMessages(library("dplyr"))
packageVersion("dplyr")
```

    ## [1] '0.7.0'

``` r
packageVersion("dbplyr")
```

    ## [1] '1.0.0'

``` r
suppressPackageStartupMessages(packageVersion("sparklyr"))
```

    ## [1] '0.5.6'

``` r
packageVersion("sparklyr")
```

    ## [1] '0.5.6'

``` r
library("replyr")
packageVersion("replyr")
```

    ## [1] '0.4.1'

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

We will start with a local `data.frame` example. We create a `data.frame`, use a function to add a column, and perform a couple of example joins.

One must understand that these operations are not meant to look meaningful on their own. They are the types of code one sees in the middle of larger meaningful data transformations. The sub-operations we are calling out include:

-   Creating a table.
-   Adding a constant character column to the table (our example functions `f()` and `fCast()`).
-   Performing a simple join (our example function `fJoin()`).

We are going to spare the reader any "motivating story" or cutesy pretend application. In return we ask the reader trust us that non-trivial data projects include many steps at least this complicated, and at least this abstract.

Let's set up our data and define our functions.

``` r
dLocal <- data.frame(x = 1:2,
                     origCol = c('a', 'b'),
                     stringsAsFactors = FALSE)

f <- function(dt) {
  mutate(dt, newCol= 'a')
}

fCast <- function(dt) {
  mutate(dt, newCol= as.character('a'))
}

fJoin <- function(d1, d2) {
  inner_join(d1, d2,
           by=c('origCol'='newCol'))
}
```

And let's show a typical use of them on a "local" `data.frame`.

``` r
d <- dLocal

# call our function on table
dR <- f(d)
print(dR)
```

    ##   x origCol newCol
    ## 1 1       a      a
    ## 2 2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ##   x.x origCol newCol x.y origCol.y
    ## 1   1       a      a   1         a
    ## 2   1       a      a   2         b

``` r
# cast function works very similar
dRC <- fCast(d)
print(dRC)
```

    ##   x origCol newCol
    ## 1 1       a      a
    ## 2 2       b      a

``` r
# again, can work with the result
fJoin(dRC, dRC)
```

    ##   x.x origCol newCol x.y origCol.y
    ## 1   1       a      a   1         a
    ## 2   1       a      a   2         b

``` r
# clean up
rm(list= c('d', 'dR', 'dRC'))
```

That is our example project, and it worked just fine on in-memory or local data.

#### `SQLite` example

We can show some of the versatility of `dplyr` by trying the exact same code on an (in-memory) `SQLite` database.

``` r
# set up db connection and copy data over
sc <- dplyr::src_sqlite(":memory:", 
                        create = TRUE)
d <- copy_to(sc, dLocal, 'd')

# call our function on table
dR <- f(d)
print(dR)
```

    ## # Source:   lazy query [?? x 3]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ## # Source:   lazy query [?? x 5]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##     x.x origCol.x newCol   x.y origCol.y
    ##   <int>     <chr>  <chr> <int>     <chr>
    ## 1     1         a      a     1         a
    ## 2     1         a      a     2         b

``` r
# cast function works very similar
dRC <- fCast(d)
print(dRC)
```

    ## # Source:   lazy query [?? x 3]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# again, can work with the result
fJoin(dRC, dRC)
```

    ## # Source:   lazy query [?? x 5]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##     x.x origCol.x newCol   x.y origCol.y
    ##   <int>     <chr>  <chr> <int>     <chr>
    ## 1     1         a      a     1         a
    ## 2     1         a      a     2         b

Notice the exact same code worked on the data even when it is in a database. This is a big advantage. Experience earned using `dplyr` on `data.frame`s can be re-used when working with databases. Procedures can be rehearsed, and code can be re-used. `dplyr` isn't just promising us a single "better in-memory `data.frame`" it is giving us the ability to delegate implementation to other systems including substantial databases and `Spark`.

#### PostgreSQL example

We can try this exact same workflow on a `PostgreSQL` database.

``` r
sc <- dplyr::src_postgres(host = 'localhost',
                          port = 5432,
                          user = 'postgres',
                          password = 'pg')
d <- copy_to(sc, dLocal, 'd')

# call our function on table
dR <- f(d)
print(dR)
```

    ## Warning in postgresqlExecStatement(conn, statement, ...): RS-DBI driver
    ## warning: (unrecognized PostgreSQL field type unknown (id:705) in column 2)

    ## # Source:   lazy query [?? x 3]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

We got a warning, that should make us worried. And indeed the `dR` table is "not quite right" and triggers an error in our simple join.

``` r
# work with result
fJoin(dR, dR)
```

    ## Error in postgresqlExecStatement(conn, statement, ...): RS-DBI driver: (could not Retrieve the result : ERROR:  failed to find conversion function from unknown to text
    ## )

This error is in fact why we have the function `fCast()`. The cast version of `f()` seems to inform `PostgreSQL` of the needed type information and allow a correct join.

``` r
# cast function version
dRC <- fCast(d)
print(dRC)
```

    ## # Source:   lazy query [?? x 3]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# again, can work with the result
fJoin(dRC, dRC)
```

    ## # Source:   lazy query [?? x 5]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##     x.x origCol.x newCol   x.y origCol.y
    ##   <int>     <chr>  <chr> <int>     <chr>
    ## 1     1         a      a     1         a
    ## 2     1         a      a     2         b

At this point it appears that just adding an extra cast will give us code that works everywhere. Of course one has to remember to do this. To make remembering simple we have a function called `replyr::addConstantColumn()` which attempt to remember if the cast is needed (which depends both on the type of the value being added and the database we are working with). This is a small thing, but once you have a lot of these they can be substantial.

#### `Spark`

`Spark` is becoming a very important system for `R` users due to its ability to work at scale and be scripted through the `SparkR` or `SparklyR` interfaces.

Notice in this `Spark 2.0.2` example we can use the same code as the original example (we are only using `replyr::addConstantColumn()` as a choice).

``` r
sc <- sparklyr::spark_connect(version= '2.0.2', 
                              master= "local")
d <- copy_to(sc, dLocal, 'd')

# call our function on table
dR <- replyr::addConstantColumn(d, 'newCol', 'a')

# work with result
fJoin(dR, dR)
```

    ## # Source:   lazy query [?? x 5]
    ## # Database: spark_connection
    ##     x.x origCol.x newCol   x.y origCol.y
    ##   <int>     <chr>  <chr> <int>     <chr>
    ## 1     1         a      a     1         a
    ## 2     1         a      a     1         a

### Conclusion

At this point we have shown that while `dplyr` can work over multiple data sources, it often needs somewhat different code for each one. This makes writing reliable, re-usable, *generic* code needlessly difficult. Each of these problems is easy to fix if they the entirety of your goals, but as interruptions in laying out a larger workflow they can be killing distractions. [`replyr`](https://CRAN.R-project.org/package=replyr) is (among other things) a patch-set in convenient package form.

We suggest using a genericising adapter such as `replyr` to work around these differences in production.

We do, as a public service, file everything we find as concise issues with the original projects; but one needs to make progress on actual production work in the meantime.

Appendix: other currently needed work-arounds or patches
--------------------------------------------------------

The following are all small speed bumps that are easy to move past, *if* they were what you were directly working and thinking about. Hidden as steps in larger code or packages they can produce wrong results or at least trigger long debugging sessions.

### nrow

From [`dplyr` issue 2871](https://github.com/tidyverse/dplyr/issues/2871):

``` r
d <- data.frame(x = 1:3)

# expected behavior
nrow(d)
```

    ## [1] 3

``` r
#> [1] 3

# db vector behavior (throws)
dS <- dbplyr::memdb_frame(x = 1:3)
print(dS)
```

    ## # Source:   table<mrbdaaweal> [?? x 1]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       x
    ##   <int>
    ## 1     1
    ## 2     2
    ## 3     3

``` r
# return NA
nrow(dS)
```

    ## [1] NA

``` r
# works
replyr_nrow(dS)
```

    ## [1] 3

### union\_all

``` r
my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
dr <- dplyr::copy_to(my_db,
                     data.frame(x= c(1,2),
                                y= c('a','b'),
                                stringsAsFactors = FALSE),
                     'dr',
                     overwrite=TRUE)
dr <- head(dr,1)

# works
replyr_union_all(dr, dr)
```

    ## # Source:   table<replyr_union_all_Q8dHrDF0Vf7qpqqytrNK_0000000003> [?? x
    ## #   2]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       x     y
    ##   <dbl> <chr>
    ## 1     1     a
    ## 2     1     a

``` r
# throws
dplyr::union_all(dr, dr)
```

    ## Error: SQLite does not support set operations on LIMITs

### rename

From [`dplyr` issue 2860](https://github.com/tidyverse/dplyr/issues/2860):

``` r
df <- dbplyr::memdb_frame(x = 1:3, y = 4:6)
df
```

    ## # Source:   table<ycekaozytk> [?? x 2]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       x     y
    ##   <int> <int>
    ## 1     1     4
    ## 2     2     5
    ## 3     3     6

``` r
# works
df %>% replyr_mapRestrictCols(c('A'='x', 'B'='y'))
```

    ## # Source:   lazy query [?? x 2]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       A     B
    ##   <int> <int>
    ## 1     1     4
    ## 2     2     5
    ## 3     3     6

``` r
# throws
df %>% rename(A=x, B=y)
```

    ## Error in names(select)[match(old_vars, vars)] <- new_vars: NAs are not allowed in subscripted assignments

Appendix: re-run initial examples with `replyr::addConstantColumn()`
--------------------------------------------------------------------

In this appendix we re-run the initial examples with `replyr::addConstantColumn()` to confirm our claim `replyr::addConstantColumn()` works in a generic sense.

``` r
d <- dLocal

# call our function on table
dR <- replyr::addConstantColumn(d, 'newCol', 'a')
print(dR)
```

    ##   x origCol newCol
    ## 1 1       a      a
    ## 2 2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ##   x.x origCol newCol x.y origCol.y
    ## 1   1       a      a   1         a
    ## 2   1       a      a   2         b

``` r
# set up db connection and copy data over
sc <- dplyr::src_sqlite(":memory:", 
                        create = TRUE)
d <- copy_to(sc, dLocal, 'd')

# call our function on table
dR <- replyr::addConstantColumn(d, 'newCol', 'a')
print(dR)
```

    ## # Source:  
    ## #   table<replyr_addConstantColumn_1NMMS9Ep97DRrBIP51YQ_0000000000> [?? x
    ## #   3]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ## # Source:   lazy query [?? x 5]
    ## # Database: sqlite 3.11.1 [:memory:]
    ##     x.x origCol.x newCol   x.y origCol.y
    ##   <int>     <chr>  <chr> <int>     <chr>
    ## 1     1         a      a     1         a
    ## 2     1         a      a     2         b

``` r
sc <- dplyr::src_postgres(host = 'localhost',
                          port = 5432,
                          user = 'postgres',
                          password = 'pg')
d <- copy_to(sc, dLocal, 'd')

# call our function on table
dR <- replyr::addConstantColumn(d, 'newCol', 'a')
print(dR)
```

    ## # Source:  
    ## #   table<replyr_addConstantColumn_C7ilqokumKEaC9JvfYDC_0000000000> [?? x
    ## #   3]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ## # Source:   lazy query [?? x 5]
    ## # Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ##     x.x origCol.x newCol   x.y origCol.y
    ##   <int>     <chr>  <chr> <int>     <chr>
    ## 1     1         a      a     2         b
    ## 2     1         a      a     1         a
