library('replyr')

context("spread")

test_that("test_replyr_spread.R", {
  d <- data.frame(
    index = c(1, 2, 3, 1, 2, 3),
    meastype = c('meas1', 'meas1', 'meas1', 'meas2', 'meas2', 'meas2'),
    meas = c('m1_1', 'm1_2', 'm1_3', 'm2_1', 'm2_2', 'm2_3'),
    stringsAsFactors = FALSE
  )
  replyr_spread(d, 'index', 'meastype', 'meas')
  replyr_spread(d, 'index', 'meastype', 'meas', useTidyr = TRUE)

})
