#!/usr/bin/env python3

# Usage:  ./metacyc.py

import os
import sys
from itertools import product
from pathlib import Path
import pandas as pd

base_dir = Path(os.path.realpath(__file__)).parent.parent.parent
inp = list(base_dir.glob("data/metagenomic/annotations/metacyc/*.tsv"))
out = base_dir/"data/metagenomic/tables/metacyc/"
total = 10
sys.stderr.write(f"MetaCyc tabulation progress: 0%\r")

for a, b in product(["cummulative", "noncummulative"], ["unscaled", "scaled"]):
    os.makedirs(out/a/b, exist_ok=True)

colnames = ["Abundance"] + [f"Level{n}" for n in range(1, 9)]

def read_table(file):
    table = pd.read_csv(file, delimiter="\t", header=0, names=colnames)
    table["Sample"] = file.stem
    return table

# Create noncummulative table
ntable = pd.concat(read_table(file) for file in inp)
sys.stderr.write(f"MetaCyc tabulation progress: 10%\r")

# Create cummulative table
ctable = ntable.fillna(method="ffill", axis=1)
sys.stderr.write(f"MetaCyc tabulation progress: 20%\r")

# For each level
for lvl in range(1, 9):
    sys.stderr.write(f"MetaCyc tabulation progress: {(lvl+2)*10}%\r")

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
    cities = pd.Series(
        data=nutable.index.str[23:26], index=nutable.index, name="City"
    )
    nutable = pd.concat([cities, nutable], axis=1)
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
    cities = pd.Series(
        data=nstable.index.str[23:26], index=nstable.index, name="City"
    )
    nstable = pd.concat([cities, nstable], axis=1)
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
    cities = pd.Series(
        data=cutable.index.str[23:26], index=cutable.index, name="City"
    )
    cutable = pd.concat([cities, cutable], axis=1)
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
    cities = pd.Series(
        data=cstable.index.str[23:26], index=cstable.index, name="City"
    )
    cstable = pd.concat([cities, cstable], axis=1)
    cstable.to_csv(
        out/f"cummulative/scaled/lvl{lvl}.tsv", sep="\t", index=True
    )

print()
