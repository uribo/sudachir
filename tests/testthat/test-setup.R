context("setup")

source("utils.R")

test_that("multiplication works", {
  skip_on_cran()
  skip_on_os("windows")

  install_sudachipy()
  expect_equal(
    sum(reticulate::virtualenv_exists("r-sudachipy")),
    1L
  )
})
