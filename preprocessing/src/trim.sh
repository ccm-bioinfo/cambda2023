#!/bin/bash
# Usage:  ./trim.sh [basename]

# Change to base directory and create necessary subdirectories
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p trimmed logs/trim

# If files haven't been trimmed yet
if [[ ! -f trimmed/${1}_1.fastq.gz ]]; then

  echo $(date) ${1}
  f1="raw/${1}_1.fastq.gz"
  f2="raw/${1}_2.fastq.gz"

  # Trim file
  time trim_galore -length 40 -o trimmed/ --basename ${1} --cores 4 \
    --paired --no_report_file ${f1} ${f2}

  # Rename outputs
  mv -v trimmed/${1}_val_1.fq.gz trimmed/${1}_1.fastq.gz
  mv -v trimmed/${1}_val_2.fq.gz trimmed/${1}_2.fastq.gz

fi >> logs/trim/${1}.log 2>&1
