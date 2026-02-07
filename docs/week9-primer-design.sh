#!/bin/bash
# File: week9_primer_design.sh

echo "week 9: primer design and validation"

##### create output directories
mkdir -p week9_primer_design/{decipher_analysis,specificity_screening,pipeline_integration,results,logs}
mkdir -p week9_plots
mkdir -p week9_tables

####### phase 1: basic primer design
echo "phase 1: basic primer design"
cd week9_primer_design/decipher_analysis || exit 1
Rscript basic_primer_design_complete.R > ../logs/phase1_primer_design.log 2>&1

### phase 2: specificity screening
echo "phase 2: specificity screening"
cd ../specificity_screening || exit 1
python3 assess_primer_specificity.py > ../logs/phase2_specificity.log 2>&1

###### phase 3: copy number analysis
echo "phase 3: copy number analysis"
cd ../pipeline_integration || exit 1
Rscript copy_number_analysis.R > ../logs/phase3_copy_numbers.log 2>&1

##### phase 4: final integration
echo "phase 4: final integration"
python3 marine_qpcr_pipeline_summary.py > ../logs/phase4_integration.log 2>&1

##### phase 5: visualization
echo "phase 5: visualization"
Rscript week9_visualization.R > ../logs/phase5_plots.log 2>&1

cd ../../ || exit 1
echo "week 9 primer design complete"
