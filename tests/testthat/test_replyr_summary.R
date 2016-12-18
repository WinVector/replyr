library('replyr')

context("summary")

test_that("test_replyr_summary.R", {
  d <- data.frame(
    x = c(NA, 2, 3),
    y = factor(c(3, 5, NA)),
    z = c('a', NA, 'z'),
    stringsAsFactors = FALSE
  )
  replyr_summary(d)

})
