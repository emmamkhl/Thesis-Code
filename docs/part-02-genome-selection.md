{\rtf1\ansi\ansicpg1252\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
# File: week2_genome_download.sh\
\
echo \'93part 2: genome download and prep"\
\
##### create directory structure\
mkdir -p genomes/\{cnidaria,crustacea,mollusca\}\
mkdir -p metadata\
mkdir -p quality_control\
\
###### cnidaria genomes\
echo "downloading cnidaria genomes..."\
cd genomes/cnidaria\
\
# hydra vulgaris\
wget -O hydra_vulgaris.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/900/245/855/GCA_900245855.1_ASM90024585v1/GCA_900245855.1_ASM90024585v1_genomic.fna.gz"\
\
# clytia hemisphaerica\
wget -O clytia_hemisphaerica.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/902/728/285/GCF_902728285.1_Clytia_hemisphaerica_genome_assembly/GCF_902728285.1_Clytia_hemisphaerica_genome_assembly_genomic.fna.gz"\
\
# nematostella vectensis\
wget -O nematostella_vectensis.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/932/526/225/GCF_932526225.1_jaNemVect1.1/GCF_932526225.1_jaNemVect1.1_genomic.fna.gz"\
\
cd ../../\
\
##### crustacea genomes\
echo "downloading crustacea genomes..."\
cd genomes/crustacea\
\
## daphnia pulex\
wget -O daphnia_pulex.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/187/875/GCF_000187875.1_V1.0/GCF_000187875.1_V1.0_genomic.fna.gz"\
\
# hyalella azteca\
wget -O hyalella_azteca.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/691/045/GCA_000691045.1_Hyalella_azteca_genome_assembly/GCA_000691045.1_Hyalella_azteca_genome_assembly_genomic.fna.gz"\
\
# lepeophtheirus salmonis\
wget -O lepeophtheirus_salmonis.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/181/085/GCF_000181085.1_LSalAtl2s/GCF_000181085.1_LSalAtl2s_genomic.fna.gz"\
\
cd ../../\
\
###### mollusca genomes\
echo "downloading mollusca genomes..."\
cd genomes/mollusca\
\
# biomphalaria glabrata\
wget -O biomphalaria_glabrata.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/947/242/115/GCF_947242115.1_xgBioGlab47.1/GCF_947242115.1_xgBioGlab47.1_genomic.fna.gz"\
\
## crassostrea ariakensis\
wget -O crassostrea_ariakensis.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/020/458/035/GCA_020458035.1_ASM2045803v1/GCA_020458035.1_ASM2045803v1_genomic.fna.gz"\
\
# crassostrea gigas\
wget -O crassostrea_gigas.fna.gz "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/963/853/765/GCF_963853765.1_xbMagGiga1.1/GCF_963853765.1_xbMagGiga1.1_genomic.fna.gz"\
\
cd ../../\
\
####### extract all genomes\
echo "extracting genomes..."\
for dir in cnidaria crustacea mollusca; do\
    cd genomes/$dir\
    for gz in *.gz; do\
        if [ -f "$gz" ]; then\
            gunzip "$gz"\
        fi\
    done\
    cd ../../\
done\
\
######### quality control check\
echo "performing quality control..."\
for dir in cnidaria crustacea mollusca; do\
    echo "checking $dir genomes:"\
    cd genomes/$dir\
    for fasta in *.fna; do\
        if [ -f "$fasta" ]; then\
            echo "  file: $fasta"\
            echo "    sequences: $(grep -c '>' $fasta)"\
            echo "    size: $(du -h $fasta | cut -f1)"\
            echo "    first header: $(head -1 $fasta)"\
        fi\
    done\
    cd ../../\
done\
\
echo "genome download and prep done\'94}
