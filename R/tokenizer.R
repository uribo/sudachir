#' Sudachi tokenizer
#'
#' The old `tokenizer()` function was removed.
#'
#' In general, users should not directly touch
#' the `<sudachipy.tokenizer.Tokenizer>` and its `MorphemeList` objects.
#' If you particularly want to access those objects,
#' use the returned value of `rebuild_tokenizer()` function.
#'
#' @name sudachir-defunct
#' @param ... Not used.
#' @export
tokenizer <- function(...) {
  .Defunct("tokenize_to_df", package = "sudachir")
}
