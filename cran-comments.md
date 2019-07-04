
Sub-directory doc size is to support diagrams rendered in vignettes.

## Test environments

### OSX build/check

    R CMD check --as-cran replyr_1.0.1.tar.gz 
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-apple-darwin15.6.0 (64-bit)
    * using session charset: UTF-8
    * using option ‘--as-cran’
    * checking for file ‘replyr/DESCRIPTION’ ... OK
    * checking extension type ... Package
    * this is package ‘replyr’ version ‘1.0.1’
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’
    * checking installed package size ... NOTE
      installed size is  5.4Mb
      sub-directories of 1Mb or more:
        doc   5.1Mb
    Status: 1 NOTE

### win-builder 

    devtools::build_win()
    * using R version 3.6.0 (2019-04-26)
    * using platform: x86_64-w64-mingw32 (64-bit)
    * using session charset: ISO8859-1
    * checking for file 'replyr/DESCRIPTION' ... OK
    * checking extension type ... Package
    * this is package 'replyr' version '1.0.1'
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: 'John Mount <jmount@win-vector.com>'
    Status: OK

    devtools::check_win_devel()
    * using R Under development (unstable) (2019-06-27 r76748)
    * using platform: x86_64-w64-mingw32 (64-bit)
    * using session charset: ISO8859-1
    * checking for file 'replyr/DESCRIPTION' ... OK
    * checking extension type ... Package
    * this is package 'replyr' version '1.0.1'
    * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: 'John Mount <jmount@win-vector.com>'
    Status: OK


## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)

