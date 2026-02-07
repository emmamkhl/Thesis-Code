# Part 06 — Cross-Taxa Consistency Assessment

## Purpose
Compare repeat class composition across phyla and species using filtered RepeatMasker annotations from Part 04, then quantify divergence/length trends and visualise cross-taxa structure using heatmaps and ordination.

## Inputs
- `tables/all_species_filtered_repeats.csv` (from Part 04)

## Outputs
- `week6_plots/cross_taxa_heatmap.png`
- `week6_plots/repeat_classes_by_phylum.png`
- `week6_plots/divergence_by_phylum.png`
- `week6_plots/nmds_repeat_class_composition.png`
- `week6_tables/*.csv` (summaries + NMDS scores)

## Run
```bash
Rscript scripts/week6_cross_taxa_analysis.R
