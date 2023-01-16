skip_if_no_sudachi <- function(envname = "r-sudachipy") {
  if (!reticulate::py_available() && reticulate::virtualenv_exists(envname)) {
    reticulate::use_virtualenv(envname)
  }
  if (!all(
    reticulate::py_module_available("sudachipy"),
    reticulate::py_module_available("sudachidict_core"),
    reticulate::py_module_available("pandas")
  )) {
    skip("SudachiPy not available for testing.")
  } else {
    invisible(NULL)
  }
}
