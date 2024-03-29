context("tokenize")

source(test_path("utils.R"))

test_that("tokenize works", {
  skip_on_cran()
  # skip_on_os("windows")
  skip_if_no_sudachi()

  tokenizer <- rebuild_tokenizer(dict_type = "core")
  expect_s3_class(
    tokenizer,
    c("sudachipy.tokenizer.Tokenizer", "python.builtin.object")
  )

  res <-
    tokenize_to_df(
      c(a = "Tokyo", b = "Japan"),
      into = dict_features("en"),
      instance = tokenizer
    )
  expect_equal(res[["doc_id"]], c("a", "b"))
  expect_equal(dim(res), c(2, 13))

  res <-
    tokenize_to_df(
      c("Tokyo", "Japan"),
      into = dict_features("en"),
      col_select = c(1, 2, 3),
      instance = tokenizer
    )
  expect_equal(res[["doc_id"]], c(1, 2))
  expect_equal(dim(res), c(2, 10))

  res <-
    tokenize_to_df(
      c("Tokyo", "Japan"),
      into = dict_features("en"),
      col_select = NULL,
      instance = tokenizer
    )
  expect_equal(res[["doc_id"]], c(1, 2))
  expect_equal(dim(res), c(2, 8))

  res <-
    tokenize_to_df(
      data.frame(
        doc_id = c(1, 2),
        text = c("Tokyo", "Japan")
      ),
      into = dict_features("en"),
      col_select = NULL,
      instance = tokenizer
    )
  expect_equal(res[["doc_id"]], c(1, 2))
  expect_equal(dim(res), c(2, 8))
})
