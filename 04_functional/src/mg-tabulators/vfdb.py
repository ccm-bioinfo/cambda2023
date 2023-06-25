#!/usr/bin/env python3

# Usage:  ./vfdb.py

import math
import os
import sys
from multiprocessing import Pool
from pathlib import Path
import pandas as pd

base_dir = Path(os.path.realpath(__file__)).parent.parent.parent
inp = list(base_dir.glob("data/metagenomic/annotations/vfdb/*.tsv"))
out = base_dir/"data/metagenomic/tables/"

os.makedirs(out, exist_ok=True)
counts = []

# Returns a Pandas series with counts of BLAST results with identity >= 80%
def process_tsv(file):
    table = pd.read_csv(file, delimiter="\t", usecols=["sseqid", "pident"])
    table = table[table["pident"] >= 80.0]["sseqid"].value_counts()
    table.name = file.stem
    return table

# Use a quarter of the CPUs available for the process_tsv function
with Pool(processes=math.ceil(os.cpu_count() / 4)) as pool:
    for i, count in enumerate(pool.imap_unordered(process_tsv, inp)):
        progress = (i+1) / len(inp) * 100
        sys.stderr.write(f"VFDB tabulation progress: {progress:.2f}%\r")
        counts.append(count)

# Create output table and save
print(f"VFDB tabulation progress: Concatenating...", end="\r")
data = pd.concat(counts, axis=1).T.fillna(0)
data["City"] = data.index.str[23:26]
cols = ["City"] + list(data.columns[:-1])
data = data.reindex(columns=cols).sort_index()
print(f"VFDB tabulation progress: Saving...       ", end="\r")
data.to_csv(out/"vfdb.tsv.gz", sep="\t", index=True, compression="gzip")
print(f"VFDB tabulation progress: Done!           ")
