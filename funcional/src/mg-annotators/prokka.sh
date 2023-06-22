#!/bin/bash

# Usage:  ./prokka.sh [basename]

set -e
cd $(dirname "$(dirname "$(dirname "$(readlink -f $0)")")")

inp=$(readlink -f "data/metagenomic/assemblies/${1}.fasta")
out=$(readlink -f "data/metagenomic/annotations/prokka/")

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -rf ${out}/${1}/" SIGINT

mkdir -p ${out}

# Run Prokka
prokka --outdir ${out}/${1}/ --prefix ${1} --metagenome --cpus 12 ${inp} \
  > /dev/null 2>&1
