
This is a maintenance release to work around errors
seen on the CRAN results page.  Also we are declaring
the package in maintenance mode: we will continue to
support it but are also encouraging users to move on
to our newer non-monolithic
re-implementations: wrapr, seplyr, rquery, 
and cdata.

## Test environments

  * OSX build/check
  * using R version 3.4.4 (2018-03-15)
  * using platform: x86_64-apple-darwin15.6.0 (64-bit)


  * win-builder 

## R CMD check --as-cran replyr_0.9.3.tar.gz 

  * using option ‘--as-cran’
  * checking for file ‘replyr/DESCRIPTION’ ... OK
  * checking extension type ... Package
  * this is package ‘replyr’ version ‘0.9.3’
  * checking CRAN incoming feasibility ... Note_to_CRAN_maintainers
  Maintainer: ‘John Mount <jmount@win-vector.com>’
  
  Status: OK

## Downstream dependencies

No declared dependencies.

    devtools::revdep()
    character(0)
