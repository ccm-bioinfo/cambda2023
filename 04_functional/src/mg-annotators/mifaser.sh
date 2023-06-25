#!/bin/bash

# Usage:  ./mifaser.sh [basename]

set -e
cd $(dirname "$(dirname "$(dirname "$(readlink -f $0)")")")

echo $(date +"%D %T:") Annotating ${1} with Mi-Faser

inp=$(readlink -f "data/metagenomic/assemblies/${1}.fasta")
out=$(readlink -f "data/metagenomic/annotations/mifaser/")

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -rf ${out}/${1}/" 2 15

mkdir -p ${out}

# Run mifaser
cd software/standalone/mifaser/
python3 -m mifaser -f ${inp} -d "GS-21-all" -t 12 -o "${out}/${1}/" \
  > /dev/null 2>&1
