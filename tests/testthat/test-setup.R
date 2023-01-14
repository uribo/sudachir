context("setup")

skip_on_cran()
skip_on_os("windows")

source("utils.R")

test_that("multiplication works", {
  install_sudachipy()
  expect_equal(
    sum(reticulate::virtualenv_exists("r-sudachipy")),
    1L
  )
})
