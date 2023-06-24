#!/bin/bash

# Usage:  ./uniprot.sh [basename]

set -e
cd $(dirname "$(dirname "$(dirname "$(readlink -f $0)")")")

inp=$(readlink -f "data/metagenomic/annotations/prokka/${1}/${1}.faa")
out=$(readlink -f "data/metagenomic/annotations/uniprot/")

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -f ${out}/${1}.tsv" SIGINT

mkdir -p ${out}

# Run blast
blastp -num_threads 12 -query ${inp} -db data/databases/uniprot/db \
  -outfmt "6 qseqid sseqid evalue pident stitle" -out ${out}/${1}.tsv

# Add column names to output .tsv file
sed -i '1s/^/qseqid\tsseqid\tevalue\tpident\tstitle\n/' ${out}/${1}.tsv
