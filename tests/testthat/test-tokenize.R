context("tokenize")

source("utils.R")

test_that("tokenize", {
  skip_on_os("windows")
  skip_if_no_sudachi()

  res <-
    tokenizer("Tokyo, Japan", mode = "A")
  expect_length(
    res,
    1L
  )
  res <-
    tokenize_to_df("Tokyo, Japan", mode = "B")
  expect_equal(
    dim(res),
    c(4, 12)
  )
})
