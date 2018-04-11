library('replyr')

context("copy_from")

test_that("test_replyr_copy_from.R", {
  if ( requireNamespace("RSQLite", quietly = TRUE)) {
    my_db <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
    RSQLite::initExtension(my_db)
    d <- replyr_copy_to(my_db, data.frame(x = c(1, 2)), 'd')
    d2 <- replyr_copy_from(d)
    #print(d2)
    DBI::dbDisconnect(my_db)
  }

})
