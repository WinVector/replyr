library('replyr')

context("dataServiceName")

test_that("test_replyr_dataServiceName.R", {
  replyr_dataServiceName(data.frame(x = 1))
  replyr_dataServiceName(dplyr::as.tbl(data.frame(x = 1)))

})
