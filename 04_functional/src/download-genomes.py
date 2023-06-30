#!/usr/bin/env python3

import io
import os
import gzip
import shutil
from pathlib import Path
from subprocess import check_output
from urllib.request import urlopen

import pandas as pd

base_dir = Path(os.path.realpath(__file__)).parent.parent
out = base_dir/"data/genomic/assemblies/"
os.makedirs(out, exist_ok=True)

cities = {
    "New York": "NYC",
    "Baltimore": "BAL",
    "San Antonio": "SAN",
    "Minneapolis": "MIN"
}
species = {
    "Klebsiella pneumoniae": "KP",
    "Escherichia coli": "EC",
    "Enterobacter hormaechei": "EH"
}
genomes = pd.read_csv(
    "https://raw.githubusercontent.com/ccm-bioinfo/cambda2023/main/06_amr_resistance/data/genome-metadata.csv",
    index_col="accession"
)

def download_genome(acc, year, spp, city):
    # Get assembly name
    assembly = pd.read_csv(io.StringIO(check_output(
        f"datasets summary genome accession '{acc}' --as-json-lines "
        f"| dataformat tsv genome --fields 'assminfo-name'", shell=True
    ).decode()))["Assembly Name"][0]

    # Get FTP URL for download
    url = (
        f"https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/{acc[4:7]}/{acc[7:10]}"
        f"/{acc[10:13]}/{acc}_{assembly}/{acc}_{assembly}_genomic.fna.gz"
    )

    # Open and decompress .fna.gzip file
    with gzip.GzipFile(fileobj=urlopen(url), mode='rb') as gz:
        with open(out/f"{city}_{year}_{spp}_{acc}.fna", mode='wb') as fna:
            shutil.copyfileobj(gz, fna)

for acc, row in genomes.iterrows():
    year, city, spp, _ = list(row)
    city = cities[city]
    spp = species[spp]
    print(f"Downloading {acc}")
    download_genome(acc, year, spp, city)
