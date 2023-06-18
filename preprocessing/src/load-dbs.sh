#!/bin/bash
# Usage:  ./load-dbs.sh

# Change to base directory and create necessary subdirectories
cd $(dirname "$(dirname "$(readlink -f $0)")")
mkdir -p krakenDB localDB

# If Kraken2 database hasn't been downloaded yet
cd krakenDB
if [[ ! -f hash.k2d ]] || [[ ! -f opts.k2d ]] || [[ ! -f taxo.k2d ]]; then

  # Download Kraken2 database
  wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20230314.tar.gz

  # Decompress and remove tar.gz file
  tar -xvzf k2_standard_20230314.tar.gz
  rm -v k2_standard_20230314.tar.gz

fi
cd ..

# Clean local RGI database
docker run -v $PWD:/data finlaymaguire/rgi rgi clean --local

# If RGI database hasn't been downloaded yet
cd localDB
if [[ ! -f card.json ]]; then

  # Download and extract RGI database, remove tar.bz2 files
  wget https://card.mcmaster.ca/download/0/broadstreet-v3.2.6.tar.bz2
  tar -xvf broadstreet-v3.2.6.tar.bz2 ./card.json
  wget https://card.mcmaster.ca/download/6/prevalence-v4.0.0.tar.bz2
  mkdir -p wildcard
  tar -xjf prevalence-v4.0.0.tar.bz2 -C wildcard
  gunzip -v wildcard/*.gz
  rm -v broadstreet-v3.2.6.tar.bz2 prevalence-v4.0.0.tar.bz2

fi

# Create RGI annotation files
docker run -v $PWD:/data finlaymaguire/rgi rgi card_annotation \
  -i card.json > card_annotation.log 2>&1
docker run -v $PWD:/data finlaymaguire/rgi rgi wildcard_annotation \
  -i wildcard/ --card_json card.json -v 4.0.0 > wildcard_annotation.log 2>&1

cd ..

# Load RGI database
docker run -v $PWD:/data finlaymaguire/rgi rgi load \
  --card_json localDB/card.json \
  --debug --local \
  --card_annotation localDB/card_database_v3.2.6.fasta \
  --card_annotation_all_models localDB/card_database_v3.2.6_all.fasta \
  --wildcard_annotation localDB/wildcard_database_v4.0.0.fasta \
  --wildcard_annotation_all_models localDB/wildcard_database_v4.0.0_all.fasta \
  --wildcard_index localDB/wildcard/index-for-model-sequences.txt \
  --wildcard_version 4.0.0 \
  --amr_kmers localDB/wildcard/all_amr_61mers.txt \
  --kmer_database localDB/wildcard/61_kmer_db.json \
  --kmer_size 61

# Remove inactivate dockers
docker rm $(docker ps -a -q) > /dev/null 2>&1
