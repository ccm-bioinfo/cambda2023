#!/usr/bin/env python3

# Usage:  ./uniprot.py [-g] [input directory] [output directory]

import math
import os
import sys
from multiprocessing import Pool
from pathlib import Path
import pandas as pd

# Check if -g flag was used
try:
    genomic = sys.argv.index("-g")
    del sys.argv[genomic]
except ValueError:
    genomic = 0

try: inp = list(Path(sys.argv[1]).glob("*.tsv"))
except IndexError:
    print("ERROR: Missing input directory", file=sys.stderr)
    sys.exit(1)

try: out = Path(sys.argv[2])
except IndexError:
    print("ERROR: Missing output directory", file=sys.stderr)
    sys.exit(1)

os.makedirs(out, exist_ok=True)
counts = []

# Returns a Pandas series with counts of BLAST results with identity >= 80%
def process_tsv(file):
    table = pd.read_csv(file, delimiter="\t", usecols=["sseqid", "pident"])
    table = table[table["pident"] >= 80.0]["sseqid"].value_counts()
    table.name = file.stem
    return table

# Use a quarter of the CPUs available for the process_tsv function
with Pool(processes=math.ceil(os.cpu_count() / 8)) as pool:
    for i, count in enumerate(pool.imap_unordered(process_tsv, inp)):
        progress = (i+1) / len(inp) * 100
        print(
            f"UniProt tabulation progress: {progress:.2f}%",
            file=sys.stderr, end="\r")
        counts.append(count)

# Create output table and save
print(
    f"UniProt tabulation progress: Concatenating...", file=sys.stderr, end="\r"
)
data = pd.concat(counts, axis=1).T.fillna(0)
if genomic:
    data["City"] = data.index.str[:3]
    data["Taxon"] = data.index.str[4:6]
    cols = ["City", "Taxon"] + list(data.columns[:-2])
else:
    data["City"] = data.index.str[23:26]
    cols = ["City"] + list(data.columns[:-1])
data = data.reindex(columns=cols).sort_index()
print(
    f"UniProt tabulation progress: Saving...       ", file=sys.stderr, end="\r"
)
data.to_csv(out/"uniprot.tsv.gz", sep="\t", index=True, compression="gzip")
print(
    f"UniProt tabulation progress: Done!           ", file=sys.stderr
)
