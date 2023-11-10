#!/usr/bin/env python3

from json import load
from multiprocessing import Pool
from os import cpu_count
from pathlib import Path
from subprocess import run, DEVNULL

import pandas as pd

def __read_metacyc(file: Path) -> pd.DataFrame:
    result = pd.read_csv(file, sep="\t", names=range(9), header=0)
    result["Sample"] = file.stem
    return result

def __read_mifaser(file: Path) -> pd.Series:
    sample = file.parent.stem
    return pd.read_csv(
        file, sep="\t", header=0,
        names=["", sample], index_col="")[sample]

def __read_rgi_main(file: Path) -> pd.DataFrame:

    # Include Cut_Off, Best_Hit_ARO and ARO columns
    result = pd.read_csv(
        file, sep="\t", usecols=[5, 8, 10], header=0,
        names=["Cutoff", "Gene", "ARO"])
    result["Sample"] = file.stem
    return result

def __read_rgi_kmer(file: Path) -> pd.DataFrame:
    
    # Include Cut_Off, Best_Hit_ARO and CARD*kmer Prediction columns
    result = pd.read_csv(
        file, sep="\t", usecols=range(2, 5), header=0,
        names=["Cutoff", "Gene", "Genus"])
    result["Sample"] = file.stem
    return result

def amr_mapper(rgidb: Path) -> pd.Series:
    """Parses the card.json file inside `rgidb` to create a gene -> ARO mapper.
    """

    with open(rgidb/"card.json", "r") as handle:
        return pd.Series({
            value["model_name"]: value["ARO_accession"]
            for key, value in load(handle).items() if key[0] != "_"})

def amr_genes(inp: Path, out: Path, cpu: int=1):

    # Ensure that at least one CPU is used and no more than available
    cpu = max(min(cpu, cpu_count()), 1)

    # Get rgi main tsv outputs
    files = sorted(inp.glob("*.tsv"))

    # Read files in parallel and concatenate them into a single table
    with Pool(cpu) as p:
        full = pd.concat(p.map(__read_rgi_main, files), ignore_index=True)

    # Filter out loose hits for strict table
    strict = full[full["Cutoff"] != "Loose"]

    for table, name in zip([full, strict], ["Full", "Strict"]):
        counts = (
            table.drop("Cutoff", axis=1)  # Remove unnecessary Cutoff column
            .groupby(["Gene", "ARO"])     # Set index for genes and AROs
            .value_counts()               # Count genes per sample
            .unstack(fill_value=0))       # Transform rows into columns
        
        # Presence data: convert non-zero values -> 1
        presence = counts.astype(bool).astype(int)

        # Save tables
        counts.to_csv(out/f"{inp.stem}_{name}_Counts.tsv", sep="\t")
        presence.to_csv(out/f"{inp.stem}_{name}_Presence.tsv", sep="\t")

def amr_pathogens(inp: Path, out: Path, gene_aro: pd.Series, cpu: int=1):

    # Ensure that at least one CPU is used and no more than available
    cpu = max(min(cpu, cpu_count()), 1)

    # Get rgi kmer_query tsv outputs
    files = sorted(inp.glob("*.tsv"))

    # Read files in parallel and concatenate them into a single table
    with Pool(cpu) as p:
        full = pd.concat(p.map(__read_rgi_kmer, files), ignore_index=True)

    # Keep only genera of interest
    genera = ["Enterobacter", "Escherichia", "Klebsiella"]
    full["Genus"] = full["Genus"].str.split().str.get(0)
    full = full[full["Genus"].isin(genera)]

    # Filter out loose hits for strict table
    strict = full[full["Cutoff"] != "Loose"]

    for table, name in zip([full, strict], ["Full", "Strict"]):
        counts = (
            table.drop("Cutoff", axis=1)  # Remove unnecessary Cutoff column
            .groupby(["Genus", "Gene"])   # Set index for genera and genes
            .value_counts()               # Count genes per sample
            .unstack(fill_value=0)        # Transform rows into columns
            .reset_index())               # Write index for every column

        # Add ARO column
        counts.insert(2, "ARO", counts["Gene"].replace(gene_aro))

        # Presence data: convert non-zero values -> 1
        presence = counts.copy()
        presence.iloc[:, 3:] = presence.iloc[:, 3:].astype(bool).astype(int)

        # Save tables
        counts.to_csv(
            out/f"{inp.stem}_{name}_Counts.tsv", sep="\t", index=False)
        presence.to_csv(
            out/f"{inp.stem}_{name}_Presence.tsv", sep="\t", index=False)

def metacyc_functions(inp: Path, out: Path, cpu: int=1):

    # Ensure that at least one CPU is used and no more than available
    cpu = max(min(cpu, cpu_count()), 1)

    # Get metacyc outputs
    files = sorted(inp.glob("*.tsv"))

    # Read files in parallel
    with Pool(cpu) as p: tables = p.map(__read_metacyc, files)

    # Concatenate tables and fill NaNs with values of last known level
    table = pd.concat(tables, ignore_index=True).ffill(axis=1)

    # Produce a subtable for each level
    for lvl in range(1, 9):
    
        # Group subtable by sample and function (use sum to get abundance)
        sub = table[[0, lvl, "Sample"]].groupby(["Sample", lvl]).sum()

        # Reshape table to get sample vs function abundance
        sub = sub.reset_index().pivot(index="Sample", columns=lvl, values=0)

        # Fill missing values with zeros, insert City column, and save table
        sub = sub.fillna(0)
        sub.insert(0, "City", sub.index.str[2:5])
        sub.to_csv(f"{out}-{lvl}.tsv", sep="\t")

def mifaser_functions(inp: Path, out: Path, cpu: int=1):

    # Ensure that at least one CPU is used and no more than available
    cpu = max(min(cpu, cpu_count()), 1)

    # Get mifaser outputs
    files = sorted(inp.glob("*/analysis.tsv"))

    # Read files in parallel
    with Pool(cpu) as p: series = p.map(__read_mifaser, files)

    # Concatenate series by column and fill missing values with zeroes
    table = pd.concat(series, axis=1, sort=True).fillna(0)

    # Produce a subtable for each EC level
    for lvl in range(1, 5):

        # Group by level
        sub = table.copy()
        if lvl < 4:
            sub["EC"] = sub.index.str.rsplit(pat=".", n=4-lvl).str.get(0)
        else:
            sub["EC"] = sub.index
        sub = sub.groupby("EC").sum().T
        sub.index.name = "Sample"

        # Insert City column and save table
        sub.insert(0, "City", sub.index.str[2:5])
        sub.to_csv(f"{out}-{lvl}.tsv", sep="\t")

def taxonomy(inp: Path, out: Path):
    files = " ".join(sorted(map(str, inp.glob("*.report"))))
    cmd = (
        f"kraken-biom -o '{out}.json' --fmt json {files} && "
        f"kraken-biom -o '{out}.tsv' --fmt tsv {files}")
    run(cmd, shell=True)

    # Remove first line of tsv output
    with open(f"{out}.tsv", 'r+') as handle:
        handle.readline()
        data = handle.read()
        handle.seek(0)
        handle.write(data)
        handle.truncate()
