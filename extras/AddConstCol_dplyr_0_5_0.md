#### Introduction

One of the big selling points of the [`R`](https://cran.r-project.org) package [`dplyr`](https://CRAN.R-project.org/package=dplyr) is it lets you use the same grammar to work with data from a variety of data sources:

-   local `data.frame`s.
-   Databases (`SQLite`, `PostgreSQL`, `MySQL`, and more).
-   [`Spark`](http://spark.apache.org) (via [`SparklyR`](https://CRAN.R-project.org/package=sparklyr)).

This yields the *expectation* that the same code can be used on these multiple data sources. This in fact not quite the case. One has the weaker circumstance that while some `dplyr` code will often work with each of these data sources, sometimes no one piece of code will work on all data sources.

That is we may have to adapt our `dplyr` workflows to the data source. The [`replyr` package](https://CRAN.R-project.org/package=replyr) (especially the [development version](https://github.com/WinVector/replyr)) attempts to make it possible to write code that will run correctly on a variety of data sources. Our current emphasis is running correctly on [`RPostgreSQL`](https://CRAN.R-project.org/package=RPostgreSQL) and [`Sparklyr`](https://CRAN.R-project.org/package=sparklyr) as this adds significant medium data and big data capabilities to [`R`](https://cran.r-project.org).

#### Example

The above is much clearer if we work a concrete example.

Let's first start up an `R` instance.

``` r
# devtools::install_github("tidyverse/dplyr")
# devtools::install_github('tidyverse/dbplyr')
base::date()
```

    ## [1] "Sun May 14 23:56:03 2017"

``` r
suppressPackageStartupMessages(library("dplyr"))
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
packageVersion("replyr")
```

    ## [1] '0.3.2'

``` r
R.Version()$version.string
```

    ## [1] "R version 3.4.0 (2017-04-21)"

And work a local `data.frame` example. We create a `data.frame`, use a function to add a column, and perform a couple of example joins.

One must understand that these operations are not meant to look meaningful on their own. They are the types of code one sees in the middle of larger meaningful data transformations. The sub-operations we are calling out include:

-   Creating a table.
-   Adding a constant character column to the table (our functions `f()` and `fCast()`).
-   Performing a simple join (our function `fJoin()`).

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

    ## Source:   query [?? x 3]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ## Source:   query [?? x 6]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

``` r
# cast function works very similar
dRC <- fCast(d)
print(dRC)
```

    ## Source:   query [?? x 3]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# again, can work with the result
fJoin(dRC, dRC)
```

    ## Source:   query [?? x 6]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

Notice the exact same code worked on the data even when it is in a database. This is a big advantage. Experience earned using `dplyr` on `data.frame`s can be re-used when working with databases. Procedures can be rehearsed, and code can be re-used. `dplyr` isn't promising us a single "better in-memory `data.frame`" is is giving us the ability to delegate implementation to other systems including substantial databases and `Spark`.

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

    ## Source:   query [?? x 3]
    ## Database: postgres 9.6.1 [postgres@localhost:5432/postgres]

    ## Warning in postgresqlExecStatement(conn, statement, ...): RS-DBI driver
    ## warning: (unrecognized PostgreSQL field type unknown (id:705) in column 2)

    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

We got a warning, that should make us worried. And indeed the `dR` table is "not quite right" and triggers an error in our simple join.

``` r
# work with result
fJoin(dR, dR)
```

    ## Source:   query [?? x 6]
    ## Database: postgres 9.6.1 [postgres@localhost:5432/postgres]

    ## Error in postgresqlExecStatement(conn, statement, ...): RS-DBI driver: (could not Retrieve the result : ERROR:  failed to find conversion function from unknown to text
    ## )

This error is in fact why we have the function `fCast()`. The cast version of `f()` seems to inform `PostgreSQL` of the needed type information and allow a correct join.

``` r
# cast function version
dRC <- fCast(d)
print(dRC)
```

    ## Source:   query [?? x 3]
    ## Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ## 
    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# again, can work with the result
fJoin(dRC, dRC)
```

    ## Source:   query [?? x 6]
    ## Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

At this point it *appears* that just adding an extra cast will give us code that works everywhere. Our next example we show another database that insists on not having the cast.

#### `MySQL` example

The `MySQL` adapter requires our extra cast not be present. This means no generic code that doesn't do something non-transparent (such as looking at the database type) is going to work reliably on both databases.

Here is the `MySQL` example.

It has multiple problems. The first is `MySQL` (at least through the `dplyr`) adapter doesn't seem to be able to handle a ["self-join"](https://en.wikipedia.org/wiki/Join_(SQL)#Self-join) (which is in fact a very useful operation in a number of situations).

``` r
sc <- dplyr::src_mysql('mysql', 
                       '127.0.0.1', 
                       3306, 
                       'root', '')
d <- copy_to(sc, dLocal, 'd')

# call our function on table
dR <- f(d)
print(dR)
```

    ## Source:   query [?? x 3]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]
    ## 
    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# try the join
fJoin(dR, dR)
```

    ## Source:   query [?? x 6]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]

    ## Error in .local(conn, statement, ...): could not run statement: Can't reopen table: 'd'

We can try to work around that by making copies of tables. Such code would be less efficient but should work on multiple data sources.

``` r
# copy table
dR <- compute(dR)
dR2 <- dR %>% 
  filter(TRUE) %>% 
  compute()

# try the join again
fJoin(dR, dR2)
```

    ## Source:   query [?? x 6]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

That was ugly, but such code could be made to work on our previous data sources. The real issue is the `MySQL` adapter will not work with `fCast()`. This is a problems as converting `f()` to `fCast()` was a necessary adaption for the `RPostgreSQL` adapter.

``` r
# cast function fails for MySQL adapter
dRC <- fCast(d)
print(dRC)
```

    ## Source:   query [?? x 3]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]

    ## Error in .local(conn, statement, ...): could not run statement: You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near 'TEXT) AS `newCol`
    ## FROM `d`) `tlmsrcjfze`
    ## LIMIT 10' at line 2

We could say "don't use `MySQL`", but many clients have significant data in `MySQL` databases and `dplyr 0.5.0` explicitly mentions `MySQL` as an important target (at least as of 2016-06-23):

> ["Currently dplyr supports the three most popular open source databases (sqlite, mysql and postgresql), and google’s bigquery."](https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html)

The way we work with around this in the development version of [`replyr`](https://github.com/WinVector/replyr) is: swallow our pride, inspect the database name and run different code depending on the database. That looks like the following:

``` r
# devtools::install_github("WinVector/replyr")
dRC <- replyr::addConstantColumn(d, 'newCol', 'a')

dR <- compute(dR)
dR2 <- dR %>% 
  filter(TRUE) %>% 
  compute()

# try the join again
fJoin(dR, dR2)
```

    ## Source:   query [?? x 6]
    ## Database: mysql 10.1.23-MariaDB [root@127.0.0.1:/mysql]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

The idea is unlike `f()` and `fCast()` the function `replyr::addConstantColumn()` will work with both `PostgreSQL` and `MySQL`. This means code written in terms of `replyr::addConstantColumn()` has a chance of being generic and working on multiple data sources.

#### `Spark`

`Spark` is becoming a very important system for `R` users due to its ability to work at scale and be scripted throught the `SparkR` or `SparklyR` interfaces.

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

    ## Source:   query [2 x 6]
    ## Database: spark connection master=local[4] app=sparklyr local=TRUE
    ## 
    ## # A tibble: 2 x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

### Conclusion

At this point we have shown that while `dplyr` can work over multiple data sources, it often needs somewhat different code for each one. This makes writing reliable, re-usable, *generic* code needlessly difficult. To work around this we suggest using a genericising adapter such as `replyr` to work around these differences in production.

We do, as a public service, file everything we find as concise issues with the original projects; but one needs to make progress on work in the meantime (and often the issues are not considered a high priority).

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

    ## Source:   query [?? x 3]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ## Source:   query [?? x 6]
    ## Database: sqlite 3.11.1 [:memory:]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     1         a        a
    ## 2     1         a        a     2         b        a

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

    ## Source:   query [?? x 3]
    ## Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ## 
    ## # A tibble: ?? x 3
    ##       x origCol newCol
    ##   <int>   <chr>  <chr>
    ## 1     1       a      a
    ## 2     2       b      a

``` r
# work with result
fJoin(dR, dR)
```

    ## Source:   query [?? x 6]
    ## Database: postgres 9.6.1 [postgres@localhost:5432/postgres]
    ## 
    ## # A tibble: ?? x 6
    ##     x.x origCol.x newCol.x   x.y origCol.y newCol.y
    ##   <int>     <chr>    <chr> <int>     <chr>    <chr>
    ## 1     1         a        a     2         b        a
    ## 2     1         a        a     1         a        a
