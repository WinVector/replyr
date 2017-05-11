library('replyr')

context("check_rankds")

test_that("test_replyr_check_ranks.R", {
  d <- data.frame(
    Sepal_Length = c(5.8, 5.7),
    Sepal_Width = c(4.0, 4.4),
    Species = 'setosa',
    rank = c(1, 2)
  )
  replyr_check_ranks(d, 'Species', 'Sepal_Length', 'rank',
                     decreasing=TRUE)

})
