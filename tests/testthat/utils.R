skip_if_no_sudachi <- function() {
  if (!all(
    reticulate::py_module_available("sudachipy"),
    reticulate::py_module_available("sudachidict_core")
  )) {
    skip("SudachiPy not available for testing")
  }
}
