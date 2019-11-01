

Fix doc size.

## Test environments

### OSX build/check

    R CMD check --as-cran replyr_1.0.5.tar.gz 
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘1.0.5’
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK


### Windows

    rhub::check_for_cran()
    867#> * using R Under development (unstable) (2019-10-19 r77318)
    868#> * using platform: x86_64-w64-mingw32 (64-bit)
    869#> * using session charset: ISO8859-1
    870#> * using option '--as-cran'
    871#> * checking for file 'replyr/DESCRIPTION' ... OK
    872#> * checking extension type ... Package
    873#> * this is package 'replyr' version '1.0.5'
    874#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    875#> Maintainer: 'John Mount '
    911#> * checking Rd cross-references ... NOTE
    912#> Package unavailable to check Rd xrefs: 'rquery'
    932#> Status: 1 NOTE
    rquery is a documented alternative to replyr, but not a dependency.

## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)

