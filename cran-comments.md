
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
 

### win-builder 

    devtools::check_win_devel()
 
 

## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)

