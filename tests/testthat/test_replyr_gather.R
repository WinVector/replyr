library('replyr')

context("gather")

test_that("test_replyr_gather.R", {
  d <- data.frame(
    index = c(1, 2, 3),
    info = c('a', 'b', 'c'),
    meas1 = c('m1_1', 'm1_2', 'm1_3'),
    meas2 = c('m2_1', 'm2_2', 'm2_3'),
    stringsAsFactors = FALSE
  )
  replyr_gather(d, c('meas1', 'meas2'), 'meastype', 'meas')
  replyr_gather(d, c('meas1', 'meas2'), 'meastype', 'meas', useTidyr = TRUE)

})
