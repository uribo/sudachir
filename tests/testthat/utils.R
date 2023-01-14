skip_if_no_sudachi <- function() {
  skip_if_not(reticulate::py_available(TRUE), "Python is not available.")
  if (!all(
    reticulate::py_module_available("sudachipy"),
    reticulate::py_module_available("sudachidict_core")
  )) {
    skip("SudachiPy not available for testing.")
  } else {
    invisible(NULL)
  }
}
