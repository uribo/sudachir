#' Create a list of tokens
#'
#' @param tbl A data.frame of tokens out of `tokenize_to_df()`.
#' @param type Preference for the format of returned tokens.
#' Pick one of "surface", "dictionary", "normalized", or "reading".
#' @param pos When passed as `TRUE`, this function
#' uses the part-of-speech information as the name of the returned tokens.
#' @param ... Passed to `dict_features()`.
#' @return A named list of character vectors.
#' @examples
#' \dontrun{
#' tokenize_to_df("Tokyo, Japan") |>
#'   as_tokens(type = "surface")
#' }
#' @export
as_tokens <- function(tbl, type, pos = TRUE, ...) {
  type <-
    rlang::arg_match(
      type,
      c(
        "surface",
        "dictionary",
        "normalized",
        "reading",
        "part_of_speech"
      )
    )
  if (type == "part_of_speech") {
    rlang::abort("`type=\"part_of_speech\"` is now defunct.")
  }

  fn <-
    switch(type,
      "surface" = "surface",
      "dictionary" = "dictionary_form",
      "normalized" = "normalized_form",
      "reading" = "reading_form"
    )

  tbl <- dplyr::ungroup(tbl) %>%
    dplyr::group_by(.data$doc_id)

  if (isTRUE(pos)) {
    res <- dplyr::group_map(tbl, function(tbl, grp) {
      dplyr::pull(tbl, fn, dict_features(...)[1])
    })
  } else {
    res <- dplyr::group_map(tbl, function(tbl, grp) {
      dplyr::pull(tbl, fn)
    })
  }

  col_u <- dplyr::pull(tbl, "doc_id")
  if (is.factor(col_u)) {
    col_u <- levels(col_u)
  } else {
    col_u <- unique(col_u)
  }
  names(res) <- col_u
  res
}

#' Create a list of tokens
#'
#' This function is a shorthand of `tokenize_to_df() |> as_tokens()`.
#'
#' @inheritParams tokenize
#' @param ... Passed to `as_tokens()`.
#' @return A named list of character vectors.
#' @examples
#' \dontrun{
#' form(
#'   "Tokyo, Japan",
#'   type = "surface"
#' )
#' }
#' @export
form <- function(x,
                 text_field = "text",
                 docid_field = "doc_id",
                 instance = rebuild_tokenizer(),
                 ...) {
  text_field <- rlang::enquo(text_field)
  docid_field <- rlang::enquo(docid_field)

  tokenize(x, text_field, docid_field, instance) %>%
    audubon::prettify(into = dict_features(), col_select = 1) %>%
    as_tokens(...)
}
