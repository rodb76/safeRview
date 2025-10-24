#' Summarize Adverse Event Data
#'
#' @description
#' Calculates the number and percentage of subjects experiencing each adverse
#' event, summarized by treatment arm. The final output is a wide-format
#' table suitable for reporting.
#'
#' @param adsl A data.frame of subject-level data, like the one generated
#'   by `random.cdisc.data::radsl()`. Must contain columns `USUBJID` and `ARM`.
#' @param adae A data.frame of adverse event data, like the one generated
#'   by `random.cdisc.data::radae()`. Must contain `USUBJID` and `AETERM`.
#'
#' @return A summarized data.frame with one row per adverse event term (`AETERM`).
#'   Columns are created for the count (`n`) and percentage (`pct`) of subjects
#'   in each treatment arm.
#'
#' @importFrom dplyr count distinct group_by left_join mutate select arrange desc
#' @importFrom tidyr pivot_wider
#'
#' @export
#'
#' @examples
#' # This is an example of how the function can be used
#' adsl_data <- radsl(N = 100, seed = 1)
#' adae_data <- radae(adsl = adsl_data, seed = 1)
#' summarize_ae_data(adsl = adsl_data, adae = adae_data)

summarize_ae_data <- function(adsl, adae) {

  # --- Step 1: Get total number of subjects in each arm (the denominator 'N') ---
  arm_totals <- adsl |>
    dplyr::count(ARM, name = "N")

  # --- Step 2: Calculate number of subjects with each AE in each arm (the numerator 'n') ---
  event_counts <- adae |>
    # A subject may have the same AE multiple times, but we only count them once.
    dplyr::distinct(USUBJID, AETERM) |>
    # Join with ADSL to get the treatment ARM for each subject
    dplyr::left_join(adsl |> dplyr::select(USUBJID, ARM), by = "USUBJID") |>
    # Now count the unique subjects per ARM and AE Term
    dplyr::count(ARM, AETERM, name = "n")

  # --- Step 3: Combine totals and event counts to create a "long" summary table ---
  summary_long <- event_counts |>
    dplyr::left_join(arm_totals, by = "ARM") |>
    # Calculate the percentage
    dplyr::mutate(pct = (n / N) * 100)

  # --- Step 4: Pivot to the "wide" format required for reporting ---
  # This turns rows into columns. For example, the values from the "ARM" column
  # will become the new column headers.
  summary_wide <- summary_long |>
    tidyr::pivot_wider(
      id_cols = AETERM,
      names_from = ARM,
      values_from = c(n, pct),
      # If an AE didn't occur in an arm, its count and pct should be 0, not NA
      values_fill = 0
    )

  # --- Step 5: Add a total count across all arms for sorting purposes ---
  total_counts <- adae |>
    dplyr::distinct(USUBJID, AETERM) |>
    dplyr::count(AETERM, name = "total_n")

  # --- Step 6: Join the total count and sort the final table ---
  # This makes the most frequent AEs appear at the top.
  final_summary <- summary_wide |>
    dplyr::left_join(total_counts, by = "AETERM") |>
    dplyr::arrange(dplyr::desc(total_n)) #|>
    # The total_n column was just for sorting, so we can remove it now
    #dplyr::select(-total_n)

  return(final_summary)
}
