#!/bin/bash

set -e
cd $(dirname "$(dirname "$(readlink -f $0)")")

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
if [[ ! -d software/venv/ ]]; then
  echo $(date +"%D %T:") Using $packager as package manager.

  # Install required software using the selected package manager
  $packager create -q -y -p ./software/venv -f software/environment.yml

  # Comment tbl2asn lines so the program isn't executed
  # tbl2asn is extremely slow for metagenomic assemblies so it was avoided
  sed -i '1412,1415 {/^#/! s/^/#/}' software/venv/bin/prokka
  sed -i '1420 {/^#/! s/^/#/}' software/venv/bin/prokka

  echo $(date +"%D %T:") Virtual environment created successfully.
else
  echo $(date +"%D %T:") Skipping environment creation as software/venv \
    already exists.
fi

# If minpath hasn't been downloaded yet
if [[ ! -d software/standalone/minpath/ ]]; then
  echo $(date +"%D %T:") Cloning MinPath GitHub repository.
  
  # Clone repository and set to specific commit ID for reproducibility
  git clone https://github.com/mgtools/MinPath/ software/standalone/minpath
  cd software/standalone/minpath
  git checkout 46d3e81a4dca2310d558bea970bc002b15d44767
  cd ../../..
else
  echo $(date +"%D %T:") Skipping MinPath Github repository cloning.
fi

# If kofamscan hasn't been downloaded yet
if [[ ! -d software/standalone/kofamscan/ ]]; then
  echo $(date +"%D %T:") Cloning kofam_scan GitHub repository.
  
  # Clone repository and set to specific commit ID for reproducibility
  git clone https://github.com/takaram/kofam_scan/ software/standalone/kofamscan
  cd software/standalone/kofamscan
  git checkout 62cee3943aa28b96f498150f5e0bb2d7c498e648
  cd ../../..
else
  echo $(date +"%D %T:") Skipping kofam_scan Github repository cloning.
fi

# If mifaser hasn't been downloaded yet
if [[ ! -d software/standalone/mifaser/ ]]; then
  echo $(date +"%D %T:") Cloning mifaser Bitbucket repository.
  
  # Clone repository and set to specific commit ID for reproducibility
  git clone https://bitbucket.org/bromberglab/mifaser/ software/standalone/mifaser
  cd software/standalone/mifaser
  git checkout 8012b2676eb3d2548db569191d19c0da9f64330c
  cd ../../..
else
  echo $(date +"%D %T:") Skipping kofam_scan Bitbucket repository cloning.
fi
