#!/bin/bash

# Usage:
# ./metacyc.sh [-i input_gff] [-o output_tsv] [-s standalone_dir]
#              [-d databases_dir]

set -e
src=$(dirname $(dirname $(readlink -f $0)))

# Parse arguments
while [[ "$#" > 1 ]]; do
  case $1 in
    -i) inp="$2"; shift;;
    -o) out="$2"; shift;;
    -d) db="$2"; shift;;
    -s) std="$2"; shift;;
  esac
  shift
done

# Verify parameters
if [ -z "$inp" ]; then >&2 echo "ERROR: Missing input gff file"; exit 1; fi
if [ -z "$out" ]; then >&2 echo "ERROR: Missing output tsv file"; exit 1; fi
if [ -z "$db" ]; then >&2 echo "ERROR: Missing database dir"; exit 1; fi
if [ -z "$std" ]; then >&2 echo "ERROR: Missing standalone dir"; exit 1; fi

# Verify that files exist
if [[ ! -f "$inp" ]]; then >&2 echo "ERROR: $inp doesn't exist"; exit 1; fi
if [[ ! -d "$db/metacyc/" ]]; then
  >&2 echo "ERROR: MetaCyc database not found in $db"; exit 1
fi
if [[ ! -d "$std/minpath/" ]]; then
  >&2 echo "ERROR: MinPath not found in $std"; exit 1
fi

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with MetaCyc started

# Remove outputs if the script is stopped with Ctrl-C
trap "rm -f ${out%.*}.{ec,minpath,tsv}" 2 15

mkdir -p "$(dirname ${out})"

# Get EC numbers from .gff file
grep "eC_number=" ${inp} | cut -f9 | cut -f1,2 -d ';' | sed 's/ID=//g' \
  | sed 's/;eC_number=/\t/g' > ${out%.*}.ec

# Predict MetaCyc pathways with MinPath
python3 ${std}/minpath/MinPath.py \
  -any ${out%.*}.ec \
  -map ${db}/metacyc/map.tsv \
  -report ${out%.*}.minpath > /dev/null 2>&1

# Get hierarchy information from predicted pathways
${src}/metacyc-conversion.py \
  -i ${out%.*}.ec \
  -m ${db}/metacyc/map.tsv \
  -H ${db}/metacyc/hierarchy.tsv \
  -n $(basename ${out%.*}) \
  -l <(grep "minpath 1" ${out%.*}.minpath) \
  -o ${out%.*}.tsv

# Keep only .tsv file
rm ${out%.*}.{ec,minpath}

echo $(date +"%D %T:") Annotation of $(basename ${inp%.*}) with MetaCyc finished
