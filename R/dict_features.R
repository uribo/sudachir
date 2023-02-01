#' Get dictionary's features
#' @param lang Dictionary features label; one of "ja" or "en".
#' @examples
#' dict_features("en")
#' @export
dict_features <- function(lang = c("ja", "en")) {
  lang <- rlang::arg_match(lang)
  switch(lang,
    "ja" = c(
      paste0(intToUtf8(c(21697, 35422)), seq_len(4)),
      intToUtf8(c(27963, 29992, 22411)),
      intToUtf8(c(27963, 29992, 24418))
    ),
    "en" = c(
      "pos1", "pos2", "pos3", "pos4",
      "cType", "cForm"
    )
  )
}
