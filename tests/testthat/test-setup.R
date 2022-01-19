context("setup")

source("utils.R")

test_that("multiplication works", {
  skip_if_no_sudachi()
  install_sudachipy()
  expect_equal(
    sum(reticulate::virtualenv_exists("r-sudachipy")),
    1L
  )
})
