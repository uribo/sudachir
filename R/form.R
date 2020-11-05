#' Parse tokenized input text
#'
#' @inheritParams tokenizer
#' @param type return form. One of the following "surface", "dictionary",
#' "normalized", "reading" or "part_of_speech".
#' @param pos Include part of speech information with object name.
#' @examples
#' \dontrun{
#' form("Tokyo", mode = "B", type = "normalized")
#' form("Osaka", mode = "B", type = "surface")
#' form("Hokkaido", mode = "C", type = "part_of_speech")
#' }
#' @export
form <- function(x, mode, type, pos = TRUE) {
  type <-
    rlang::arg_match(type,
                     c("surface",
                       "dictionary",
                       "normalized",
                       "reading",
                       "part_of_speech"))
  fn <-
    switch (type,
            "surface" = "surface",
            "dictionary" = "dictionary_form",
            "normalized" = "normalized_form",
            "reading" = "reading_form",
            "part_of_speech" = "part_of_speech")
  purrr::map(tokenizer(x, mode),
             form_vec,
             type = fn,
             pos = pos)
}

form_vec <- function(x, type, pos = TRUE) {
  type <-
    rlang::arg_match(type,
                     c("surface",
                       "dictionary_form",
                       "normalized_form",
                       "reading_form",
                       "part_of_speech"))
  if (type != "part_of_speech") {
    res <-
      purrr::map_chr(seq.int(reticulate::py_len(x)),
                     ~ purrr::pluck(x[.x - 1],
                                    type) %>% {
                                      .()
                                    })
    if (pos == TRUE) {
      res <-
        purrr::set_names(
        res,
        purrr::map_chr(
          seq.int(reticulate::py_len(x)),
          ~ x[.x - 1]$part_of_speech()[1]))
    }
  } else {
    res <-
      purrr::map(seq.int(reticulate::py_len(x)),
                 ~ purrr::pluck(x[.x - 1],
                                type) %>% {
                                  .()
                                })
  }
  res
}
