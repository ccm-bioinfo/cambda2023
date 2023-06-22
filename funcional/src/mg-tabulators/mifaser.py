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

table = pd.DataFrame({file.parent.stem: load_file(file) for file in inp})
for j in range(0, 4):
    partial = table.copy()
    partial["index"] = table.index.str.rsplit(".", n=j).str.get(0)
    print(partial)
    break
