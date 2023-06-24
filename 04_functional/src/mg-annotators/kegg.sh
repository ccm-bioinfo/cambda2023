#!/bin/bash

# Usage:  ./kegg.sh [basename]

set -e
cd $(dirname "$(dirname "$(dirname "$(readlink -f $0)")")")

echo $(date +"%D %T:") Annotating ${1} with KEGG

inp=$(readlink -f "data/metagenomic/annotations/prokka/${1}/${1}.faa")
out=$(readlink -f "data/metagenomic/annotations/kegg/")
db=$(readlink -f "data/databases/kegg/")
rand=$(echo $$${RANDOM})  # For temporary directory

mkdir -p ${out} tmp/${rand}/

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -f ${out}/${1}.txt" SIGINT
trap "rm -rf tmp/${rand}/" EXIT

# Run kofamscan
./software/standalone/kofamscan/exec_annotation --cpu 12 -o ${out}/${1}.txt \
  -p "${db}/profiles/" -k "${db}/ko-list.txt" --tmp-dir "tmp/${rand}/" ${inp} \
  > /dev/null 2>&1
