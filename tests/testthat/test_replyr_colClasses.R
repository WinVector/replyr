library('replyr')

context("colClasses")

test_that("test_replyr_colClasses.R", {
  d <- data.frame(x = c(1, 2))
  replyr_colClasses(d)

})
