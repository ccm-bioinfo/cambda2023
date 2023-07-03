#!/bin/bash

# Usage: ./load-databases.sh [output_dir]

set -e
if [ -z "$1" ]; then >&2 echo "ERROR: Missing output directory"; exit 1; fi
mkdir -p ${1}/{kegg,metacyc,uniprot,vfdb}

# kegg

## KEGG Ontology list
if [[ ! -f ${1}/kegg/ko-list.txt ]]; then
  echo $(date +"%D %T:") Downloading KEGG Ontology list.
  wget -qO- --show-progress \
    https://www.genome.jp/ftp/db/kofam/ko_list.gz \
    | gunzip > ${1}/kegg/ko-list.txt
else
  echo $(date +"%D %T:") Skipping KEGG Ontology list download.
fi

## KEGG HMM profiles
if [[ ! -d ${1}/kegg/profiles/ ]]; then
  echo $(date +"%D %T:") Downloading KEGG HMM profiles.
  wget -qO- --show-progress \
    https://www.genome.jp/ftp/db/kofam/profiles.tar.gz \
    | tar -xz -C ${1}/kegg/
else
  echo $(date +"%D %T:") Skipping KEGG HMM profiles download.
fi

# metacyc

## MetaCyc mapping file
if [[ ! -f ${1}/metacyc/map.tsv ]]; then
  echo $(date +"%D %T:") Downloading MetaCyc mapping file.
  wget -qO- --show-progress \
    https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/ec.to.pwy \
    > ${1}/metacyc/map.tsv
else
  echo $(date +"%D %T:") Skipping MetaCyc mapping file download.
fi

## MetaCyc hierarchy file
if [[ ! -f ${1}/metacyc/hierarchy.tsv ]]; then
  echo $(date +"%D %T:") Downloading MetaCyc hierarchy file.
  wget -qO- --show-progress \
    https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/pwy.hierarchy \
    > ${1}/metacyc/hierarchy.tsv
else
  echo $(date +"%D %T:") Skipping MetaCyc hierarchy file download.
fi

# uniprot

## UniProt fasta file
if [[ ! -f ${1}/uniprot/db.fa ]]; then
  echo $(date +"%D %T:") Downloading UniProt fasta file.
  wget -qO- --show-progress \
    https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz \
    | gunzip > ${1}/uniprot/db.fa
else
  echo $(date +"%D %T:") Skipping UniProt fasta file download.
fi

## UniProt BLAST database
if [[ ! -f ${1}/uniprot/db.pot ]]; then
  echo $(date +"%D %T:") Creating UniProt BLAST database.
  makeblastdb -in ${1}/uniprot/db.fa -dbtype prot \
    -out ${1}/uniprot/db -logfile ${1}/uniprot/db.log
else
  echo $(date +"%D %T:") Skipping UniProt BLAST database creation.
fi

# vfdb

## VFDB fasta file
if [[ ! -f ${1}/vfdb/db.fa ]]; then
  echo $(date +"%D %T:") Downloading VFDB fasta file.
  wget -qO- --show-progress http://www.mgc.ac.cn/VFs/Down/VFDB_setB_pro.fas.gz \
   | gunzip > ${1}/vfdb/db.fa
else
  echo $(date +"%D %T:") Skipping VFDB fasta file download.
fi

## VFDB BLAST database
if [[ ! -f ${1}/vfdb/db.pot ]]; then
  echo $(date +"%D %T:") Creating VFDB BLAST database.
  makeblastdb -in ${1}/vfdb/db.fa -dbtype prot \
    -out ${1}/vfdb/db -logfile ${1}/vfdb/db.log
else
  echo $(date +"%D %T:") Skipping VFDB BLAST database creation.
fi

echo $(date +"%D %T:") Finished.
