library('replyr')

context("str")

test_that("test_replyr_str.R", {
  d <- data.frame(x = c(1, 2))
  s <- replyr_str(d)

})
