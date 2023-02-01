context("setup")

test_that("multiplication works", {
  skip_on_cran()
  skip_on_os("windows")
  skip_on_ci() ## FIXME: needs testing on ci?

  install_sudachipy()
  expect_equal(
    sum(reticulate::virtualenv_exists("r-sudachipy")),
    1L
  )
})
