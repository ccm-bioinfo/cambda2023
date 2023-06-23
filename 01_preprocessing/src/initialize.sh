#!/bin/bash
# Usage:  ./initialize.sh

# Create virtual environment in venv/
cd $(dirname "$(dirname "$(readlink -f $0)")")
conda create -y -c conda-forge -c anaconda -c defaults -c bioconda -p ./venv \
  bedtools bowtie2 kraken2 krona megahit numpy picard prokka samtools trim-galore

# Pull RGI docker image
docker pull finlaymaguire/rgi:latest

# Clone MinPath repository
git clone https://github.com/mgtools/MinPath.git minpath
