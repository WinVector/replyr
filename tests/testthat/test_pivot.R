library('replyr')

context("pivot")

test_that("test_pivot.R", {
  my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")

  # test unpivot
  d <- replyr_copy_to(my_db,
                      data.frame(
                        index = c(1, 2, 3),
                        info = c('a', 'b', 'c'),
                        meas1 = c('m1_1', 'm1_2', 'm1_3'),
                        meas2 = c('m2_1', 'm2_2', 'm2_3'),
                        stringsAsFactors = FALSE),
                      'd1',
                      temporary = TRUE, overwrite = TRUE)
  ct <- buildUnPivotControlTable(nameForNewKeyColumn= 'meastype',
                                 nameForNewValueColumn= 'meas',
                                 columnsToTakeFrom= c('meas1','meas2'))
  moveValuesToRowsQ('d1',
                    controlTable = ct,
                    columnsToCopy = c('index', 'info'),
                    my_db = my_db) %.>%
    dplyr::select(., index, info, meastype, meas) %.>%
    dplyr::arrange(., index, meastype) %.>%
    dplyr::collect(.) %.>%
    as.data.frame(.) -> rp
  expect <- data.frame(index = c(1,1,2,2,3,3),
                       info = c('a','a','b','b','c','c'),
                       meastype = c('meas1','meas2','meas1','meas2','meas1','meas2'),
                       meas= c('m1_1', 'm2_1', 'm1_2', 'm2_2', 'm1_3', 'm2_3'),
                       stringsAsFactors = FALSE)
  expect_true(all.equal(expect, data.frame(rp)))

  # test pivot
  d <- replyr_copy_to(my_db,
                      data.frame(
                        index = c(1, 2, 3, 1, 2, 3),
                        meastype = c('meas1','meas1','meas1','meas2','meas2','meas2'),
                        meas = c('m1_1', 'm1_2', 'm1_3', 'm2_1', 'm2_2', 'm2_3'),
                        stringsAsFactors = FALSE),
                      'd2',
                      temporary = TRUE, overwrite = TRUE)
  ct <- buildPivotControlTable(d,
                               columnToTakeKeysFrom= 'meastype',
                               columnToTakeValuesFrom= 'meas')
  moveValuesToColumnsQ('d2',
                       controlTable = ct,
                       keyColumns = 'index',
                       my_db = my_db) %.>%
    dplyr::select(., index, meas1, meas2) %.>%
    dplyr::arrange(., index) %.>%
    dplyr::collect(.) %.>%
    as.data.frame(.) -> rp
  expect <- data.frame(index = c(1,2,3),
                       meas1 = c('m1_1', 'm1_2', 'm1_3'),
                       meas2 = c('m2_1', 'm2_2', 'm2_3'),
                       stringsAsFactors = FALSE)
  expect_true(all.equal(expect, data.frame(rp)))
})