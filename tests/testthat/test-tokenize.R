context("tokenize")

source("utils.R")

test_that("tokenize", {
  skip_if_no_sudachi()
  res <-
    tokenizer("Tokyo, Japan", mode = "A")
  expect_length(res,
                1L)
  expect_output(
    tokenizer("Tokyo, Japan", mode = "A"),
    "Parsed to 4 tokens"
  )
  res <-
    tokenize_to_df("Tokyo, Japan", mode = "B")
  expect_equal(
    dim(res),
    c(4, 11)
  )
})
