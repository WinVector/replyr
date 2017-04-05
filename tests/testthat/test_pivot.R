library('replyr')

context("pivot")

test_that("test_pivot.R", {
  library("dplyr")

  # test pivot
  d <- data.frame(
    index = c(1, 2, 3),
    info = c('a', 'b', 'c'),
    meas1 = c('m1_1', 'm1_2', 'm1_3'),
    meas2 = c('m2_1', 'm2_2', 'm2_3'),
    stringsAsFactors = FALSE)
  replyr_moveValuesToRows(d,
                          nameForNewKeyColumn= 'meastype',
                          nameForNewValueColumn= 'meas',
                          columnsToTakeFrom= c('meas1','meas2')) %>%
    dplyr::select(index, info, meastype, meas) %>%
    dplyr::arrange(index, meastype) -> rp
  expect <- data.frame(index = c(1,1,2,2,3,3),
                       info = c('a','a','b','b','c','c'),
                       meastype = c('meas1','meas2','meas1','meas2','meas1','meas2'),
                       meas= c('m1_1', 'm2_1', 'm1_2', 'm2_2', 'm1_3', 'm2_3'),
                       stringsAsFactors = FALSE)
  expect_true(all.equal(expect, data.frame(rp)))

  # test unpivot
  d <- data.frame(
    index = c(1, 2, 3, 1, 2, 3),
    meastype = c('meas1','meas1','meas1','meas2','meas2','meas2'),
    meas = c('m1_1', 'm1_2', 'm1_3', 'm2_1', 'm2_2', 'm2_3'),
    stringsAsFactors = FALSE)
  replyr_moveValuesToColumns(d,
                             columnToTakeKeysFrom= 'meastype',
                             columnToTakeValuesFrom= 'meas',
                             rowKeyColumns= 'index') %>%
    dplyr::select(index, meas1, meas2) %>%
    dplyr::arrange(index) -> rp
  expect <- data.frame(index = c(1,2,3),
                       meas1 = c('m1_1', 'm1_2', 'm1_3'),
                       meas2 = c('m2_1', 'm2_2', 'm2_3'),
                       stringsAsFactors = FALSE)
  expect_true(all.equal(expect, data.frame(rp)))
})