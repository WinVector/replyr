library('replyr')

context("copy_to")

test_that("test_replyr_copy_to.R", {
  if (requireNamespace("RSQLite", quietly = TRUE)) {
    my_db <- dplyr::src_sqlite(":memory:", create = TRUE)
    d <- replyr_copy_to(my_db, data.frame(x = c(1, 2)), 'd')
    #print(d)
    tryCatch(
      # try/catch in case we have a dplyr 0.5.0 handle not a dplyr 0.7.0 handle
      DBI::dbDisconnect(my_db),
      error = function(e) {NULL}
    )
  }

})
