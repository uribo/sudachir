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
#' as_phrase(type = "surface")
#' }
#' @aliases form
#' @export
as_phrase <- function(tbl, type, pos = TRUE, ...) {
  type <-
    rlang::arg_match(
      type,
      c(
        "surface",
        "dictionary",
        "normalized",
        "reading"
      )
    )
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

  names(res) <- unique(dplyr::pull(tbl, "doc_id"))
  res
}

#' Create a list of tokens
#'
#' @inheritParams as_phrase
#' @examples
#' \dontrun{
#' tokenize_to_df(
#'   "Tokyo, Japan",
#'   mode = "A"
#' ) |>
#' form(type = "surface")
#' }
#' @export
form <- as_phrase
