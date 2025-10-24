library(shiny)
library(plotly)

# --- 1. Load Data and Define Choices ---
# This logic must run *outside* the UI definition.
# It runs once when the app starts.
# This requires your 'safeRview' package to be installed.
data(adsl, package = "safeRview")
all_arms <- unique(adsl$ARM)


# --- 2. Define the User Interface ---
shinyUI(
  fluidPage(

    # App Title
    titlePanel("safeRview: Clinical Trial Safety Dashboard"),

    # Sidebar Layout
    sidebarLayout(

      # --- Sidebar Panel (Inputs) ---
      sidebarPanel(
        width = 3,
        h4("Volcano Plot Controls"),

        selectInput(
          inputId = "treatment_arm",
          label = "Select Treatment Arm:",
          choices = all_arms,
          selected = all_arms[1] # Select the first arm by default
        ),

        selectInput(
          inputId = "comparator_arm",
          label = "Select Comparator Arm:",
          choices = all_arms,
          selected = all_arms[2] # Select the second arm by default
        ),

        hr(), # A horizontal line

        h4("AE Barchart Controls"),
        sliderInput(
          inputId = "top_n",
          label = "Select Number of Top AEs:",
          min = 5,
          max = 20,
          value = 10,
          step = 1
        )
      ),

      # --- Main Panel (Outputs) ---
      mainPanel(
        width = 9,
        # Use tabs to organize the outputs
        tabsetPanel(
          type = "tabs",

          tabPanel(
            "AE Barchart",
            # We use plotlyOutput to make the plot interactive
            plotlyOutput("ae_barchart", height = "500px")
          ),

          tabPanel(
            "Volcano Plot",
            plotlyOutput("ae_volcano", height = "500px")
          ),

          tabPanel(
            "Full AE Summary Table",
            # DT (DataTables) makes the table interactive
            DT::dataTableOutput("ae_summary_table")
          )
        )
      )
    )
  )
)
