#!/bin/bash\
# File: week7_flanking_extraction.sh\
\
echo \'93week 7: flanking sequence extraction\'94\
\
##### create output directories\
mkdir -p flanking_sequences\
mkdir -p bed_files\
mkdir -p genome_indices\
mkdir -p week7_logs\
\
##### create genome size files for bedtools\
echo "creating genome size files..."\
for phylum in cnidaria crustacea mollusca; do\
    for genome in genomes/$phylum/*.fna; do\
        species=$(basename "$genome" .fna)\
        echo "processing genome sizes for $species"\
        \
        # create genome size file\
        awk '/^>/ \{if (seqlen) print seqname"\\t"seqlen; seqname=substr($0,2); seqlen=0; next\} \{seqlen += length($0)\} END \{print seqname"\\t"seqlen\}' $genome > genome_indices/$\{species\}.genome\
        \
        echo "  genome size file created"\
    done\
done\
\
##### extract flanking regions around filtered repeats\
for species in hydra_vulgaris clytia_hemisphaerica nematostella_vectensis daphnia_pulex hyalella_azteca lepeophtheirus_salmonis biomphalaria_glabrata crassostrea_ariakensis crassostrea_gigas; do\
    \
    echo "extracting flanking sequences"\
    \
    repeat_file="repeatmasker_output/$\{species\}.fna.out"\
    genome_file=$(find genomes -name "$\{species\}.fna" | head -1)\
    \
    if [ ! -f "$repeat_file" ]; then\
        echo "  repeat file not found for $species"\
        continue\
    fi\
    \
    if [ ! -f "$genome_file" ]; then\
        echo "  warning: genome file not found for $species"\
        continue\
    fi\
    \
    ####### convert repeatmasker output to bed format (filter for quality repeats)\
    awk 'NR>3 && $2<20 && ($7-$6+1)>200 && $11!~/Simple_repeat|Low_complexity/ \{\
        print $5"\\t"($6-1)"\\t"$7"\\t"$10"_"$11"_"NR"\\t"$1"\\t"$9\
    \}' $repeat_file > bed_files/$\{species\}_repeats.bed\
    \
    repeat_count=$(wc -l < bed_files/$\{species\}_repeats.bed)\
    echo "  found $repeat_count quality repeats"\
    \
    if [ $repeat_count -eq 0 ]; then\
        echo "  no quality repeats found for $species"\
        continue\
    fi\
    \
    ####### extend regions by 500bp on each side for flanking sequences\
    bedtools slop -i bed_files/$\{species\}_repeats.bed -g genome_indices/$\{species\}.genome -b 500 > bed_files/$\{species\}_extended.bed\
    \
    ###### extract flanking sequences\
    bedtools getfasta -fi $genome_file -bed bed_files/$\{species\}_extended.bed -fo flanking_sequences/$\{species\}_flanking.fasta -name\
    \
    ######## filter out sequences that overlap with other repeats (clean flanking regions)\
    bedtools intersect -v -a bed_files/$\{species\}_extended.bed -b bed_files/$\{species\}_repeats.bed > bed_files/$\{species\}_clean_flanking.bed\
    \
    ##### extract clean flanking sequences\
    bedtools getfasta -fi $genome_file -bed bed_files/$\{species\}_clean_flanking.bed -fo flanking_sequences/$\{species\}_clean_flanking.fasta -name\
    \
    ##### quality control - count sequences\
    total_flanking=$(grep -c ">" flanking_sequences/$\{species\}_flanking.fasta 2>/dev/null || echo 0)\
    clean_flanking=$(grep -c ">" flanking_sequences/$\{species\}_clean_flanking.fasta 2>/dev/null || echo 0)\
    \
    echo "  total flanking sequences: $total_flanking"\
    echo "  clean flanking sequences: $clean_flanking"\
    \
    #### create summary log\
    cat >> week7_logs/$\{species\}_flanking_log.txt << EOF\
species: $species\
repeat_file: $repeat_file\
genome_file: $genome_file\
quality_repeats: $repeat_count\
total_flanking_sequences: $total_flanking\
clean_flanking_sequences: $clean_flanking\
flanking_region_size: 500bp\
date: $(date)\
EOF\
    \
    echo "  flanking extraction complete for $species"\
done\
\
##### create overall summary\
echo "creating week 7 summary."\
cat > week7_flanking_summary.txt << 'EOF'\
WEEK 7: flanking sequence extraction summary\
\
objective: extract flanking regions around filtered repeats for primer design\
\
methodology:\
- filtered repeats: divergence < 20%, length > 200bp, exclude simple repeats\
- flanking region size: \'b1500bp around each repeat\
- clean flanking: regions that do not overlap with other repeats\
\
output files:\
- bed_files/: bed format coordinates for repeats and flanking regions\
- flanking_sequences/: fasta files with flanking sequences\
- genome_indices/: genome size files for bedtools\
- week7_logs/: detailed logs for each species\
\
quality control:\
- sequences extracted using bedtools getfasta\
- overlap filtering to ensure clean flanking regions\
- sequence counts logged for each species\
\
EOF\
\
##### summary statistics\
echo "generating summary statistics..."\
total_species=0\
total_clean_sequences=0\
\
for species in hydra_vulgaris clytia_hemisphaerica nematostella_vectensis daphnia_pulex hyalella_azteca lepeophtheirus_salmonis biomphalaria_glabrata crassostrea_ariakensis crassostrea_gigas; do\
    if [ -f "flanking_sequences/$\{species\}_clean_flanking.fasta" ]; then\
        count=$(grep -c ">" flanking_sequences/$\{species\}_clean_flanking.fasta)\
        total_clean_sequences=$((total_clean_sequences + count))\
        total_species=$((total_species + 1))\
        echo "$species: $count clean flanking sequences"\
    fi\
done\
\
echo ""\
echo "week 7 summary:"\
echo "species processed: $total_species"\
echo "total clean flanking sequences: $total_clean_sequences"\
echo "average sequences per species: $((total_clean_sequences / total_species))"\
\
echo "week 7 flanking sequence extraction complete"}
