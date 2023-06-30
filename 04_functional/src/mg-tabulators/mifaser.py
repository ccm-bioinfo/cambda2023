#!/usr/bin/env python3

# Usage:  ./mifaser.py

import os
import sys
from pathlib import Path
import pandas as pd

base_dir = Path(os.path.realpath(__file__)).parent.parent.parent
inp = list(base_dir.glob("data/metagenomic/annotations/mifaser/*/analysis.tsv"))
out = base_dir/"data/metagenomic/tables/mifaser"

os.makedirs(out, exist_ok=True)

i = 0

# Creates a dictionary of ec: count for each file
def load_file(file):
    global i
    data = pd.read_csv(
        file, delimiter="\t", names=["ec", "count"], header=0, index_col="ec"
    )["count"]
    i += 1
    sys.stderr.write(
        f"Mi-faser tabulation progress: {i/(len(inp))*100:.2f}%\r"
    )
    return dict(data)

# Create complete table
table = pd.DataFrame(
    {file.parent.stem: load_file(file) for file in inp}
).fillna(0)

# Save tables by level
for j in range(1, 5):
    partial = table.copy()
    if j != 4:
        partial["index"] = table.index.str.rsplit(".", n=4-j).str.get(0)
        partial = partial.groupby("index").sum()
    partial = partial.T
    partial["City"] = partial.index.str[23:26]
    cols = ["City"] + list(partial.columns[:-1])
    partial = partial.reindex(columns=cols).sort_index()
    partial.columns.name = ""
    partial.to_csv(out/f"lvl{j}.tsv", sep="\t", index=True)

print()
