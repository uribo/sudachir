#' 'Sudachi' tokenizer
#'
#' The old `tokenizer()` function was removed.
#'
#' In general, users should not directly touch
#' the `<sudachipy.tokenizer.Tokenizer>` and its `MorphemeList` objects.
#' If you must access those objects,
#' use the return value of the `rebuild_tokenizer()` function.
#' @name sudachir-defunct
#' @param ... Not used.
#' @export
tokenizer <- function(...) {
  .Defunct("tokenize_to_df", package = "sudachir")
}
