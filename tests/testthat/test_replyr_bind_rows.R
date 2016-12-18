library('replyr')

context("bind_rows")

test_that("test_replyr_bind_rows", {
  d <- data.frame(x = 1:2)
  replyr_bind_rows(list(d, d, d))

})
