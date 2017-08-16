

## Test environments

 * local OS X install x86_64-apple-darwin13.4.0 (64-bit)
 * using R version 3.4.1 (2017-06-30)
 * win-builder (devel and release) 

## R CMD check --as-cran replyr_0.5.3.tar.gz

* using R version 3.4.1 (2017-06-30)
* using platform: x86_64-apple-darwin15.6.0 (64-bit)
* using session charset: UTF-8
* using option ‘--as-cran’
* checking for file ‘replyr/DESCRIPTION’ ... OK
* checking extension type ... Package
* this is package ‘replyr’ version ‘0.5.3’

NOTEs

Maintainer: ‘John Mount <jmount@win-vector.com>’

Missing or unexported object: 'sparklyr::sdf_bind_rows'

`sparklyr::sdf_bind_rows` is new to the development version of `Sparklyr`,
`sparklyr` is a suggested package, and this method 
is only called in the following block (under user control, and fully
guarded):
```r
  if(useSparkMethod && replyr_is_Spark_data(tabA)) {
    # sparklyr (post '0.5.6', at least '0.5.6.9008')
    # has a new sdf_bind_rows function we could try to use on Spark sources (limit columns first)
    if(requireNamespace('sparklyr', quietly = TRUE) &&
       exists('sdf_bind_rows', where=asNamespace('sparklyr'), mode='function')) {
      return(sparklyr::sdf_bind_rows(list(tabA, tabB)))
    }
  }
```


Status: OK (no other NOTEs, WARNINGs, or ERRORs)

## Downstream dependencies

All declared dependencies checked.

  devtools::revdep('replyr')
  [1] "WVPlots"
