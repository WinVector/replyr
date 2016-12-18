library('replyr')

context("quantile")

test_that("test_replyr_quantile.R", {
  d <- data.frame(xvals = rev(1:1000))
  replyr_quantile(d, 'xvals')

})
