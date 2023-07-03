#!/usr/bin/env python3

# Usage:  ./metacyc.py [-g] [input directory] [output directory]

import os
import sys
from itertools import product
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

try: out = Path(sys.argv[2])/"metacyc"
except IndexError:
    print("ERROR: Missing output directory", file=sys.stderr)
    sys.exit(1)

print(f"MetaCyc tabulation progress: 0%", file=sys.stderr, end="\r")

for a, b in product(["cummulative", "noncummulative"], ["unscaled", "scaled"]):
    os.makedirs(out/a/b, exist_ok=True)

colnames = ["Abundance"] + [f"Level{n}" for n in range(1, 9)]

def read_table(file):
    table = pd.read_csv(file, delimiter="\t", header=0, names=colnames)
    table["Sample"] = file.stem
    return table

# Adds City column, and Taxon column for genomic files
def add_metadata(table):
    global genomic
    if genomic:
        cities = pd.Series(
            data=table.index.str[:3], index=table.index, name="City"
        )
        taxon = pd.Series(
            data=table.index.str[4:6], index=table.index, name="Taxon"
        )
        return pd.concat([cities, taxon, table], axis=1)
    else:
        cities = pd.Series(
            data=table.index.str[23:26], index=table.index, name="City"
        )
        return pd.concat([cities, table], axis=1)

# Create noncummulative table
ntable = pd.concat([read_table(file) for file in inp])
print(f"MetaCyc tabulation progress: 10%", file=sys.stderr, end="\r")

# Create cummulative table
ctable = ntable.fillna(method="ffill", axis=1)
print(f"MetaCyc tabulation progress: 20%", file=sys.stderr, end="\r")

# For each level
for lvl in range(1, 9):
    print(
        f"MetaCyc tabulation progress: {(lvl+2)*10}%\r",
        file=sys.stderr, end="\r"
    )

    # Create noncummulative unscaled table
    nutable = (
        ntable[[f"Level{lvl}", "Sample"]]
        .dropna(subset=f"Level{lvl}")
        .groupby([f"Level{lvl}", "Sample"])
        .size()
        .reset_index(name='Count')
        .pivot(index="Sample", columns=f"Level{lvl}", values="Count")
        .fillna(0)
    )
    nutable = add_metadata(nutable)
    nutable.to_csv(
        out/f"noncummulative/unscaled/lvl{lvl}.tsv", sep="\t", index=True
    )

    # Create noncummulative scaled table
    nstable = (
        ntable[["Abundance", f"Level{lvl}", "Sample"]]
        .dropna(subset=f"Level{lvl}")
        .groupby(["Sample", f"Level{lvl}"])
        .sum()
        .reset_index()
        .pivot(index="Sample", columns=f"Level{lvl}", values="Abundance")
        .fillna(0)
    )
    nstable = add_metadata(nstable)
    nstable.to_csv(
        out/f"noncummulative/scaled/lvl{lvl}.tsv", sep="\t", index=True
    )

    # Create cummulative unscaled table
    cutable = (
        ctable[[f"Level{lvl}", "Sample"]]
        .dropna(subset=f"Level{lvl}")
        .groupby([f"Level{lvl}", "Sample"])
        .size()
        .reset_index(name='Count')
        .pivot(index="Sample", columns=f"Level{lvl}", values="Count")
        .fillna(0)
    )
    cutable = add_metadata(cutable)
    cutable.to_csv(
        out/f"cummulative/unscaled/lvl{lvl}.tsv", sep="\t", index=True
    )

    # Create cummulative scaled table
    cstable = (
        ctable[["Abundance", f"Level{lvl}", "Sample"]]
        .dropna(subset=f"Level{lvl}")
        .groupby(["Sample", f"Level{lvl}"])
        .sum()
        .reset_index()
        .pivot(index="Sample", columns=f"Level{lvl}", values="Abundance")
        .fillna(0)
    )
    cstable = add_metadata(cstable)
    cstable.to_csv(
        out/f"cummulative/scaled/lvl{lvl}.tsv", sep="\t", index=True
    )

print("MetaCyc tabulation progress: Done!", file=sys.stderr)
