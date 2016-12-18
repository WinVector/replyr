library('replyr')

context("split")

test_that("test_replyr_split.R", {
  library('dplyr')
  d <- data.frame(
    group = c(1, 1, 2, 2, 2),
    order = c(.1, .2, .3, .4, .5),
    values = c(10, 20, 2, 4, 8)
  )
  d %>% replyr_split('group')

})
