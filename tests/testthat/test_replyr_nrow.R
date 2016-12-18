library('replyr')

context("nrow")

test_that("test_replyr_nrow.R", {
  d <- data.frame(x = c(1, 2))
  replyr_nrow(d)

})
