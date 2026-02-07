#!/usr/bin/env python3
# File: week5_gc_analysis.py

import os
from Bio import SeqIO
import csv

print("WEEK 5 gc content analysis\n")

##### define genome paths
genomes = {
    "hydra_vulgaris": "genomes/cnidaria/hydra_vulgaris.fna",
    "clytia_hemisphaerica": "genomes/cnidaria/clytia_hemisphaerica.fna",
    "nematostella_vectensis": "genomes/cnidaria/nematostella_vectensis.fna",
    "daphnia_pulex": "genomes/crustacea/daphnia_pulex.fna",
    "hyalella_azteca": "genomes/crustacea/hyalella_azteca.fna",
    "lepeophtheirus_salmonis": "genomes/crustacea/lepeophtheirus_salmonis.fna",
    "biomphalaria_glabrata": "genomes/mollusca/biomphalaria_glabrata.fna",
    "crassostrea_ariakensis": "genomes/mollusca/crassostrea_ariakensis.fna",
    "crassostrea_gigas": "genomes/mollusca/crassostrea_gigas.fna"
}

def get_phylum(species):
    if any(x in species for x in ["hydra", "clytia", "nematostella"]):
        return "cnidaria"
    elif any(x in species for x in ["daphnia", "hyalella", "lepeophtheirus"]):
        return "crustacea"
    else:
        return "mollusca"

def calculate_gc_content(fasta_file):
    total_a = total_c = total_g = total_t = total_n = 0

    try:
        for record in SeqIO.parse(fasta_file, "fasta"):
            seq = str(record.seq).upper()
            total_a += seq.count("A")
            total_c += seq.count("C")
            total_g += seq.count("G")
            total_t += seq.count("T")
            total_n += seq.count("N")
    except Exception as e:
        print(f"error reading {fasta_file}: {e}")
        return None

    total_bases = total_a + total_c + total_g + total_t + total_n
    if total_bases == 0:
        return None

    gc_percent = (total_g + total_c) / total_bases * 100
    at_percent = (total_a + total_t) / total_bases * 100
    n_percent = total_n / total_bases * 100

    return {
        "genome_size": total_bases,
        "gc_content": round(gc_percent, 2),
        "at_content": round(at_percent, 2),
        "n_content": round(n_percent, 2)
    }

##### create output file
with open("gc_content_results.csv", "w", newline="") as csvfile:
    fieldnames = ["species", "phylum", "genome_size_bp", "gc_content_percent", "at_content_percent", "n_content_percent"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for species, genome_file in genomes.items():
        if os.path.exists(genome_file):
            print(f"analyzing {species}...")
            phylum = get_phylum(species)

            result = calculate_gc_content(genome_file)
            if result:
                writer.writerow({
                    "species": species,
                    "phylum": phylum,
                    "genome_size_bp": result["genome_size"],
                    "gc_content_percent": result["gc_content"],
                    "at_content_percent": result["at_content"],
                    "n_content_percent": result["n_content"]
                })
            else:
                print(f"failed to analyze {species}")
        else:
            print(f"warning: {genome_file} not found")

print("gc content analysis done - results in gc_content_results.csv")
