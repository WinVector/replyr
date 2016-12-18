library('replyr')

context("unique values")

test_that("test_replyr_uniqueValues.R", {
  d <- data.frame(x = c(1, 2, 3, 3))
  replyr_uniqueValues(d, 'x')
})
