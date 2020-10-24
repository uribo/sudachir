skip_if_no_sudachi <- function() {
  if (!reticulate::py_module_available("sudachipy"))
    skip("SudachiPy not available for testing")
}
