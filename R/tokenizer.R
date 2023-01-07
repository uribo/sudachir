#' Rebuild tokenizer
#'
#' @param dict_type Dictionary type.
#' @param config_path Absolute path to `sudachi.json`
#' @return Returns a binding to the instance of `<sudachipy.tokenizer.Tokenizer>`.
#' @examples
#' \dontrun{
#' instance <- rebuild_tokenizer()
#' form("Tokyo, Japan", "A", "surface", instance = instance)
#' }
#' @export
rebuild_tokenizer <- function(dict_type = c("core", "small", "full"),
                              config_path = NULL) {
  dict_type <- rlang::arg_match(dict_type)
  dictionary <- reticulate::import("sudachipy.dictionary")
  if (!is.null(config_path)) {
    dictionary$Dictionary(config_path = file.path(config_path))$create()
  } else {
    dictionary$Dictionary(dict_type = dict_type)$create()
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
#' @keywords internal
tokenizer <- function(x, mode = "A", instance = NULL, ...) {
  rlang::arg_match(
    mode,
    c("A", "B", "C")
  )
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
    instance <- rebuild_tokenizer()
  }
  tokenizer <- reticulate::import("sudachipy.tokenizer")
  mode <- switch(mode,
    "A" = tokenizer$Tokenizer$SplitMode$A,
    "B" = tokenizer$Tokenizer$SplitMode$B,
    "C" = tokenizer$Tokenizer$SplitMode$C
  )
  purrr::map(x, function(.x) {
    instance$tokenize(.x, mode)
  })
}

#' Create tokenizing data.frame using Sudachi
#'
#' @inheritParams tokenizer
#' @param into Column names out of part-of-speech tags.
#' @param col_select Character or integer vector of colnames
#' that kept in the returned value.
#' @examples
#' \dontrun{
#' tokenize_to_df(
#'   "Tokyo, Japan",
#'   "A",
#'   into = dict_features("en"),
#'   col_select = c("POS1", "POS2")
#' )
#' }
#' @export
tokenize_to_df <- function(x,
                           mode,
                           into = dict_features(),
                           col_select = seq_along(into),
                           instance = NULL) {
  tokenize_to_df_vec(
    tokenizer(x, mode = mode, instance = instance),
    into = into,
    col_select = col_select
  )
}

to_py_mlist <- function(m, flatten = TRUE) {
  res <-
    list(
      .x = purrr::map2(
        seq.int(length(m)),
        purrr::map_dbl(seq.int(length(m)), function(.x) {
          m[[.x]]$size()
        }),
        function(.x, .y) rep(.x, times = .y)
      ),
      .y = purrr::map(
        seq.int(length(m)),
        function(.x) {
          seq.int(m[[.x]]$size())
        }
      )
    )
  if (!flatten) {
    return(res)
  }
  purrr::map(res, purrr::flatten_dbl)
}

tokenize_to_df_vec <- function(m,
                               into = dict_features(),
                               col_select = seq_along(into)) {
  if (is.numeric(col_select) && max(col_select) <= length(into)) {
    col_select <- which(seq_along(into) %in% col_select, arr.ind = TRUE)
  } else {
    col_select <- which(into %in% col_select, arr.ind = TRUE)
  }
  if (rlang::is_empty(col_select)) {
    rlang::abort("Invalid columns have been selected.")
  }
  py_m_list <- to_py_mlist(m)

  doc_id <- tibble::tibble(doc_id = py_m_list$.x)

  tokens <-
    purrr::map2(
      .x = py_m_list$.x,
      .y = py_m_list$.y,
      function(.x, .y) {
        tibble::tibble(
          token_id = .y,
          surface = m[[.x]][.y - 1]$surface(),
          dic_form = m[[.x]][.y - 1]$dictionary_form(),
          normalized_form = m[[.x]][.y - 1]$normalized_form(),
          reading = m[[.x]][.y - 1]$reading_form()
        )
      }
    ) |>
    purrr::list_rbind()

  features <-
    purrr::map2(
      py_m_list$.x,
      py_m_list$.y,
      function(.x, .y) {
        purrr::set_names(
          unlist(m[[.x]][.y - 1]$part_of_speech())[col_select],
          into[col_select]
        ) |>
          tibble::enframe() |>
          tidyr::pivot_wider(names_from = .data$name, values_from = .data$value)
      }
    ) |>
    purrr::list_rbind() |>
    dplyr::mutate(dplyr::across(where(is.character), ~ dplyr::na_if(., "*")))

  dplyr::bind_cols(
    doc_id,
    tokens,
    features
  )
}
