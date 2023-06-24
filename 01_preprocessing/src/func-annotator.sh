#!/bin/bash
# Performs functional annotation on the assembled metagenome of a basename,
# skips if already done. Run with venv/ actvated.

# Usage:  ./func-annotator.sh [basename]


# Change to base directory and create necessary subdirectories
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p functions logs/func-annotator

# prokka --outdir functions/${1} --norrna --notrna --prefix ${1} --metagenome \
#   --cpus 32 assembled/${1}.fasta

# grep "eC_number=" functions/${1}/${1}.gff | cut -f9 | cut -f1,2 -d ';' \
#   | sed 's/ID=//g' | sed 's/;eC_number=/\t/g' > functions/${1}/${1}.ec
# egrep "COG[0-9]{4}" functions/${1}/${1}.gff | cut -f9 | \
#   sed 's/.\+COG\([0-9]\+\);locus_tag=\(PROKKA_[0-9]\+\);.\+/\2\tCOG\1/g' \
#   > functions/${1}/${1}.cog

