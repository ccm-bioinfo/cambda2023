#!/usr/bin/env python3

# Usage:  ./kegg.py

import os
import sys
from pathlib import Path
import pandas as pd

base_dir = Path(os.path.realpath(__file__)).parent.parent.parent
inp = list(base_dir.glob("data/metagenomic/annotations/kegg/*.txt"))
out = base_dir/"data/metagenomic/tables/"

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
    sys.stderr.write(f"KEGG tabulation progress: {progress:.2f}%\r")

# Create output table and save
print()
data = pd.DataFrame(datadict).T.fillna(0)
data["City"] = data.index.str[23:26]
cols = ["City"] + list(data.columns[:-1])
data = data.reindex(columns=cols).sort_index()
data.to_csv(out/"kegg.tsv", sep="\t", index=True)
