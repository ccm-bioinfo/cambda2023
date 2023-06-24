#!/bin/bash
# Classifies taxonomically the trimmed and assembled metagenomes of a basename,
# skips if already done. Run with venv/ activated. Outputs to 
# taxonomy/read-level/[basename].report and 
# taxonomy/assembly-level/[basename].report.

# Usage:  ./classify.sh [basename]


# Change to base directory and create necessary subdirectories
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p taxonomy/read-level taxonomy/assembly-level logs/classify

# Get input read-level filenames
f1="trimmed/${1}_1.fastq.gz"
f2="trimmed/${1}_2.fastq.gz"

# Get input assembly-level filenames
f3="assembled/${1}.fasta"

# If basename hasn't been classified at read level yet
if [[ ! -f taxonomy/read-level/${1}.report ]]; then

  echo ""
  echo $(date) ${1} at read level

  # Run taxonomic classification on read level
  time kraken2 --db krakenDB/ --threads 16 --output '-' \
    --report taxonomy/read-level/${1}.report --paired --gzip-compressed \
    ${f1} ${f2}

fi >> logs/classify/${1}.log 2>&1

# If basename hasn't been classified at assembly level yet
if [[ ! -f taxonomy/assembly-level/${1}.report ]]; then

  echo ""
  echo $(date) ${1} at read level

  # Run taxonomic classification on assembly level
  time kraken2 --db krakenDB/ --threads 16 --output '-' \
    --report taxonomy/assembly-level/${1}.report ${f3}
  
fi >> logs/classify/${1}.log 2>&1
