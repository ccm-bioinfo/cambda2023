#!/bin/bash

# Usage:  ./metacyc.sh [basename]

set -e
cd $(dirname "$(dirname "$(dirname "$(readlink -f $0)")")")

inp=$(readlink -f "data/metagenomic/annotations/prokka/${1}/${1}.gff")
out=$(readlink -f "data/metagenomic/annotations/metacyc/")

echo $(date +"%D %T:") Working with ${1}

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -f ${out}/${1}.{ec,minpath,tsv}" SIGINT

mkdir -p ${out}

# Get EC numbers from .gff file
grep "eC_number=" ${inp} | cut -f9 | cut -f1,2 -d ';' | sed 's/ID=//g' \
  | sed 's/;eC_number=/\t/g' > ${out}/${1}.ec

# Predict MetaCyc pathways with MinPath
python3 software/standalone/minpath/MinPath.py \
  -any ${out}/${1}.ec \
  -map data/databases/metacyc/map.tsv \
  -report ${out}/${1}.minpath > /dev/null 2>&1

# Get hierarchy information from predicted pathways
./src/metacyc-conversion.py \
  -i ${out}/${1}.ec \
  -m data/databases/metacyc/map.tsv \
  -H data/databases/metacyc/hierarchy.tsv \
  -n ${1} \
  -l <(grep "minpath 1" ${out}/${1}.minpath) \
  -o ${out}/${1}.tsv

# Keep only .tsv file
rm ${out}/${1}.{ec,minpath}
