library('replyr')

context("dim")

test_that("test_replyr_dim", {
  d <- data.frame(x = c(1, 2))
  replyr_dim(d)

})
