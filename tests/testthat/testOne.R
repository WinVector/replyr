library('replyr')

context("Excercise Operations")

test_that("testOne: Works As Expected", {
  d <- data.frame(x = c(1, 2))
  n <- replyr_nrow(d)
  expect_true(n == 2)
})