#!/bin/bash
# File: week8_clustering.sh

echo "WEEK 8: repeat clustering and redundancy reduction"

##### create output directories
mkdir -p clustered_sequences
mkdir -p clustering_analysis
mkdir -p week8_plots
mkdir -p week8_logs

##### run cd-hit-est on flanking sequences with multiple thresholds
for species in hydra_vulgaris clytia_hemisphaerica nematostella_vectensis daphnia_pulex hyalella_azteca lepeophtheirus_salmonis biomphalaria_glabrata crassostrea_ariakensis crassostrea_gigas; do

  echo "clustering sequences for $species"

  input_file="flanking_sequences/${species}_clean_flanking.fasta"

  if [ ! -f "$input_file" ]; then
    echo "  warning: input file not found for $species"
    continue
  fi

  seq_count=$(grep -c ">" "$input_file")
  echo "  input sequences: $seq_count"

  if [ "$seq_count" -eq 0 ]; then
    echo "  no sequences to cluster for $species"
    continue
  fi

  ##### clustering at 90% identity
  echo "  clustering at 90% identity"
  cd-hit-est -i "$input_file" \
             -o "clustered_sequences/${species}_clustered_90.fasta" \
             -c 0.90 -n 8 -M 2000 -T 8 -d 0 \
             > "week8_logs/${species}_cdhit_90.log" 2>&1

  ##### clustering at 95% identity
  echo "  clustering at 95% identity"
  cd-hit-est -i "$input_file" \
             -o "clustered_sequences/${species}_clustered_95.fasta" \
             -c 0.95 -n 10 -M 2000 -T 8 -d 0 \
             > "week8_logs/${species}_cdhit_95.log" 2>&1

  ##### clustering at 85% identity (more stringent)
  echo "  clustering at 85% identity"
  cd-hit-est -i "$input_file" \
             -o "clustered_sequences/${species}_clustered_85.fasta" \
             -c 0.85 -n 7 -M 2000 -T 8 -d 0 \
             > "week8_logs/${species}_cdhit_85.log" 2>&1

  ##### count clusters for each threshold
  for threshold in 85 90 95; do
    clustered_file="clustered_sequences/${species}_clustered_${threshold}.fasta"
    cluster_file="clustered_sequences/${species}_clustered_${threshold}.fasta.clstr"

    if [ -f "$clustered_file" ] && [ -f "$cluster_file" ]; then
      cluster_count=$(grep -c ">" "$clustered_file")
      total_clusters=$(grep -c "^>Cluster" "$cluster_file")
      echo "  ${threshold}% identity: $cluster_count representative sequences, $total_clusters clusters"
    fi
  done

  echo "  clustering complete for $species"
done

##### run cluster analysis
echo "running cluster analysis..."
Rscript clustering_analysis/analyze_clusters.R

##### create week 8 summary
cat > week8_clustering_summary.txt << 'EOF'
WEEK 8: clustering and redundancy reduction complete

objective: reduce redundancy in flanking sequences using cd-hit-est clustering

methodology:
- clustering algorithm: cd-hit-est
- identity thresholds tested: 85%, 90%, 95%
- memory limit: 2000mb per process
- threads: 8

clustering parameters:
- 85% identity: word size 7, more stringent clustering
- 90% identity: word size 8, balanced approach
- 95% identity: word size 10, conservative clustering

output files:
- clustered_sequences/: representative sequences for each threshold
- clustering_analysis/: statistical analysis and comparisons
- week8_plots/: visualization of cluster distributions
- week8_logs/: detailed cd-hit logs

analysis:
- cluster size distributions by phylum and threshold
- optimal threshold determination
- redundancy reduction quantification

EOF

echo "week 8 clustering and redundancy reduction complete"
