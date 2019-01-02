

## Test environments

### OSX build/check

    R CMD check --as-cran replyr_0.9.9.tar.gz 
    * using R version 3.5.0 (2018-04-23)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘0.9.9’
    * checking CRAN incoming feasibility ...
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Status: OK

### win-builder 

    devtools::build_win()
    * using R Under development (unstable) (2019-01-01 r75943)
    * using platform: x86_64-w64-mingw32 (64-bit)
    * using session charset: ISO8859-1
    * checking for file 'replyr/DESCRIPTION' ... OK
    * checking extension type ... Package
    * this is package 'replyr' version '0.9.9'
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: 'John Mount <jmount@win-vector.com>'
    Status: OK

## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)
