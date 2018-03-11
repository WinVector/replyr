
This is a maintenance release including minor fixes and
to reduce package dependencies.

## Test environments

  * OSX build/check
  * using R version 3.4.3 (2017-11-30)
  * using platform: x86_64-apple-darwin15.6.0 (64-bit)

  * win-builder 
  * using R Under development (unstable) (2018-03-09 r74376)
  * using platform: x86_64-w64-mingw32 (64-bit)

## R CMD check --as-cran replyr_0.9.2.tar.gz 

  * using option ‘--as-cran’
  * checking for file ‘replyr/DESCRIPTION’ ... OK
  * checking extension type ... Package
  * this is package ‘replyr’ version ‘0.9.2’
  * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
    Maintainer: ‘John Mount <jmount@win-vector.com>’

Status: OK
(no other NOTEs, WARNINGs, or ERRORs)

## Downstream dependencies

All declared dependencies checked.

    devtools::revdep_check()
    Checking 1 packages: WVPlots
    Checked WVPlots: 0 errors | 0 warnings | 0 notes
