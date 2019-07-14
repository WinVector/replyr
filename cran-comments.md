

Sub-directory doc size is to support diagrams rendered in vignettes.

## Test environments


### OSX build/check

    R CMD check --as-cran replyr_1.0.3.tar.gz 
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘1.0.3’
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    * checking installed package size ... NOTE
      installed size is  5.4Mb
      sub-directories of 1Mb or more:
        doc   5.1Mb
    Status: 1 NOTE


### Windows

    devtools::check_win_devel()

    rhub::check_for_cran()
    943#> * using R Under development (unstable) (2019-07-04 r76780)
    944#> * using platform: x86_64-w64-mingw32 (64-bit)
    945#> * using session charset: ISO8859-1
    946#> * using option '--as-cran'
    947#> * checking for file 'replyr/DESCRIPTION' ... OK
    948#> * checking extension type ... Package
    949#> * this is package 'replyr' version '1.0.3'
    950#> * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    951#> Maintainer: 'John Mount '
    961#> * checking installed package size ... NOTE
    962#> installed size is 5.4Mb
    963#> sub-directories of 1Mb or more:
    964#> doc 5.1Mb
    990#> * checking Rd cross-references ... NOTE
    991#> Package unavailable to check Rd xrefs: 'rquery'
   1009#> * DONE
   1010#> Status: 2 NOTEs
   rquery is a documented alternative to replyr, but not a dependency.

## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)

