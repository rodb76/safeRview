# This single file sources your ui.R and server.R
# and handles package installation on the server.

# --- 1. Package Management ---

# Check if 'remotes' is installed, install if not
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

# Check if 'safeRview' is installed, install from GitHub if not
if (!requireNamespace("safeRview", quietly = TRUE)) {
  remotes::install_github("rodb76/safeRview") # <-- Make sure this is your GitHub username/repo
}

# --- 2. Load Libraries ---

library(shiny)
library(safeRview)
library(plotly)
library(DT)
library(dplyr)

# --- 3. Source UI and Server ---

source("ui.R", local = TRUE)
source("server.R", local = TRUE)

# --- 4. Run the App ---

shinyApp(ui = shinyUI, server = shinyServer)
