#!/usr/bin/env python3

# Usage:  ./mifaser.py [-g] [input_dir] [output_dir]

import os
import sys
from pathlib import Path
import pandas as pd

# Check if -g flag was used
try:
    genomic = sys.argv.index("-g")
    del sys.argv[genomic]
except ValueError:
    genomic = 0

try: inp = list(Path(sys.argv[1]).glob("*/ec_count.tsv"))
except IndexError:
    print("ERROR: Missing input directory", file=sys.stderr)
    sys.exit(1)

try: out = Path(sys.argv[2])/"mifaser"
except IndexError:
    print("ERROR: Missing output directory", file=sys.stderr)
    sys.exit(1)

os.makedirs(out, exist_ok=True)

i = 0

# Creates a series of ec: count for each file
def load_file(file):
    global i
    data = pd.read_csv(file, header=None).sum(axis=1)
    data = data.str.split("\t", n=1).str.get(1).str.split("\t").explode()
    i += 1
    print(
        f"Mi-faser tabulation progress: {i/(len(inp))*100:.2f}%",
        file=sys.stderr, end="\r"
    )
    return data.value_counts()

# Create complete table
table = pd.DataFrame(
    {file.parent.stem: load_file(file) for file in inp}
).fillna(0)

print("Mi-faser tabulation progress: Saving...", file=sys.stderr, end="\r")

# Save tables by level
for j in range(1, 5):
    partial = table.copy()
    if j != 4:
        partial["index"] = table.index.str.rsplit(".", n=4-j).str.get(0)
        partial = partial.groupby("index").sum()
    partial = partial.T
    if genomic:
        partial["City"] = partial.index.str[:3]
        partial["Taxon"] = partial.index.str[4:6]
        cols = ["City", "Taxon"] + list(partial.columns[:-2])
    else:
        partial["City"] = partial.index.str[23:26]
        cols = ["City"] + list(partial.columns[:-1])
    partial = partial.reindex(columns=cols).sort_index()
    partial.columns.name = ""
    partial.to_csv(out/f"lvl{j}.tsv", sep="\t", index=True)

print("Mi-faser tabulation progress: Done!    ", file=sys.stderr)
