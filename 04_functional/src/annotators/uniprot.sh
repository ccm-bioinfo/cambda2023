#!/bin/bash

# Usage:
# ./uniprot.sh [-i input_faa] [-o output_tsv] [-d databases_dir]

set -e

# Parse arguments
while [[ "$#" > 1 ]]; do
  case $1 in
    -i) inp="$2"; shift;;
    -o) out="$2"; shift;;
    -d) db="$2"; shift;;
  esac
  shift
done

# Verify parameters
if [ -z "$inp" ]; then >&2 echo "ERROR: Missing input faa file"; exit 1; fi
if [ -z "$out" ]; then >&2 echo "ERROR: Missing output tsv file"; exit 1; fi
if [ -z "$db" ]; then >&2 echo "ERROR: Missing database dir"; exit 1; fi

# Verify that files exist
if [[ ! -f "$inp" ]]; then >&2 echo "ERROR: $inp doesn't exist"; exit 1; fi
if [[ ! -d "$db/uniprot/" ]]; then
  >&2 echo "ERROR: UniProt database not found in $db"; exit 1
fi

# Check that blastp command exists
if ! command -v blastp &> /dev/null; then
  >&2 echo "ERROR: blastp command not found"; exit 1
fi

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with UniProt started

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -f ${out}" 2 15

mkdir -p "$(dirname ${out})"

# Run blast
blastp -num_threads 12 -query ${inp} -db ${db}/uniprot/db \
  -outfmt "6 qseqid sseqid evalue pident stitle" -out ${out}

# Add column names to output .tsv file
sed -i '1s/^/qseqid\tsseqid\tevalue\tpident\tstitle\n/' ${out}

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with UniProt finished
