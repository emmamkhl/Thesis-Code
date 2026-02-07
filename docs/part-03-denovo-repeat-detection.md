#!/bin/bash
# File: week3_repeat_detection.sh

##### create output directories
mkdir -p repeatmodeler_output
mkdir -p repeatmasker_output
mkdir -p repeat_libraries

##### run repeatmodeler on all genomes
for phylum in cnidaria crustacea mollusca; do
  for genome in genomes/$phylum/*.fna; do
    species=$(basename "$genome" .fna)
    echo "running RepeatModeler on $species"

    ### build database
    BuildDatabase -name "repeatmodeler_output/${species}_db" -engine ncbi "$genome"

    #### run repeatmodeler
    RepeatModeler -database "repeatmodeler_output/${species}_db" -engine ncbi -pa 8 -LTRStruct \
      > "repeatmodeler_output/${species}_repeatmodeler.log" 2>&1

    ### copy library to libraries directory
    cp "repeatmodeler_output/${species}_db-families.fa" \
       "repeat_libraries/${species}_custom_library.fa"

    #### run repeatmasker with custom library
    RepeatMasker -lib "repeat_libraries/${species}_custom_library.fa" \
                 -dir repeatmasker_output -gff -pa 8 "$genome"
  done
done

##### generate summary statistics
cat > repeat_detection_summary.txt << 'EOF'
WEEK 3: REPEAT DETECTION SUMMARY

Species processed:
- Hydra vulgaris
- Clytia hemisphaerica
- Nematostella vectensis
- Daphnia pulex
- Hyalella azteca
- Lepeophtheirus salmonis
- Biomphalaria glabrata
- Crassostrea ariakensis
- Crassostrea gigas

Output files:
- repeatmodeler_output/: RepeatModeler databases and logs
- repeat_libraries/: Custom repeat libraries for each species
- repeatmasker_output/: RepeatMasker annotation files (.out, .gff)
EOF
