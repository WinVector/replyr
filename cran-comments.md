
Quick update to try and undo the undeclared indirect use on 'webshot' in vignettes caught on the Solaris checks.

Sub-directory doc size is to support diagrams rendered in vignettes.

## Test environments

### Linux build/check

    R CMD check --as-cran replyr_1.0.2.tar.gz 
    * using R version 3.5.3 (2019-03-11)
    * using platform: x86_64-pc-linux-gnu (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘1.0.2’
    * checking CRAN incoming feasibility ... NOTE
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Days since last update: 1
    * checking installed package size ... NOTE
      installed size is  6.9Mb
      sub-directories of 1Mb or more:
        doc   6.6Mb
    Status: 2 NOTEs


### OSX build/check

    R CMD check --as-cran replyr_1.0.2.tar.gz 
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘1.0.2’
    * checking CRAN incoming feasibility ... NOTE
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    Days since last update: 1
    * checking installed package size ... NOTE
      installed size is  5.4Mb
      sub-directories of 1Mb or more:
        doc   5.1Mb
    Status: 2 NOTEs

### Windows

    devtools::check_win_devel()
    * using R Under development (unstable) (2019-07-05 r76784)
    * using platform: x86_64-w64-mingw32 (64-bit)
    * using session charset: ISO8859-1
    * checking for file 'replyr/DESCRIPTION' ... OK
    * checking extension type ... Package
    * this is package 'replyr' version '1.0.2'
    * checking CRAN incoming feasibility ... NOTE
    Maintainer: 'John Mount <jmount@win-vector.com>'
    Days since last update: 2
    Status: 1 NOTE

    rhub::check_for_cran()
    1135#> * using R Under development (unstable) (2019-06-21 r76731)
    1136#> * using platform: x86_64-w64-mingw32 (64-bit)
    1137#> * using session charset: ISO8859-1
    1138#> * using option '--as-cran'
    1142#> * checking CRAN incoming feasibility ... NOTE
    1143#> Maintainer: 'John Mount '
    1144#> Days since last update: 1
    1154#> * checking installed package size ... NOTE
    1155#> installed size is 5.4Mb
    1156#> sub-directories of 1Mb or more:
    1157#> doc 5.1Mb
    1183#> * checking Rd cross-references ... NOTE
    1184#> Package unavailable to check Rd xrefs: 'rquery'
    1203#> Status: 3 NOTEs
    'rquery' is an alternative to this package, so 'rquery' is mentioned in documentation even though it is not used by this package.

## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)

