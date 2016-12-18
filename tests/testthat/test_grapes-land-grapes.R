library('replyr')

context("test land")

test_that("test_grapes-land-grapes.R", {
  library("dplyr")
  7 %>% sin() %->% z1
  7 %>% sin() %->_% 'z2'
  varname <- 'z3'
  7 %>% sin() %->_% varname

})
