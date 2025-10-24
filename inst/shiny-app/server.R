library(shiny)
library(safeRview) # Our package!
library(plotly)
library(DT)
library(dplyr)

# Define the server logic
shinyServer(function(input, output, session) {

  # --- 1. Load Data ---
  # Load the package data once when the server starts
  data(adsl)
  data(adae)

  # --- 2. Reactive Data Summary ---
  # Create a "reactive" expression.
  # This code will re-run *only* when an input it depends on changes.
  # Here, it doesn't depend on any inputs, so it runs only once.
  ae_summary_reactive <- reactive({
    # Use the function from our package!
    summarize_ae_data(adsl, adae)
  })

  # --- 3. Outputs ---

  # --- Output for Barchart Tab ---
  output$ae_barchart <- renderPlotly({

    # Get the summary table from our reactive expression
    ae_table <- ae_summary_reactive()

    # Create the ggplot object using our package function
    # It uses input$top_n, so it will re-run when the slider changes
    p <- plot_ae_barchart(ae_table, top_n = input$top_n)

    # Use ggplotly() to convert the static ggplot to an interactive plotly one
    ggplotly(p, tooltip = c("y", "x"))
  })

  # --- Output for Volcano Plot Tab ---
  output$ae_volcano <- renderPlotly({

    # Create the ggplot object
    # This uses input$treatment_arm and input$comparator_arm,
    # so it re-runs when those dropdowns change.
    p <- plot_ae_volcano(
      adsl = adsl,
      adae = adae,
      treatment_arm = input$treatment_arm,
      comparator_arm = input$comparator_arm
    )

    # Convert to plotly
    #ggplotly(p)
    # Convert to plotly and specify the tooltip
    ggplotly(p, tooltip = c("text", "x", "y"))
  })

  # --- Output for Data Table Tab ---
  output$ae_summary_table <- DT::renderDataTable({

    # Get the summary table
    ae_table <- ae_summary_reactive()

    # Use the datatable() function for a nice interactive table
    # We round the percentage columns for cleaner display
    datatable(
      ae_table %>% mutate(across(starts_with("pct_"), ~ round(.x, 1))),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE
    )
  })

})
