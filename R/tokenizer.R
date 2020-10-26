#' @noRd
.tokenizer <- (function() {
  if (!exists("instance")) instance <- NULL
  function(obj = NULL) {
    if (!is.null(obj)) instance <<- obj
    return(instance)
  }
})()

#' Rebuild tokenizer
#'
#' @param config_path Absolute path to `sudachi.json`
#' @return Returns a binding to the instance of `<sudachipy.tokenizer.Tokenizer>` invisibly
#' @export
rebuild_tokenizer <- function(config_path = NULL) {
  dictionary <- reticulate::import("sudachipy.dictionary")
  if (!is.null(config_path)) {
    .tokenizer(dictionary$Dictionary()$create(config_path = file.path(config_path)))
  } else {
    .tokenizer(dictionary$Dictionary()$create())
  }
  return(invisible(.tokenizer()))
}

#' Sudachi tokenizer
#'
#' @param x Input text vectors
#' @param mode Select split mode (A, B, C)
#' @export
tokenizer <- function(x, mode) {
  if (is.null(.tokenizer())) {
    rebuild_tokenizer()
  }
  mode <-
    switch (mode,
            "A" = .tokenizer()$SplitMode$A,
            "B" = .tokenizer()$SplitMode$B,
            "C" = .tokenizer()$SplitMode$C)
  res <-
    purrr::map(x,
               ~ tokenizer_vector(.x, mode, .tokenizer()))
  purrr::map(
    res,
    ~ cat(cli::col_cyan(
      glue::glue("Parsed to {n} {token}\n\n",
                 n = reticulate::py_len(.x),
                 token = ifelse(reticulate::py_len(.x) > 1L,
                                          "tokens",
                                          "token")))))
  res
}

tokenizer_vector <- function(x, mode, tokenizer_obj) {
  tokenizer_obj$tokenize(x, mode)
}

#' Create tokenizing data.frame using Sudachi
#'
#' @inheritParams tokenizer
#' @export
tokenize_to_df <- function(x, mode) {
  purrr::map_dfr(
    tokenizer(x, mode = mode),
    ~ tokenize_to_df_vec(.x),
    .id = "id")
}

tokenize_to_df_vec <- function(m) {
  dplyr::bind_cols(
    purrr::map_dfr(seq.int(reticulate::py_len(m)), ~
                     tibble::tibble(surface = m[. - 1]$surface(),
                                    dic_form = m[. - 1]$dictionary_form(),
                                    normalized_form = m[. - 1]$normalized_form(),
                                    reading = m[. - 1]$reading_form()
                                    #,
                                    #part_of_speech = m[. - 1]$part_of_speech()
                     )),
    purrr::map_dfr(
      seq.int(reticulate::py_len(m)),
      ~ tibble::as_tibble(
        purrr::set_names(
          as.data.frame(
            t(
              data.frame(x = m[.x - 1]$part_of_speech()))),
              c(paste0(intToUtf8(c(21697, 35422)),
                       seq_len(4)),
                intToUtf8(c(27963, 29992, 22411)),
                intToUtf8(c(27963, 29992, 24418))))) %>%
        dplyr::mutate(dplyr::across(tidyselect::everything(),
                                    .fns = dplyr::na_if,
                                    y = "*"))))
}

