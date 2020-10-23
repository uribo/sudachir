#' Parse tokenized input text
#'
#' @inheritParams tokenizer
#' @param type return form. "dictionary" or "normalized".
#' @export
form <- function(x, mode, type) {
  type <-
    rlang::arg_match(type,
                     c("dictionary", "normalized"))
  fn <-
    switch (type,
            "dictionary" = dictionary_form_vec,
            "normalized" = normalized_form_vec
    )
  purrr::map(tokenizer(x, mode),
             fn)
}

dictionary_form_vec <- function(x) {
  purrr::set_names(
    purrr::map_chr(seq.int(reticulate::py_len(x)),
                   ~ x[.x - 1]$dictionary_form()),
    purrr::map_chr(
      seq.int(reticulate::py_len(x)),
      ~ x[.x - 1]$part_of_speech()[1]
    ))
}

normalized_form_vec <- function(x) {
  purrr::map_chr(seq.int(reticulate::py_len(x)),
                 ~ x[.x - 1]$normalized_form())
}
