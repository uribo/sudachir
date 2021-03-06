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
    dictionary$Dictionary(config_path = file.path(config_path))
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
    instance <-
      instance$create(mode = mode)
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
  purrr::map(
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
  purrr::imap_dfr(
    tokenizer(x, mode = mode, instance = instance),
    ~ tokenize_to_df_vec(.x, .y)
  )
}

tokenize_to_df_vec <- function(m, i) {
  dplyr::bind_cols(
    tibble::tibble(id = i),
    purrr::imap_dfr(
      seq.int(reticulate::py_len(m)),
      ~ tibble::tibble(
        token_id = .y,
        surface = m[.x - 1]$surface(),
        dic_form = m[.x - 1]$dictionary_form(),
        normalized_form = m[.x - 1]$normalized_form(),
        reading = m[.x - 1]$reading_form()
      )
    ),
    purrr::map_dfr(
      seq.int(reticulate::py_len(m)),
      ~ purrr::map_dfr(purrr::set_names(
        as.data.frame(
          t(
            data.frame(x = m[.x - 1]$part_of_speech())
          )
        ),
        c(
          paste0(
            intToUtf8(c(21697, 35422)),
            seq_len(4)
          ),
          intToUtf8(c(27963, 29992, 22411)),
          intToUtf8(c(27963, 29992, 24418))
        )
      ),
      dplyr::na_if,
      y = "*"
      )
    )
  )
}
