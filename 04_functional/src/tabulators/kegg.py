#!/usr/bin/env python3

# Usage:  ./kegg.py [-g] [input_dir] [output_dir]

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

try: inp = list(Path(sys.argv[1]).glob("*.txt"))
except IndexError:
    print("ERROR: Missing input directory", file=sys.stderr)
    sys.exit(1)

try: out = Path(sys.argv[2])
except IndexError:
    print("ERROR: Missing output directory", file=sys.stderr)
    sys.exit(1)

os.makedirs(out, exist_ok=True)
datadict = dict()

# For each file
for i, file in enumerate(inp):

    # Count the number of times each KO term with "*" appears
    with open(file, "r") as handle:
        start = next(handle).find("KO")
        next(handle)
        counts = dict()
        for line in handle:
            if line[0] == "*":
                ko = line[start:]
                ko = ko[:ko.find(" ")]
                if ko in counts: counts[ko] += 1
                else: counts[ko] = 1
        datadict[file.stem] = counts

    # Print progress
    progress = (i+1) / len(inp) * 100
    print(
        f"KEGG tabulation progress: {progress:.2f}%", file=sys.stderr, end="\r"
    )

# Create output table and save
print(f"KEGG tabulation progress: Concatenating...", file=sys.stderr, end="\r")
data = pd.DataFrame(datadict).T.fillna(0)
if genomic:
    data["City"] = data.index.str[:3]
    data["Taxon"] = data.index.str[4:6]
    cols = ["City", "Taxon"] + list(data.columns[:-2])
else:
    data["City"] = data.index.str[23:26]
    cols = ["City"] + list(data.columns[:-1])
data = data.reindex(columns=cols).sort_index()
print(f"KEGG tabulation progress: Saving...       ", file=sys.stderr, end="\r")
data.to_csv(out/"kegg.tsv", sep="\t", index=True)
print(f"KEGG tabulation progress: Done!           ", file=sys.stderr)
