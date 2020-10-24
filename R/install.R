#' Create conda env used by sudachir
#' @param python_version Python version to use within conda environment created
#' for installing the SudachiPy It requires version 3.5 or higher.
create_sudachipy_env <- function(python_version = 3.9) {
  if (sum(grepl("r-sudachipy", reticulate::conda_list()$name)) == 0) {
    if (python_version < 3.5)
      rlang::abort("SudachiPy requirements for python 3.5 or higher.")
    packages <-
      c(paste("python",
              python_version, sep = "="))
    reticulate::conda_create(envname = "r-sudachipy",
                             packages = packages)
  } else {
    rlang::inform(cli::col_green("r-sudachipy already exist."))
  }
}

#' Install SudachiPy
#'
#' Install SudachiPy to Conda virtual environment. As a one-time setup step,
#' you most run `install_sudachipy()` to install all dependencies.
#'
#' `install_sudachipy()` requires Python and Conda to be installed.
#' See <https://www.python.org/getit/> and
#' <https://docs.conda.io/projects/conda/en/latest/user-guide/install/>.
#' @examples
#' \dontrun{
#' install_sudachipy()
#' }
#' @export
install_sudachipy <- function() {
  create_sudachipy_env()
  sudachipy_version <-
    c(
      paste0("sudachipy", "==", "0.4.9"),
      "sudachidict_core") # nolint use latest dictionary
  reticulate::conda_install(envname = "r-sudachipy",
                            packages = sudachipy_version,
                            pip = TRUE)
  cat(cli::col_green('\nInstallation complete.\n'),
      cli::col_grey('Restarte to R, activate environment with `',
                    cli::style_bold('reticulate::use_condaenv(condaenv = "r-sudachipy", required = TRUE)')))
  if (rstudioapi::hasFun("restartSession"))
    rstudioapi::restartSession()
  invisible(NULL)
}

#' Remove SudachiPy
#'
#' Uninstalls SudachiPy by removing the Conda environment.
#' @examples
#' \dontrun{
#' install_sudachipy()
#' remove_sudachipy()
#' }
#' @export
remove_sudachipy <- function() {
  reticulate::conda_remove(envname = "r-sudachipy",
                           packages = "sudachipy")
}
