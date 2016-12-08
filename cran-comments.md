## Test environments
* local OS X install x86_64-apple-darwin13.4.0 (64-bit)
* R version 3.3.2
* win-builder (devel and release) (URL note in win-builder check is an incorrect signaling, URL is valid)

## R CMD check --as-cran replyr_0.1.0.tar.gz 
* using log directory ‘/Users/johnmount/Documents/work/replyr.Rcheck’
* using R version 3.3.2 (2016-10-31)
* using platform: x86_64-apple-darwin13.4.0 (64-bit)
* using session charset: UTF-8
* using option ‘--as-cran’

1 NOTEs, no WARNINGs or ERRORs


* checking CRAN incoming feasibility ... NOTE
Maintainer: ‘John Mount <jmount@win-vector.com>’

New submission

Found the following (possibly) invalid URLs:
  URL: http://www.win-vector.com'
    From: inst/doc/replyr.html
    Status: Error
    Message: libcurl error code 6
    	Could not resolve host: www.win-vector.com'
  URL: http://www.win-vector.com'/
    From: README.md
    Status: Error
    Message: libcurl error code 6
    	Could not resolve host: www.win-vector.com'


URL is in fact correct and responds host www.win-vector.com is valid.  Same URL issue in win-build check.

## Downstream dependencies

No declared reverse dependencies:

     devtools::revdep('replyr')
     character(0)
