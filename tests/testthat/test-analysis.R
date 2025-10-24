library(testthat)
library(safeRview)
library(dplyr)

# --- Test Data ---
# Create small, predictable data for testing
test_adsl <- tibble::tribble(
  ~USUBJID, ~ARM,
  "sub-1",  "A: Drug X",
  "sub-2",  "A: Drug X",
  "sub-3",  "B: Placebo",
  "sub-4",  "B: Placebo"
)

test_adae <- tibble::tribble(
  ~USUBJID, ~AETERM,
  "sub-1",  "Headache",
  "sub-1",  "Headache", # Duplicate, should only be counted once
  "sub-2",  "Headache",
  "sub-3",  "Nausea"
)

# --- Test summarize_ae_data ---

test_that("summarize_ae_data returns correct counts and percentages", {
  summary <- summarize_ae_data(test_adsl, test_adae)

  # Check that it has the right shape
  expect_equal(nrow(summary), 2)
  expect_true("total_n" %in% names(summary))
  expect_true("pct_A: Drug X" %in% names(summary))

  # Check Headache row
  headache <- summary |> dplyr::filter(AETERM == "Headache")
  expect_equal(headache$`n_A: Drug X`, 2)
  expect_equal(headache$`pct_A: Drug X`, 100) # 2 out of 2
  expect_equal(headache$`n_B: Placebo`, 0)
  expect_equal(headache$`pct_B: Placebo`, 0)   # 0 out of 2
  expect_equal(headache$total_n, 2)

  # Check Nausea row
  nausea <- summary |> dplyr::filter(AETERM == "Nausea")
  expect_equal(nausea$`n_A: Drug X`, 0)
  expect_equal(nausea$`pct_A: Drug X`, 0)
  expect_equal(nausea$`n_B: Placebo`, 1)
  expect_equal(nausea$`pct_B: Placebo`, 50) # 1 out of 2
  expect_equal(nausea$total_n, 1)
})

# --- Test plotting functions ---

test_that("plotting functions return ggplot objects", {
  # Use the data built into the package
  summary_table <- summarize_ae_data(adsl, adae)

  # Test barchart
  p_bar <- plot_ae_barchart(summary_table)
  expect_s3_class(p_bar, "ggplot")
  # Check that it's faceted
  expect_true(inherits(p_bar$facet, "FacetWrap"))

  # Test volcano plot
  p_volcano <- plot_ae_volcano(
    adsl = adsl,
    adae = adae,
    treatment_arm = "A: Drug X",
    comparator_arm = "B: Placebo"
  )
  expect_s3_class(p_volcano, "ggplot")
  # Check that the underlying data has the correct stats
  expect_true("log_p" %in% names(p_volcano$data))
  expect_true("risk_diff" %in% names(p_volcano$data))
})
