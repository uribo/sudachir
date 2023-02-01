#' Rebuild 'Sudachi' tokenizer
#'
#' @param mode Split mode (A, B, C)
#' @param dict_type Dictionary type.
#' @param config_path Absolute path to `sudachi.json`.
#' @return Returns a binding to the instance of `<sudachipy.tokenizer.Tokenizer>`.
#' @examples
#' \dontrun{
#' tokenizer <- rebuild_tokenizer()
#' tokenize_to_df("Tokyo, Japan", instance = tokenizer)
#' }
#' @export
rebuild_tokenizer <- function(mode = c("C", "B", "A"),
                              dict_type = c("core", "small", "full"),
                              config_path = NULL) {
  mode <- rlang::arg_match(mode)
  dict_type <- rlang::arg_match(dict_type)

  sudachi <- reticulate::import("sudachipy")
  mode <- switch(mode,
    "A" = sudachi$SplitMode$A,
    "B" = sudachi$SplitMode$B,
    "C" = sudachi$SplitMode$C
  )
  if (!is.null(config_path)) {
    sudachi$Dictionary(config_path = file.path(config_path))$create(mode)
  } else {
    sudachi$Dictionary(dict_type = dict_type)$create(mode)
  }
}

#' Package internal environment
#' @noRd
.pkgenv <- rlang::env()

#' Call 'Sudachi' tokenizer
#'
#' @param x A data.frame like object or a character vector to be tokenized.
#' @param text_field Column name where to get texts to be tokenized.
#' @param docid_field Column name where to get identifiers of texts.
#' @param instance A binding to the instance of `<sudachipy.tokenizer.Tokenizer>`.
#' If you already have a tokenizer instance,
#' you can improve performance by providing a predefined instance.
#' @keywords internal
tokenize <- function(x,
                     text_field,
                     docid_field,
                     instance) {
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
  reticulate::source_python(
    system.file("wrapper.py", package = "sudachir"),
    envir = .pkgenv,
    convert = FALSE
  )
  UseMethod("tokenize", x)
}

#' @noRd
tokenize.character <- function(x, text_field, docid_field, instance) {
  doc_id <- names(x)
  if (is.null(doc_id)) {
    doc_id <- seq_along(x)
  }
  .pkgenv$tokenize_to_pd(
    data.frame(
      doc_id = doc_id,
      text = x
    ),
    text_field = "text",
    docid_field = "doc_id",
    instance = instance
  ) %>%
    reticulate::py_to_r() %>%
    dplyr::mutate(sentence_id = .data$sentence_id + 1) %>%
    dplyr::as_tibble()
}

#' @noRd
tokenize.default <- function(x, text_field, docid_field, instance) {
  tbl <-
    dplyr::rename(x, text = !!text_field, doc_id = !!docid_field) %>%
    dplyr::as_tibble()
  tbl <-
    .pkgenv$tokenize_to_pd(
      tbl,
      text_field = "text",
      docid_field = "doc_id",
      instance = instance
    ) %>%
      reticulate::py_to_r() %>%
      dplyr::mutate(sentence_id = .data$sentence_id + 1)
  dplyr::select(x, -!!text_field) %>%
    dplyr::rename(doc_id = !!docid_field) %>%
    dplyr::left_join(tbl, by = "doc_id") %>%
    dplyr::as_tibble()
}

#' Create a data.frame of tokens
#'
#' @inheritParams tokenize
#' @param into Column names of features.
#' @param col_select Character or integer vector of column names
#' that kept in the return value. When passed as `NULL`,
#' returns comma-separated features as is.
#' @param ... Currently not used.
#' @return A tibble.
#' @examples
#' \dontrun{
#' tokenize_to_df(
#'   "Tokyo, Japan",
#'   into = dict_features("en"),
#'   col_select = c("pos1", "pos2")
#' )
#' }
#' @export
tokenize_to_df <- function(x,
                           text_field = "text",
                           docid_field = "doc_id",
                           into = dict_features(),
                           col_select = seq_along(into),
                           instance = rebuild_tokenizer(),
                           ...) {
  text_field <- rlang::enquo(text_field)
  docid_field <- rlang::enquo(docid_field)

  res <- tokenize(x, text_field, docid_field, instance)

  if (is.null(col_select)) {
    return(res)
  }
  audubon::prettify(
    res,
    into = into,
    col_select = col_select
  )
}
