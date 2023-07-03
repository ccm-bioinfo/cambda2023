#!/bin/bash

# Usage:
# ./kegg.sh [-i input_faa] [-o output_txt] [-d databases_dir]

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
if [ -z "$out" ]; then >&2 echo "ERROR: Missing output txt file"; exit 1; fi
if [ -z "$db" ]; then >&2 echo "ERROR: Missing database dir"; exit 1; fi

# Verify that files exist
if [[ ! -f "$inp" ]]; then >&2 echo "ERROR: $inp doesn't exist"; exit 1; fi
if [[ ! -d "$db/kegg/" ]]; then
  >&2 echo "ERROR: KEGG database not found in $db"; exit 1
fi

# Check that exec_annotation command exists
if ! command -v exec_annotation &> /dev/null; then
  >&2 echo "ERROR: exec_annotation command not found"; exit 1
fi

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with KEGG started

rand=$(echo $$${RANDOM})  # For temporary directory

mkdir -p "$(dirname ${out})" tmp-${rand}/

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -f ${out}" 2 15
trap "rm -rf tmp-${rand}/" EXIT

# Run kofamscan
exec_annotation --cpu 12 -o ${out} -p "${db}/kegg/profiles/" \
  -k "${db}/kegg/ko-list.txt" --tmp-dir "tmp-${rand}/" ${inp} \
  > /dev/null 2>&1

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with KEGG finished
