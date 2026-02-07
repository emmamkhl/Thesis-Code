# MSc Thesis Code Repository

This repository contains the code used for my MSc dissertation project on **de novo repeat detection, filtering, and downstream analysis across marine invertebrate genomes**.

The aim of this repository is to **document and showcase the analysis pipeline** used in the project, rather than to provide a polished or fully automated software package. The scripts were developed incrementally as part of the research process.


## Project overview

The workflow follows the structure of the dissertation and is organised into sequential parts (Weeks 2–9), covering:

- Genome selection and download  
- De novo repeat detection  
- Repeat filtering and metrics extraction  
- GC content analysis  
- Cross-taxa consistency assessment  
- Flanking sequence extraction  
- Sequence clustering and redundancy reduction  
- Primer design and validation  

Each step builds on outputs from the previous stage.

## Repository structure

### Documentation (`.md` files)
Each `part-XX-*.md` file explains:
- the purpose of that stage
- input and output files
- a brief description of the methods used

These files are intended to mirror the **Methods / Results workflow** described in the dissertation.

### Scripts
Analysis scripts are provided as standalone files:
- `.sh` — bash pipelines and tool execution
- `.R` — statistical analysis and plotting
- `.py` — data processing and table generation

Scripts are not written as a single executable pipeline and may require running in sequence, depending on available data and tools.

## Running the code

Most scripts were run individually during development rather than as a single automated workflow.

Typical usage examples are included at the top of each script or in the corresponding `.md` file, for example:

```bash
Rscript week6_cross_taxa_analysis.R
bash week8_clustering.sh
python3 week9-primer-design-create-final-table.py
