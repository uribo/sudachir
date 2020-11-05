context("setup")

source("utils.R")

test_that("multiplication works", {
  skip_if_no_sudachi()
  install_sudachipy()
  expect_equal(
    sum(grepl("r-sudachipy", reticulate::conda_list()$name)),
    1L
  )
})
