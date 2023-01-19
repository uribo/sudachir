context("form")

source(test_path("utils.R"))

test_that("form works", {
  skip_on_cran()
  # skip_on_os("windows")
  skip_if_no_sudachi()

  tokenizer <- rebuild_tokenizer(dict_type = "core")

  surface <- form(c(test = "Tokyo"), type = "surface", instance = tokenizer)
  expect_named(surface, "test")
  expect_named(surface[[1]], enc2utf8("\u540d\u8a5e"))
  expect_equal(unname(surface[[1]]), "Tokyo")

  reading <- form("Tokyo", type = "reading", pos = FALSE, instance = tokenizer)
  expect_equal(reading[[1]], enc2utf8("\u30c8\u30a6\u30ad\u30e7\u30a6"))

  dictionary <- form("Tokyo", type = "dictionary", pos = FALSE, instance = tokenizer)
  expect_length(dictionary, 1L)

  normalized <- form("Tokyo", type = "normalized", pos = FALSE, instance = tokenizer)
  expect_length(normalized, 1L)
})
