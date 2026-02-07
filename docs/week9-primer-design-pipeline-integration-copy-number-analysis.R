#!/usr/bin/env Rscript
# File: copy_number_analysis.R

library(dplyr)
library(readr)

cat("week 9: copy number analysis\n")

extract_repeat_family <- function(target_id) {
  family_mapping <- c(
    "Hydra_vulgaris_29747" = "rnd-4_family-4439",
    "Hydra_vulgaris_28668" = "rnd-4_family-9",
    "Hydra_vulgaris_25592" = "rnd-1_family-1354",
    "Hydra_vulgaris_27211" = "ltr-1_family-104",
    "Hydra_vulgaris_29570" = "ltr-1_family-104"
  )
  return(family_mapping[target_id])
}

# Function to count repeat family occurrences
count_repeat_copies <- function(repeat_family, species = "Hydra_vulgaris") {
  repeat_data_file <- paste0("../../", species, "_repeat_data.csv")

  if (!file.exists(repeat_data_file)) {
    cat("Warning: repeat data file not found for ", species, "\n")
    return(NA)
  }

  repeat_data <- read_csv(repeat_data_file, show_col_types = FALSE)
  copy_count <- sum(grepl(repeat_family, repeat_data$repeat_name, fixed = TRUE))
  return(copy_count)
}

#### load primer results
primer_file <- "../specificity_screening/final_primer_rankings.csv"

if (file.exists(primer_file)) {
  primers <- read_csv(primer_file, show_col_types = FALSE)

  ##### add copy number analysis
  primers$repeat_family <- sapply(primers$sequence_id, extract_repeat_family)
  primers$expected_copy_number <- sapply(primers$repeat_family, count_repeat_copies)

  ###### add sensitivity ranking based on copy numbers
  primers$sensitivity_rank <- case_when(
    primers$expected_copy_number >= 2000 ~ "Highest",
    primers$expected_copy_number >= 600  ~ "High",
    primers$expected_copy_number >= 300  ~ "Moderate",
    TRUE ~ "Lower"
  )

  ##### save enhanced results
  write_csv(primers, "primer_pairs_with_copy_numbers.csv")

  cat("=== COPY NUMBER ANALYSIS RESULTS ===\n")
  top_5 <- head(primers, 5)
  for (i in 1:nrow(top_5)) {
    cat(sprintf("Primer %d: %s copies (%s sensitivity)\n",
                i, top_5$expected_copy_number[i], top_5$sensitivity_rank[i]))
  }

} else {
  cat("Error: Primer file not found. Run Phase 2 first.\n")
}
