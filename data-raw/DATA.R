## DATA.R
## code to prepare `adsl` and `adae` test datasets

# Load the libraries
library(random.cdisc.data)
library(usethis)
library(dplyr)

# ---
# 1. SET PARAMETERS
# ---

# Set a random seed so the data is reproducible
set.seed(42)


# ---
# 2. GENERATE ADSL (Subject-Level Data)
# ---

# Generate the subject-level data using radsl()
# We just pass the number of subjects. The function
# will create its own default treatment arms.
adsl <- radsl(
  N = n_subjects
)

# A quick check to see the output
# adsl %>% count(ARM)

# ---
# 3. GENERATE ADAE (Adverse Event Data)
# ---

# Generate the adverse event data using radae()
# This function requires the `adsl` data as an input.
# We set max_n_aes (max number of AEs per patient) to 5.
adae <- radae(
  adsl = adsl,
  max_n_aes = 5L,  # Maximum number of AEs per patient. Defaults to 10.
  seed = 42        # Use seed for reproducible AE generation
)

# A quick check to see the output
# adae %>% count(AETERM, sort = TRUE)

# ---
# 4. SAVE THE DATA FOR THE PACKAGE
# ---

# This is the most important step.
# usethis::use_data() saves the data objects (adsl, adae)
# into the `data/` folder as compressed .rda files.
# This makes them available for your package's functions
# and for users (with `data(adsl)`).
usethis::use_data(adsl, adae, overwrite = TRUE)
