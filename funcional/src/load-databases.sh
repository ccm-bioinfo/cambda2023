#!/bin/bash

# This script downloads all required databases for functional annotation and
# places them into data/databases/, skipping any database if it was already
# created. If you wish to redownload any database, remove it and run this
# script.

set -e
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p data/databases/{kegg,metacyc,uniprot,vfdb}

# kegg

## KEGG Ontology list
if [[ ! -f data/databases/kegg/ko-list.txt ]]; then
  echo $(date +"%D %T:") Downloading KEGG Ontology list.
  wget -qO- --show-progress \
    https://www.genome.jp/ftp/db/kofam/ko_list.gz \
    | gunzip > data/databases/kegg/ko-list.txt
else
  echo $(date +"%D %T:") Skipping KEGG Ontology list download.
fi

## KEGG HMM profiles
if [[ ! -d data/databases/kegg/profiles/ ]]; then
  echo $(date +"%D %T:") Downloading KEGG HMM profiles.
  wget -qO- --show-progress \
    https://www.genome.jp/ftp/db/kofam/profiles.tar.gz \
    | tar -xz -C data/databases/kegg/
else
  echo $(date +"%D %T:") Skipping KEGG HMM profiles download.
fi

# metacyc

## MetaCyc mapping file
if [[ ! -f data/databases/metacyc/map.tsv ]]; then
  echo $(date +"%D %T:") Downloading MetaCyc mapping file.
  wget -qO- --show-progress \
    https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/ec.to.pwy \
    > data/databases/metacyc/map.tsv
else
  echo $(date +"%D %T:") Skipping MetaCyc mapping file download.
fi

## MetaCyc hierarchy file
if [[ ! -f data/databases/metacyc/hierarchy.tsv ]]; then
  echo $(date +"%D %T:") Downloading MetaCyc hierarchy file.
  wget -qO- --show-progress \
    https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/pwy.hierarchy \
    > data/databases/metacyc/hierarchy.tsv
else
  echo $(date +"%D %T:") Skipping MetaCyc hierarchy file download.
fi

# uniprot

## UniProt fasta file
if [[ ! -f data/databases/uniprot/db.fa ]]; then
  echo $(date +"%D %T:") Downloading UniProt fasta file.
  wget -qO- --show-progress \
    https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz \
    | gunzip > data/databases/uniprot/db.fa
else
  echo $(date +"%D %T:") Skipping UniProt fasta file download.
fi

## UniProt BLAST database
if [[ ! -f data/databases/uniprot/db.pot ]]; then
  echo $(date +"%D %T:") Creating UniProt BLAST database.
  makeblastdb -in data/databases/uniprot/db.fa -dbtype prot \
    -out data/databases/uniprot/db -logfile data/databases/uniprot/db.log
else
  echo $(date +"%D %T:") Skipping UniProt BLAST database creation.
fi

# vfdb

## VFDB fasta file
if [[ ! -f data/databases/vfdb/db.fa ]]; then
  echo $(date +"%D %T:") Downloading VFDB fasta file.
  wget -qO- --show-progress http://www.mgc.ac.cn/VFs/Down/VFDB_setB_pro.fas.gz \
   | gunzip > data/databases/vfdb/db.fa
else
  echo $(date +"%D %T:") Skipping VFDB fasta file download.
fi

## VFDB BLAST database
if [[ ! -f data/databases/vfdb/db.pot ]]; then
  echo $(date +"%D %T:") Creating VFDB BLAST database.
  makeblastdb -in data/databases/vfdb/db.fa -dbtype prot \
    -out data/databases/vfdb/db -logfile data/databases/vfdb/db.log
else
  echo $(date +"%D %T:") Skipping VFDB BLAST database creation.
fi

echo $(date +"%D %T:") Finished.
