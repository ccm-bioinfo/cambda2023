#!/bin/bash

# Usage:
# ./mifaser.sh [-i input_fasta] [-o output_dir] [-s standalone_dir]

set -e

# Parse arguments
while [[ "$#" > 1 ]]; do
  case $1 in
    -i) inp="$2"; shift;;
    -o) out="$2"; shift;;
    -s) std="$2"; shift;;
  esac
  shift
done

# Verify parameters
if [ -z "$inp" ]; then >&2 echo "ERROR: Missing input fasta file"; exit 1; fi
if [ -z "$out" ]; then >&2 echo "ERROR: Missing output dir"; exit 1; fi
if [ -z "$std" ]; then >&2 echo "ERROR: Missing standalone dir"; exit 1; fi

# Verify that files exist
if [[ ! -f "$inp" ]]; then >&2 echo "ERROR: $inp doesn't exist"; exit 1; fi
if [[ ! -d "$std/mifaser/" ]]; then
  >&2 echo "ERROR: Mi-Faser not found in $std"; exit 1
fi

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with Mi-Faser started

mkdir -p $(dirname ${out})
inp=$(readlink -f "${inp}")
out=$(readlink -f "${out}")

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -rf ${out}" 2 15

# Run mifaser
cd ${std}/mifaser/
python3 -m mifaser -f "$inp" -d "GS-21-all" -t 12 -o "$out" > /dev/null 2>&1

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with Mi-Faser finished
