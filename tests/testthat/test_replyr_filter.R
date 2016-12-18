library('replyr')

context("filter")

test_that("test_replyr_filter.R", {
  values <- c('a', 'c')
  d <- data.frame(
    x = c('a', 'a', 'b', 'b', 'c', 'c'),
    y = 1:6,
    stringsAsFactors = FALSE
  )
  replyr_filter(d, 'x', values)

})
