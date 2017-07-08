library('replyr')

context("test land")

test_that("test_grapes-land-grapes.R", {
  library("dplyr")
  sin(7) %->% z1
  sin(7) %->_% 'z2'
  varname <- 'z3'
  sin(7) %->_% varname

})
