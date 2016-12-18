library('replyr')

context("inTest")

test_that("test_replyr_inTest", {
  values <- c('a', 'c')
  d <- data.frame(
    x = c('a', 'a', 'b', 'b', 'c', 'c'),
    y = 1:6,
    stringsAsFactors = FALSE
  )
  replyr_inTest(d, 'x', values, 'match')

})
