#!/bin/bash

# Usage:  ./prokka.sh [-g] [-i input_fasta] [-o output_dir]

set -e
genomic=false

# Parse arguments
while [[ "$#" > 1 ]]; do
  case $1 in
    -g) genomic=true;;
    -i) inp="$2"; shift;;
    -o) out="$2"; shift;;
  esac
  shift
done

# Verify parameters
if [ -z "$inp" ]; then >&2 echo "ERROR: Missing input fasta file"; exit 1; fi
if [ -z "$out" ]; then >&2 echo "ERROR: Missing output dir"; exit 1; fi

# Verify that files exist
if [[ ! -f "$inp" ]]; then >&2 echo "ERROR: $inp doesn't exist"; exit 1; fi

# Check that prokka command exists
if ! command -v prokka &> /dev/null; then
  >&2 echo "ERROR: prokka command not found"; exit 1
fi

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with Prokka started

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -rf ${out}" 2 15

mkdir -p "$(dirname ${out})"
prefix=$(basename ${out})

# Run Prokka
if [[ $genomic == true ]]; then
  prokka --outdir ${out} --prefix ${prefix} --cpus 12 ${inp} \
    > /dev/null 2>&1
else
  prokka --outdir ${out} --prefix ${prefix} --metagenome --cpus 12 ${inp} \
    > /dev/null 2>&1
fi

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with Prokka finished
