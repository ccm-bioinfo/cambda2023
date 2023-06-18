#!/bin/bash
# Assembles the trimmed metagenome of a basename, skips if already done. Run
# with venv/ activated. Outputs to assembled/[basename].fasta

# Usage:  ./assemble.sh [basename]


# Change to base directory and create necessary subdirectories
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p assembled logs/assemble/ tmp/

# If basename hasn't been assembled yet
if [[ ! -f assembled/${1}.fasta ]]; then

  echo ""
  echo $(date) ${1}

  # Get input filenames
  f1="trimmed/${1}_1.fastq.gz"
  f2="trimmed/${1}_2.fastq.gz"

  # Run assembly on input
  time megahit -1 ${f1} -2 ${f2} -t 16 -o assembled/${1} \
    --out-prefix ${1} --tmp-dir tmp/

  # Remove extra files
  mv -v assembled/${1}/${1}.contigs.fa assembled/${1}.fasta
  rm -rf assembled/${1}/

fi >> logs/assemble/${1}.log 2>&1
