#' Create virtualenv env used by sudachir
#' @param python_version Python version to use
#' within the virtualenv environment created.
#' SudachiPy requires Python 3.6 or higher to install.
create_sudachipy_env <- function(python_version = "3.9.12") {
  if (!reticulate::virtualenv_exists("r-sudachipy")) {
    if (as.numeric_version(python_version) < 3.6) {
      rlang::abort("SudachiPy requires Python 3.6 or higher to install.")
    }
    reticulate::virtualenv_create(
      envname = "r-sudachipy",
      version = python_version
    )
  } else {
    rlang::inform(cli::col_green("r-sudachipy already exists."))
  }
}

#' Install SudachiPy
#'
#' Install SudachiPy to virtualenv virtual environment.
#' As a one-time setup step, you can run
#' `install_sudachipy()` to install all dependencies.
#'
#' `install_sudachipy()` requires Python and virtualenv installed.
#' See <https://www.python.org/getit/>.
#' @examples
#' \dontrun{
#' install_sudachipy()
#' }
#' @export
install_sudachipy <- function() {
  create_sudachipy_env()
  sudachipy_packages <-
    c(
      paste0("sudachipy", ">=", "0.6.6"),
      "sudachidict_core", "pandas"
    )
  reticulate::virtualenv_install(
    envname = "r-sudachipy",
    packages = sudachipy_packages
  )
  cat(
    cli::col_green("\nInstallation complete.\n"),
    cli::col_grey(
      "Restart R, activate environment with `",
      cli::style_bold('reticulate::use_virtualenv(virtualenv = "r-sudachipy", required = TRUE)')
    )
  )
  if (rstudioapi::hasFun("restartSession")) {
    rstudioapi::restartSession()
  }
  invisible(NULL)
}

#' Remove SudachiPy
#'
#' Uninstalls SudachiPy by removing the virtualenv environment.
#' @examples
#' \dontrun{
#' install_sudachipy()
#' remove_sudachipy()
#' }
#' @export
remove_sudachipy <- function() {
  reticulate::virtualenv_remove(
    envname = "r-sudachipy"
  )
}
