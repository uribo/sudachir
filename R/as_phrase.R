#' Create a list of tokens
#'
#' @param tbl A data.frame of tokens out of `tokenize_to_df()`.
#' @param type Preference for the form of returned tokens.
#' Pick one of "surface", "dictionary", "normalized", or "reading".
#' @param pos When supplied with `TRUE`, this function
#' uses the part-of-speech information as the name of the returned tokens.
#' @param ... Passed to `dict_features()`.
#' @examples
#' \dontrun{
#' tokenize_to_df(
#'   "Tokyo, Japan",
#'   mode = "A"
#' ) |>
#'   as_phrase(type = "surface")
#' }
#' @export
as_phrase <- function(tbl, type, pos = TRUE, ...) {
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
    rlang::abort("`type=\"part_of_speech\"` is defuncted.")
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
#' This function is a shorthand of `tokenize_to_df() |> as_phrase()`.
#'
#' @inheritParams tokenize_to_df
#' @param ... Passed to `as_phrase`.
#' @examples
#' \dontrun{
#' form(
#'   "Tokyo, Japan",
#'   mode = "A",
#'   type = "surface"
#' )
#' }
#' @export
form <- function(sentence,
                 doc_id = seq_along(sentence),
                 mode = c("C", "B", "A"),
                 into = dict_features(),
                 col_select = seq_along(into),
                 instance = NULL,
                 ...) {
  tokenize_to_df(
    sentence,
    doc_id = doc_id,
    mode = mode,
    into = into,
    col_select = col_select,
    instance = instance
  ) %>%
    as_phrase(...)
}
