#!/bin/bash

# Usage:
# ./download-software.sh [output software directory]

set -e
if [ -z "$1" ]; then >&2 echo "ERROR: Missing output directory"; exit 1; fi
currdir=$(pwd)
yml=$(dirname "$(dirname "$(readlink -f $0)")")/environment.yml
mkdir -p $1/standalone/

# Detect package manager (micromamba, mamba or conda)
if command -v micromamba &> /dev/null; then
  packager="micromamba"
elif command -v mamba &> /dev/null; then
  packager="mamba"
elif command -v conda &> /dev/null; then
  packager="conda"
else
  echo $(date +"%D %T:") Package manager '(conda, etc.)' not found.
  exit 1
fi

# If the virtual environment hasn't been created yet
if [[ ! -d $1/venv/ ]]; then
  echo $(date +"%D %T:") Using $packager as package manager.

  # Install required software using the selected package manager
  $packager create -q -y -p ./$1/venv -f ${yml}

  # Comment tbl2asn lines so the program isn't executed
  # tbl2asn is extremely slow for metagenomic assemblies so it was avoided
  sed -i '1412,1415 {/^#/! s/^/#/}' ${1}/venv/bin/prokka
  sed -i '1420 {/^#/! s/^/#/}' ${1}/venv/bin/prokka

  echo $(date +"%D %T:") Virtual environment created successfully.
else
  echo $(date +"%D %T:") Skipping environment creation as ${1}/venv \
    already exists.
fi

# If minpath hasn't been downloaded yet
if [[ ! -d ${1}/standalone/minpath/ ]]; then
  echo $(date +"%D %T:") Cloning MinPath GitHub repository.
  
  # Clone repository and set to specific commit ID for reproducibility
  git clone https://github.com/mgtools/MinPath/ ${1}/standalone/minpath
  cd ${1}/standalone/minpath
  git checkout 46d3e81a4dca2310d558bea970bc002b15d44767
  cd ${currdir}
else
  echo $(date +"%D %T:") Skipping MinPath Github repository cloning.
fi

# If mifaser hasn't been downloaded yet
if [[ ! -d ${1}/standalone/mifaser/ ]]; then
  echo $(date +"%D %T:") Cloning mifaser Bitbucket repository.
  
  # Clone repository and set to specific commit ID for reproducibility
  git clone https://bitbucket.org/bromberglab/mifaser/ ${1}/standalone/mifaser
  cd ${1}/standalone/mifaser
  git checkout 8012b2676eb3d2548db569191d19c0da9f64330c
  cd ${currdir}
else
  echo $(date +"%D %T:") Skipping mifaser Bitbucket repository cloning.
fi
