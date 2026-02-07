#!/bin/bash
# File: week2_genome_download.sh

echo "Part 2: genome download and preparation"

##### create directory structure
mkdir -p genomes/{cnidaria,crustacea,mollusca}
mkdir -p metadata
mkdir -p quality_control

##### cnidaria genomes
echo "downloading cnidaria genomes..."
cd genomes/cnidaria || exit 1

# hydra vulgaris
wget -O hydra_vulgaris.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/900/245/855/GCA_900245855.1_ASM90024585v1/GCA_900245855.1_ASM90024585v1_genomic.fna.gz"

# clytia hemisphaerica
wget -O clytia_hemisphaerica.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/728/285/GCF_902728285.1_Clytia_hemisphaerica_genome_assembly/GCF_902728285.1_Clytia_hemisphaerica_genome_assembly_genomic.fna.gz"

# nematostella vectensis
wget -O nematostella_vectensis.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/932/526/225/GCF_932526225.1_jaNemVect1.1/GCF_932526225.1_jaNemVect1.1_genomic.fna.gz"

cd ../../

##### crustacea genomes
echo "downloading crustacea genomes..."
cd genomes/crustacea || exit 1

# daphnia pulex
wget -O daphnia_pulex.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/187/875/GCF_000187875.1_V1.0/GCF_000187875.1_V1.0_genomic.fna.gz"

# hyalella azteca
wget -O hyalella_azteca.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/691/045/GCA_000691045.1_Hyalella_azteca_genome_assembly/GCA_000691045.1_Hyalella_azteca_genome_assembly_genomic.fna.gz"

# lepeophtheirus salmonis
wget -O lepeophtheirus_salmonis.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/181/085/GCF_000181085.1_LSalAtl2s/GCF_000181085.1_LSalAtl2s_genomic.fna.gz"

cd ../../

##### mollusca genomes
echo "downloading mollusca genomes..."
cd genomes/mollusca || exit 1

# biomphalaria glabrata
wget -O biomphalaria_glabrata.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/947/242/115/GCF_947242115.1_xgBioGlab47.1/GCF_947242115.1_xgBioGlab47.1_genomic.fna.gz"

# crassostrea ariakensis
wget -O crassostrea_ariakensis.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/020/458/035/GCA_020458035.1_ASM2045803v1/GCA_020458035.1_ASM2045803v1_genomic.fna.gz"

# crassostrea gigas
wget -O crassostrea_gigas.fna.gz \
  "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/963/853/765/GCF_963853765.1_xbMagGiga1.1/GCF_963853765.1_xbMagGiga1.1_genomic.fna.gz"

cd ../../

##### extract all genomes
echo "extracting genomes..."
for dir in cnidaria crustacea mollusca; do
  cd genomes/$dir || exit 1
  for gz in *.gz; do
    [ -f "$gz" ] && gunzip "$gz"
  done
  cd ../../
done

##### quality control checks
echo "performing quality control..."
for dir in cnidaria crustacea mollusca; do
  echo "checking $dir genomes:"
  cd genomes/$dir || exit 1
  for fasta in *.fna; do
    [ -f "$fasta" ] || continue
    echo "  file: $fasta"
    echo "    sequences: $(grep -c '>' "$fasta")"
    echo "    size: $(du -h "$fasta" | cut -f1)"
    echo "    first header: $(head -1 "$fasta")"
  done
  cd ../../
done

echo "genome download and preparation complete"
