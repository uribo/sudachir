#' Sudachi tokenizer
#'
#' @param x Input text vectors
#' @param mode Select split mode (A, B, C)
#' @export
tokenizer <- function(x, mode) {
  tokenizer <- reticulate::import("sudachipy.tokenizer")
  dictionary <- reticulate::import("sudachipy.dictionary")
  tokenizer_obj <- dictionary$Dictionary()$create()
  mode <-
    switch (mode,
            "A" = tokenizer$Tokenizer$SplitMode$A,
            "B" = tokenizer$Tokenizer$SplitMode$B,
            "C" = tokenizer$Tokenizer$SplitMode$C)
  res <-
    purrr::map(x,
               ~ tokenizer_vector(.x, mode, tokenizer_obj))
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

