#!/usr/bin/env Rscript

library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)

cat("week 8: cluster analysis\n")

##### function to parse cd-hit cluster files
analyze_clusters <- function(species, threshold) {
  clstr_file <- paste0("clustered_sequences/", species, "_clustered_", threshold, ".fasta.clstr")

  if (!file.exists(clstr_file)) {
    return(NULL)
  }

  lines <- readLines(clstr_file)
  cluster_sizes <- c()
  current_size <- 0

  for (line in lines) {
    if (grepl("^>Cluster", line)) {
      if (current_size > 0) {
        cluster_sizes <- c(cluster_sizes, current_size)
      }
      current_size <- 0
    } else {
      current_size <- current_size + 1
    }
  }
  if (current_size > 0) {
    cluster_sizes <- c(cluster_sizes, current_size)
  }

  data.frame(
    species = species,
    threshold = threshold,
    cluster_size = cluster_sizes,
    cluster_id = 1:length(cluster_sizes)
  )
}

##### analyze all species and thresholds
species_list <- c(
  "hydra_vulgaris", "clytia_hemisphaerica", "nematostella_vectensis",
  "daphnia_pulex", "hyalella_azteca", "lepeophtheirus_salmonis",
  "biomphalaria_glabrata", "crassostrea_ariakensis", "crassostrea_gigas"
)

all_clusters <- list()
for (species in species_list) {
  for (threshold in c(85, 90, 95)) {
    result <- analyze_clusters(species, threshold)
    if (!is.null(result)) {
      all_clusters[[paste(species, threshold, sep = "_")]] <- result
    }
  }
}

if (length(all_clusters) > 0) {
  cluster_data <- bind_rows(all_clusters)

  ##### add phylum information
  cluster_data <- cluster_data %>%
    mutate(phylum = case_when(
      species %in% c("hydra_vulgaris", "clytia_hemisphaerica", "nematostella_vectensis") ~ "cnidaria",
      species %in% c("daphnia_pulex", "hyalella_azteca", "lepeophtheirus_salmonis") ~ "crustacea",
      species %in% c("biomphalaria_glabrata", "crassostrea_ariakensis", "crassostrea_gigas") ~ "mollusca",
      TRUE ~ NA_character_
    ))

  ##### plot cluster size distributions
  p1 <- ggplot(cluster_data, aes(x = cluster_size)) +
    geom_histogram(bins = 20, fill = "steelblue", alpha = 0.7) +
    facet_grid(threshold ~ phylum, scales = "free") +
    labs(title = "cluster size distributions by threshold and phylum",
         x = "cluster size", y = "frequency") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))

  ggsave("week8_plots/cluster_size_distributions.png", p1, width = 14, height = 10, dpi = 300)

  ##### summary statistics
  cluster_summary <- cluster_data %>%
    group_by(species, phylum, threshold) %>%
    summarise(
      total_clusters = n(),
      mean_cluster_size = round(mean(cluster_size), 2),
      max_cluster_size = max(cluster_size),
      singleton_clusters = sum(cluster_size == 1),
      large_clusters = sum(cluster_size >= 5),
      .groups = "drop"
    )

  write_csv(cluster_summary, "clustering_analysis/cluster_summary_stats.csv")

  ##### optimal threshold analysis
  threshold_comparison <- cluster_summary %>%
    group_by(species, phylum) %>%
    summarise(
      clusters_85 = total_clusters[threshold == 85],
      clusters_90 = total_clusters[threshold == 90],
      clusters_95 = total_clusters[threshold == 95],
      reduction_90_vs_95 = round((clusters_95 - clusters_90) / clusters_95 * 100, 1),
      reduction_85_vs_90 = round((clusters_90 - clusters_85) / clusters_90 * 100, 1),
      .groups = "drop"
    )

  write_csv(threshold_comparison, "clustering_analysis/threshold_comparison.csv")

  ##### plot threshold comparison
  threshold_long <- threshold_comparison %>%
    select(species, phylum, clusters_85, clusters_90, clusters_95) %>%
    pivot_longer(cols = starts_with("clusters_"),
                 names_to = "threshold",
                 values_to = "cluster_count") %>%
    mutate(threshold = as.numeric(gsub("clusters_", "", threshold)))

  p2 <- ggplot(threshold_long, aes(x = threshold, y = cluster_count, color = phylum)) +
    geom_line(aes(group = species), alpha = 0.7) +
    geom_point(size = 2) +
    facet_wrap(~phylum, scales = "free_y") +
    labs(title = "cluster count by identity threshold",
         x = "identity threshold (%)", y = "number of clusters", color = "phylum") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))

  ggsave("week8_plots/threshold_comparison.png", p2, width = 12, height = 8, dpi = 300)

  cat("cluster analysis complete\n")
  cat("generated files:\n")
  cat("- week8_plots/cluster_size_distributions.png\n")
  cat("- week8_plots/threshold_comparison.png\n")
  cat("- clustering_analysis/cluster_summary_stats.csv\n")
  cat("- clustering_analysis/threshold_comparison.csv\n")

} else {
  cat("no cluster data found\n")
}
