

Sub-directory doc size is to support diagrams rendered in vignettes.

## Test environments

    rhub::check_for_cran()

    1030#> * using R Under development (unstable) (2019-07-04 r76780)
    1031#> * using platform: x86_64-w64-mingw32 (64-bit)
    1032#> * using session charset: ISO8859-1
    1033#> * using option '--as-cran'
    1034#> * checking for file 'replyr/DESCRIPTION' ... OK
    1035#> * checking extension type ... Package
    1036#> * this is package 'replyr' version '1.0.4'
    1037#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    1038#> Maintainer: 'John Mount '
    1048#> * checking installed package size ... NOTE
    1049#> installed size is 5.4Mb
    1050#> sub-directories of 1Mb or more:
    1051#> doc 5.1Mb
    1076#> * checking Rd line widths ... OK
    1077#> * checking Rd cross-references ... NOTE
    1078#> Package unavailable to check Rd xrefs: 'rquery'
    1097#> Status: 2 NOTEs
    rquery is an alternative, not a dependency or suggestion.
    

### OSX build/check

    R CMD check --as-cran replyr_1.0.4.tar.gz 
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘1.0.4’
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    * checking installed package size ... NOTE
      installed size is  5.4Mb
      sub-directories of 1Mb or more:
        doc   5.1Mb
    Status: 1 NOTE

### Windows

    devtools::check_win_devel()


    rquery is a documented alternative to replyr, but not a dependency.

## Downstream dependencies

No declared dependencies.

    devtools::revdep()


