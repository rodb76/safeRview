#' Launch the safeRview Shiny App
#'
#' @description
#' Opens the interactive Shiny dashboard for exploring adverse event data.
#'
#' @export
#' @importFrom shiny runApp
#'
#' @examples
#' \dontrun{
#'   launch_app()
#' }
launch_app <- function() {
  # Find the directory of the app within the installed package
  app_dir <- system.file("shiny-app", package = "safeRview")

  if (app_dir == "") {
    stop("Could not find the 'shiny-app' directory in the 'safeRview' package.
         Try re-installing the package.", call. = FALSE)
  }

  # Run the app
  shiny::runApp(app_dir, display.mode = "normal")
}
