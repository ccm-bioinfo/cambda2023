#!/usr/bin/env python3

# Usage:  ./prokka.py [-g] [input_dir] [output_dir]

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

try: inp = list(Path(sys.argv[1]).glob("*/*.tsv"))
except IndexError:
    print("ERROR: Missing input directory", file=sys.stderr)
    sys.exit(1)

try: out = Path(sys.argv[2])
except IndexError:
    print("ERROR: Missing output directory", file=sys.stderr)
    sys.exit(1)

os.makedirs(out, exist_ok=True)

i = 0

# Returns a dictionary of function: counts
def load_file(file):
    global i
    data = pd.read_csv(
        file, delimiter="\t", usecols=["product"]
    )["product"].value_counts()
    i += 1
    print(
        f"Prokka tabulation progress: {i/(len(inp))*100:.2f}%",
        file=sys.stderr, end="\r"
    )
    return dict(data)

# Create table, remove "hypothetical" proteins
data = {file.parent.stem: load_file(file) for file in inp}
print(
    f"Prokka tabulation progress: Concatenating...",
    file=sys.stderr, end="\r"
)
data = pd.DataFrame(data).T.fillna(0).drop("hypothetical protein", axis=1)

# Add metadata columns
if genomic:
    data["City"] = data.index.str[:3]
    data["Taxon"] = data.index.str[4:6]
    cols = ["City", "Taxon"] + list(data.columns[:-2])
else:
    data["City"] = data.index.str[23:26]
    cols = ["City"] + list(data.columns[:-1])
data = data.reindex(columns=cols).sort_index()

# Save table
print(f"Prokka tabulation progress: Saving...       ", file=sys.stderr, end="\r")
data.to_csv(out/"prokka.tsv", sep="\t", index=True)
print(f"Prokka tabulation progress: Done!           ", file=sys.stderr)
