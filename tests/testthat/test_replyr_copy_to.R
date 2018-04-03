library('replyr')

context("copy_to")

test_that("test_replyr_copy_to.R", {
  if (requireNamespace("RSQLite", quietly = TRUE) &&
      requireNamespace("dbplyr", quietly = TRUE)) {
    my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
    RSQLite::initExtension(my_db)
    d <- replyr_copy_to(my_db, data.frame(x = c(1, 2)), 'd')
    #print(d)
    DBI::dbDisconnect(my_db)
  }
})
