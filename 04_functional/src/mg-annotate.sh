#!/bin/bash


set -e
cd $(dirname "$(dirname "$(readlink -f $0)")")

# Check that number of jobs has been typed
if [ -z ${1} ]; then
  echo "Missing [number of jobs] parameter"
  echo "For example: ./mg-annotate.sh 5"
  exit 1
fi

# Get all basenames
echo $(date +"%D %T:") Getting basenames
bases=$(
  for file in data/metagenomic/assemblies/*.fasta;
    do echo $(basename ${file%%.fasta})
  done
)


## Prokka ##
# Check for missing Prokka annotations
echo $(date +"%D %T:") Prokka annotation started
missing_prokka=$(
  for base in ${bases}; do
    if [[ ! -f data/metagenomic/annotations/prokka/${base}/${base}.txt ]]
      then echo ${base}
    fi
  done
)

# Run missing Prokka annotations
if [[ ! -z ${missing_prokka} ]]; then
  parallel -uj ${1} ./src/mg-annotators/prokka.sh ::: ${missing_prokka}
fi

echo $(date +"%D %T:") Prokka annotation finished


# KEGG ##
# Check for missing KEGG annotations
echo $(date +"%D %T:") KEGG annotation started
missing_kegg=$(
  for base in ${bases}; do
    if [[ ! -f data/metagenomic/annotations/kegg/${base}.txt ]]
      then echo ${base}
    fi
  done
)

# Run missing KEGG annotations
if [[ ! -z ${missing_kegg} ]]; then
  parallel -uj ${1} ./src/mg-annotators/kegg.sh ::: ${missing_kegg}
fi

echo $(date +"%D %T:") KEGG annotation finished


## MetaCyc ##
# Check for missing MetaCyc annotations
echo $(date +"%D %T:") MetaCyc annotation started
missing_metacyc=$(
  for base in ${bases}; do
    if [[ ! -f data/metagenomic/annotations/metacyc/${base}.tsv ]]
      then echo ${base}
    fi
  done
)

# Run missing MetaCyc annotations (ignore parameter, run one job at a time)
if [[ ! -z ${missing_metacyc} ]]; then
  parallel -uj 1 ./src/mg-annotators/metacyc.sh ::: ${missing_metacyc}
fi

echo $(date +"%D %T:") MetaCyc annotation finished


## Mi-Faser ##
# Check for missing Mi-Faser annotations
echo $(date +"%D %T:") Mi-Faser annotation started
missing_mifaser=$(
  for base in ${bases}; do
    if [[ ! -f data/metagenomic/annotations/mifaser/${base}/analysis.tsv ]]
      then echo ${base}
    fi
  done
)

# Run missing Mi-Faser annotations (ignore parameter, run one job at a time)
if [[ ! -z ${missing_mifaser} ]]; then
  parallel -uj ${1} ./src/mg-annotators/mifaser.sh ::: ${missing_mifaser}
fi

echo $(date +"%D %T:") Mi-Faser annotation finished


## UniProt ##
# Check for missing UniProt annotations
echo $(date +"%D %T:") UniProt annotation started
missing_uniprot=$(
  for base in ${bases}; do
    if [[ ! -f data/metagenomic/annotations/uniprot/${base}.tsv ]]
      then echo ${base}
    fi
  done
)

# Run missing UniProt annotations (ignore parameter, run one job at a time)
if [[ ! -z ${missing_uniprot} ]]; then
  parallel -uj ${1} ./src/mg-annotators/uniprot.sh ::: ${missing_uniprot}
fi

echo $(date +"%D %T:") UniProt annotation finished


## VFDB ##
# Check for missing VFDB annotations
echo $(date +"%D %T:") VFDB annotation started
missing_vfdb=$(
  for base in ${bases}; do
    if [[ ! -f data/metagenomic/annotations/vfdb/${base}.tsv ]]
      then echo ${base}
    fi
  done
)

# Run missing VFDB annotations (ignore parameter, run one job at a time)
if [[ ! -z ${missing_vfdb} ]]; then
  parallel -uj ${1} ./src/mg-annotators/vfdb.sh ::: ${missing_vfdb}
fi

echo $(date +"%D %T:") VFDB annotation finished
