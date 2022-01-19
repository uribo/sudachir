#' Rebuild tokenizer
#'
#' @param config_path Absolute path to `sudachi.json`
#' @return Returns a binding to the instance of `<sudachipy.tokenizer.Tokenizer>`.
#' @examples
#' \dontrun{
#' instance <- rebuild_tokenizer()
#' tokenizer("Tokyo, Japan", mode = "A", instance)
#' }
#' @export
rebuild_tokenizer <- function(config_path = NULL) {
  dictionary <- reticulate::import("sudachipy.dictionary")
  if (!is.null(config_path)) {
    dictionary$Dictionary(config_path = file.path(config_path))$create()
  } else {
    dictionary$Dictionary()$create()
  }
}

#' Sudachi tokenizer
#'
#' @param x Input text vectors
#' @param mode Select split mode (A, B, C)
#' @param instance This is optional if you already have an instance of
#' `<sudachipy.tokenizer.Tokenizer>` Giving them a predefined
#' instance will speed up their execution.
#' @param ... path to another functions.
#' @examples
#' \dontrun{
#' tokenizer("Tokyo, Japan", mode = "A")
#' }
#' @export
tokenizer <- function(x, mode = "A", instance = NULL, ...) {
  rlang::arg_match(mode,
                   c("A", "B", "C"))
  if (!is.null(instance)) {
    if (!identical(
      class(instance),
      c("sudachipy.tokenizer.Tokenizer", "python.builtin.object")
    )) {
      rlang::abort(paste0(
        "Please, set ",
        cli::style_bold("<sudachipy.tokenizer.Tokenizer>"),
        "class object"
      ))
    }
  } else {
    instance <-
      rebuild_tokenizer()
  }
  mode <-
    switch(mode,
           "A" = instance$SplitMode$A,
           "B" = instance$SplitMode$B,
           "C" = instance$SplitMode$C)
  res <-
    purrr::map(
      x,
      ~ instance$tokenize(.x, mode)
    )
  purrr::walk(
    res,
    ~ cat(cli::col_cyan(
      glue::glue("Parsed to {n} {token}\n\n",
        n = reticulate::py_len(.x),
        token = ifelse(reticulate::py_len(.x) > 1L,
          "tokens",
          "token"
        )
      )
    ))
  )
  res
}

#' Create tokenizing data.frame using Sudachi
#'
#' @inheritParams tokenizer
#' @examples
#' \dontrun{
#' tokenizer("Tokyo, Japan", mode = "A")
#' }
#' @export
tokenize_to_df <- function(x, mode, instance = NULL) {
  tokenize_to_df_vec(tokenizer(x, mode = mode, instance = instance))
}

to_py_mlist <- function(m, flatten = TRUE) {
  res <-
    list(
    .x = purrr::map2(
        seq.int(length(m)),
        purrr::map_dbl(
          seq.int(length(m)),
          ~ reticulate::py_len(m[[.x]])),
        ~ rep(.x, times = .y)),
    .y = purrr::map(
        seq.int(length(m)),
        ~ seq.int(reticulate::py_len(m[[.x]]))))
  if (flatten == TRUE) {
    res <-
      purrr::map(
      res,
      purrr::flatten_dbl)
  }
  res
}

tokenize_to_df_vec <- function(m) {
  py_m_list <-
    to_py_mlist(m)
  dplyr::bind_cols(
    tibble::tibble(
      id = py_m_list$.x),
    purrr::map2_dfr(
      .x = py_m_list$.x,
      .y = py_m_list$.y,
      ~ tibble::tibble(
        token_id = .y,
        surface = m[[.x]][.y - 1]$surface(),
        dic_form = m[[.x]][.y - 1]$dictionary_form(),
        normalized_form = m[[.x]][.y - 1]$normalized_form(),
        reading = m[[.x]][.y - 1]$reading_form())),
    dplyr::mutate(
      purrr::map2_dfr(
        py_m_list$.x,
        py_m_list$.y,
        ~ purrr::set_names(
          data.frame(x = m[[.x]][.y - 1]$part_of_speech()),
          c(
            paste0(
              intToUtf8(c(21697, 35422)),
              seq_len(4)),
            intToUtf8(c(27963, 29992, 22411)),
            intToUtf8(c(27963, 29992, 24418))))),
      dplyr::across(.fns = ~dplyr::na_if(.x, y = "*")))
  )
}
