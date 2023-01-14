#' Rebuild 'Sudachi' tokenizer
#'
#' @param mode Split mode (A, B, C)
#' @param dict_type Dictionary type.
#' @param config_path Absolute path to `sudachi.json`
#' @return Returns a binding to the instance of `<sudachipy.tokenizer.Tokenizer>`.
#' @examples
#' \dontrun{
#' tokenizer <- rebuild_tokenizer()
#' as_tokens("Tokyo, Japan", instance = tokenizer)
#' }
#' @export
rebuild_tokenizer <- function(mode = c("C", "B", "A"),
                              dict_type = c("core", "small", "full"),
                              config_path = NULL) {
  mode <- rlang::arg_match(mode)
  dict_type <- rlang::arg_match(dict_type)

  tokenizer <- reticulate::import("sudachipy.tokenizer")
  mode <- switch(mode,
    "A" = tokenizer$Tokenizer$SplitMode$A,
    "B" = tokenizer$Tokenizer$SplitMode$B,
    "C" = tokenizer$Tokenizer$SplitMode$C
  )
  dictionary <- reticulate::import("sudachipy.dictionary")
  if (!is.null(config_path)) {
    dictionary$Dictionary(config_path = file.path(config_path))$create(mode)
  } else {
    dictionary$Dictionary(dict_type = dict_type)$create(mode)
  }
}

#' Package internal environment
#' @noRd
.pkgenv <- rlang::env()

#' Call 'Sudachi' tokenizer
#'
#' @param sentence Input text vectors.
#' @param doc_id Identifier of input sentences.
#' @param instance This is optional; if you already have an instance of
#' `<sudachipy.tokenizer.Tokenizer>`, supplying the predefined
#' instance would improve the performance.
#' @examples
#' \dontrun{
#' as_tokens("Tokyo, Japan")
#' }
#' @export
as_tokens <- function(sentence,
                      doc_id = seq_along(sentence),
                      instance = rebuild_tokenizer()) {
  reticulate::source_python(
    system.file("wrapper.py", package = "sudachir"),
    envir = .pkgenv,
    convert = FALSE
  )
  .pkgenv$tokenize_to_pd(
    data.frame(
      doc_id = doc_id,
      text = sentence
    ),
    text_field = "text",
    docid_field = "doc_id",
    instance = instance
  ) %>%
    reticulate::py_to_r() %>%
    dplyr::as_tibble()
}

#' Create a data.frame of tokens
#'
#' @inheritParams as_tokens
#' @param mode Split mode (A, B, C)
#' @param into Column names of features.
#' @param col_select Character or integer vector of column names
#' that kept in the returned value.
#' @param ... Currently not used.
#' @examples
#' \dontrun{
#' tokenize_to_df(
#'   "Tokyo, Japan",
#'   mode = "A",
#'   into = dict_features("en"),
#'   col_select = c("POS1", "POS2")
#' )
#' }
#' @export
tokenize_to_df <- function(sentence,
                           doc_id = seq_along(sentence),
                           mode = c("C", "B", "A"),
                           into = dict_features(),
                           col_select = seq_along(into),
                           instance = NULL,
                           ...) {
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
    instance <- rebuild_tokenizer(mode)
  }

  as_tokens(sentence, doc_id, instance) %>%
    audubon::prettify(
      into = into,
      col_select = col_select
    )
}
