#!/bin/bash

# Change directory
# cd ~/c23

# Data downloading
if [ ! -d "taxonomy" ]; then 
    mkdir taxonomy
fi
cd ./taxonomy

# Download and unzip the count data for OTU from reads
if [ ! -f reads-biom.tsv ]; then 
    wget https://github.com/ccm-bioinfo/cambda2023/raw/main/preprocessing/taxonomy/read-biom.tsv.gz
    gzip -d read-biom.tsv.gz
fi

# Download and unzip the count data for OTU with assemblies
if [ ! -f assembly-biom.tsv ]; then 
    wget https://github.com/ccm-bioinfo/cambda2023/raw/main/preprocessing/taxonomy/assembly-biom.tsv.gz
    gzip -d assembly-biom.tsv.gz
fi

# Download and unzip the biom data for OTU with reads
if [ ! -f reads-biom.json ]; then 
    wget https://github.com/ccm-bioinfo/cambda2023/raw/main/preprocessing/taxonomy/read-biom.json.gz
    gzip -d read-biom.json.gz
fi

# Download and unzip the biom data for OTU with assemblies
if [ ! -f assembly-biom.json ]; then 
    wget https://github.com/ccm-bioinfo/cambda2023/raw/main/preprocessing/taxonomy/assembly-biom.json.gz
    gzip -d assembly-biom.json.gz
fi

# Return to main directory
cd ..

# Run the script to create tables by taxonomic levels
# Reads
Rscript ./codes/biom_to_counts_by_taxlevel.R

# Assembly
Rscript ./codes/biom_to_counts_by_taxlevel.R -r FALSE

# Separate reads and assembly 
cd ./taxonomy-levels/

mkdir reads
mv reads* reads/
mkdir assembly
mv assembly* assembly
