#' Plot Top Adverse Events as a Bar Chart
#'
#' @description
#' Creates a ggplot2 bar chart of the top N most frequent adverse events,
#' faceted by treatment arm.
#'
#' @param ae_summary_table The data.frame created by `summarize_ae_data()`.
#' @param top_n The number of adverse events to display.
#'
#' @return A ggplot object.
#'
#' @importFrom dplyr slice_head mutate
#' @importFrom tidyr pivot_longer
#' @importFrom forcats fct_reorder
#' @importFrom ggplot2 ggplot aes geom_col facet_wrap labs theme_minimal
#'
#' @export
plot_ae_barchart <- function(ae_summary_table, top_n = 10) {

  # 1. Get just the top N rows
  plot_data <- ae_summary_table |>
    dplyr::slice_head(n = top_n)

  # 2. Pivot the percentage columns to a long format
  plot_data_long <- plot_data |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("pct_"),
      names_to = "ARM",
      values_to = "Percentage",
      names_prefix = "pct_" # This trick strips "pct_" from the names!
    )

  # 3. Create the plot
  plot_data_long |>
    # Reorder the AETERM factor based on total_n so it plots correctly
    dplyr::mutate(AETERM = forcats::fct_reorder(AETERM, total_n)) |>
    ggplot2::ggplot(ggplot2::aes(x = Percentage, y = AETERM)) +
    ggplot2::geom_col(fill = "#0072B2") + # A nice blue color
    # Create one small plot for each ARM
    ggplot2::facet_wrap(~ARM) +
    ggplot2::labs(
      title = paste("Top", top_n, "Adverse Events"),
      subtitle = "Percentage of Subjects Experiencing Event by Arm",
      x = "Percentage of Subjects",
      y = "Adverse Event Term"
    ) +
    ggplot2::theme_minimal()
}
