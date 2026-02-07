#!/usr/bin/env Rscript
# File: week6_cross_taxa_analysis.R

library(dplyr)
library(ggplot2)
library(pheatmap)
library(vegan)
library(readr)
library(tidyr)

cat(" WEEK 6: cross-taxa consistency assessment \n")

##### read combined repeat data
if (file.exists("tables/all_species_filtered_repeats.csv")) {
  repeat_data <- read_csv("tables/all_species_filtered_repeats.csv")
} else {
  cat("warning: filtered repeat data not found. run week 4 first.\n")
  quit(status = 1)
}

##### create output directories
dir.create("week6_plots", showWarnings = FALSE)
dir.create("week6_tables", showWarnings = FALSE)

##### analyse repeat class abundance by phylum
class_abundance <- repeat_data %>%
  group_by(phylum, class) %>%
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = class, values_from = count, values_fill = 0)

##### create heatmap of repeat classes
if (nrow(class_abundance) > 1 && ncol(class_abundance) > 2) {
  pheatmap(
    as.matrix(class_abundance[, -1]),
    labels_row = class_abundance$phylum,
    main = "repeat class abundance by phylum",
    filename = "week6_plots/cross_taxa_heatmap.png",
    width = 12, height = 8
  )
}

##### species-level analysis
species_class_summary <- repeat_data %>%
  group_by(species, phylum, class) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(species, phylum) %>%
  mutate(percent = round(count / sum(count) * 100, 2)) %>%
  ungroup()

##### top repeat classes by phylum
top_classes <- species_class_summary %>%
  group_by(phylum, class) %>%
  summarise(total_count = sum(count), .groups = "drop") %>%
  group_by(phylum) %>%
  slice_max(total_count, n = 5) %>%
  ungroup()

##### plot repeat class composition
p1 <- ggplot(top_classes, aes(x = reorder(class, total_count), y = total_count, fill = phylum)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  facet_wrap(~phylum, scales = "free") +
  labs(title = "top 5 repeat classes by phylum",
       x = "repeat class", y = "total count", fill = "phylum") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.y = element_text(size = 8))

ggsave("week6_plots/repeat_classes_by_phylum.png", p1, width = 14, height = 10, dpi = 300)

##### divergence patterns by phylum
divergence_summary <- repeat_data %>%
  group_by(phylum) %>%
  summarise(
    mean_div = round(mean(div, na.rm = TRUE), 2),
    median_div = round(median(div, na.rm = TRUE), 2),
    sd_div = round(sd(div, na.rm = TRUE), 2),
    q25_div = round(quantile(div, 0.25, na.rm = TRUE), 2),
    q75_div = round(quantile(div, 0.75, na.rm = TRUE), 2),
    .groups = "drop"
  )

print("divergence patterns by phylum:")
print(divergence_summary)

##### plot divergence distributions
p2 <- ggplot(repeat_data, aes(x = div, fill = phylum)) +
  geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
  facet_wrap(~phylum, scales = "free_y") +
  labs(title = "repeat divergence distributions by phylum",
       x = "divergence (%)", y = "count", fill = "phylum") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave("week6_plots/divergence_by_phylum.png", p2, width = 12, height = 8, dpi = 300)

##### length patterns by phylum
length_summary <- repeat_data %>%
  group_by(phylum) %>%
  summarise(
    mean_length = round(mean(length, na.rm = TRUE), 0),
    median_length = round(median(length, na.rm = TRUE), 0),
    sd_length = round(sd(length, na.rm = TRUE), 0),
    .groups = "drop"
  )

print("length patterns by phylum:")
print(length_summary)

##### ordination analysis if enough data
species_matrix <- species_class_summary %>%
  select(species, phylum, class, count) %>%
  pivot_wider(names_from = class, values_from = count, values_fill = 0)

meta <- species_matrix %>% select(species, phylum)
mat <- species_matrix %>% select(-species, -phylum)
mat <- as.data.frame(mat)

if (nrow(mat) >= 3 && ncol(mat) >= 2) {

  set.seed(123)
  nmds <- metaMDS(mat, distance = "bray", k = 2, trymax = 50)

  nmds_scores <- as.data.frame(scores(nmds))
  nmds_scores$species <- meta$species
  nmds_scores$phylum <- meta$phylum

  p3 <- ggplot(nmds_scores, aes(x = NMDS1, y = NMDS2, color = phylum, label = gsub("_", " ", species))) +
    geom_point(size = 4) +
    geom_text(vjust = -0.5, size = 3) +
    labs(title = "NMDS of repeat class composition (Bray-Curtis)") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))

  ggsave("week6_plots/nmds_repeat_class_composition.png", p3, width = 12, height = 8, dpi = 300)

  write_csv(divergence_summary, "week6_tables/divergence_summary_by_phylum.csv")
  write_csv(length_summary, "week6_tables/length_summary_by_phylum.csv")
  write_csv(class_abundance, "week6_tables/repeat_class_abundance_by_phylum.csv")
  write_csv(species_class_summary, "week6_tables/species_class_summary.csv")
  write_csv(nmds_scores, "week6_tables/nmds_scores.csv")

  cat("\nweek 6 complete\n")
  cat("generated files:\n")
  cat("- week6_plots/cross_taxa_heatmap.png\n")
  cat("- week6_plots/repeat_classes_by_phylum.png\n")
  cat("- week6_plots/divergence_by_phylum.png\n")
  cat("- week6_plots/nmds_repeat_class_composition.png\n")
  cat("- week6_tables/*.csv\n")

} else {
  cat("not enough data for ordination\n")
}
