#' Plot Adverse Event Volcano Plot
#'
#' @description
#' Performs a statistical comparison (Fisher's Exact Test) for each AE
#' between a treatment and a comparator arm, then generates a volcano plot.
#'
#' @param adsl Subject-level data (for total N in each arm).
#' @param adae Adverse event data.
#' @param treatment_arm The name of the treatment arm (e.g., "A: Drug X").
#' @param comparator_arm The name of the comparator arm (e.g., "B: Placebo").
#' @param p_cutoff The p-value threshold for significance.
#'
#' @return A ggplot object.
#'
#' @importFrom dplyr count filter pull select rowwise mutate ungroup
#' @importFrom stats fisher.test
#' @importFrom rlang sym
#' @importFrom ggplot2 ggplot aes geom_point geom_hline labs theme_minimal
#' @importFrom ggrepel geom_text_repel
#'
#' @export
plot_ae_volcano <- function(adsl,
                            adae,
                            treatment_arm,
                            comparator_arm,
                            p_cutoff = 0.05) {

  # --- 1. Calculate Statistics ---

  # Get total N for each arm
  arm_totals <- adsl |> dplyr::count(ARM, name = "N")

  N_treat <- arm_totals |>
    dplyr::filter(ARM == treatment_arm) |>
    dplyr::pull(N)

  N_comp <- arm_totals |>
    dplyr::filter(ARM == comparator_arm) |>
    dplyr::pull(N)

  # Get AE counts (n) for each arm
  ae_summary <- summarize_ae_data(adsl, adae)

  # Use rlang (!!sym()) to use our string variables as column names
  treat_col_n <- paste0("n_", treatment_arm)
  comp_col_n <- paste0("n_", comparator_arm)

  stats_table <- ae_summary |>
    dplyr::select(AETERM,
                  n_treat = !!rlang::sym(treat_col_n),
                  n_comp = !!rlang::sym(comp_col_n)) |>
    # Run a test for every single row
    dplyr::rowwise() |>
    dplyr::mutate(
      # Create the 2x2 contingency table for the test
      matrix = list(
        matrix(c(n_treat, N_treat - n_treat,
                 n_comp,  N_comp - n_comp),
               nrow = 2, byrow = TRUE)
      ),
      # Run the test
      test_result = list(stats::fisher.test(matrix)),
      p_value = test_result$p.value,
      # Calculate risk difference: (pct_treat - pct_comp)
      risk_diff = (n_treat / N_treat) - (n_comp / N_comp),
      log_p = -log10(p_value)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      significant = p_value < p_cutoff & abs(risk_diff) > 0.05
    )

  # --- 2. Create Plot ---

  ggplot2::ggplot(
    stats_table,
    ggplot2::aes(
      x = risk_diff,
      y = log_p,
      color = significant,
      text = AETERM
    )
  ) +
    ggplot2::geom_point(alpha = 0.7) +
    # REMOVED ggrepel::geom_text_repel()

    # ggplot2::ggplot(stats_table,
    #                 ggplot2::aes(x = risk_diff, y = log_p, color = significant)) +
    # ggplot2::geom_point(alpha = 0.7) +
    # # Add labels for significant points
    # ggrepel::geom_text_repel(
    #   ggplot2::aes(label = ifelse(significant, AETERM, "")),
    #   max.overlaps = 15
    # ) +
    # Add dashed line for p-value cutoff
    ggplot2::geom_hline(
      yintercept = -log10(p_cutoff),
      linetype = "dashed",
      color = "grey50"
    ) +
    ggplot2::scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = "red")) +
    ggplot2::labs(
      title = "Adverse Event Volcano Plot",
      subtitle = paste(treatment_arm, "vs.", comparator_arm),
      x = "Risk Difference",
      y = "-log10(p-value)"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")
}
