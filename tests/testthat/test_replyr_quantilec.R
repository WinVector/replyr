library('replyr')

context("qauntilec")

test_that("test_replyr_quantilec.R", {

d <- data.frame(xvals=rev(1:1000))
replyr_quantilec(d,'xvals')

})

