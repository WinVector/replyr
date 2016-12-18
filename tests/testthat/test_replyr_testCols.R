library('replyr')

context("testCols")

test_that("test_replyr_testCols.R", {
  d <- data.frame(x = c(1, 2), y = c('a', 'b'))
  replyr_testCols(d, is.numeric)

})
