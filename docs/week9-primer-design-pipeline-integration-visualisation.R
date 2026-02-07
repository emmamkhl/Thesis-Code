#!/usr/bin/env Rscript
# File: week9_visualization.R

library(ggplot2)
library(dplyr)
library(readr)

cat("week 9: final visualisations\n")

####### load primer data with copy numbers
primer_file <- "primer_pairs_with_copy_numbers.csv"

if (file.exists(primer_file)) {
  primers <- read_csv(primer_file, show_col_types = FALSE)

  #### plot 1: final composite scores
  p1 <- ggplot(head(primers, 5),
               aes(x = reorder(paste("Primer", 1:5), final_score), y = final_score)) +
    geom_bar(stat = "identity", fill = "steelblue", alpha = 0.8) +
    coord_flip() +
    labs(title = "Final Composite Scores for Top 5 Primer Pairs",
         subtitle = "Top candidates show consistently strong composite scores",
         x = "Primer Pair", y = "Composite Score") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5))

  ggsave("../../week9_plots/week9_primer_final_scores.png", p1, width = 10, height = 6, dpi = 300)

  #### plot 2: copy numbers vs sensitivity
  p2 <- ggplot(head(primers, 5),
               aes(x = reorder(paste("Primer", 1:5), expected_copy_number),
                   y = expected_copy_number, fill = sensitivity_rank)) +
    geom_bar(stat = "identity", alpha = 0.8) +
    coord_flip() +
    labs(title = "Expected Copy Numbers for Top 5 Primer Targets",
         subtitle = "Higher copy numbers indicate greater sensitivity potential",
         x = "Primer Pair", y = "Expected Copy Number (per genome)",
         fill = "Sensitivity Rank") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5))

  ggsave("../../week9_plots/week9_copy_numbers.png", p2, width = 10, height = 6, dpi = 300)

  cat("visualizations created in week9_plots/\n")

} else {
  cat("Error: Enhanced primer file not found.\n")
}
