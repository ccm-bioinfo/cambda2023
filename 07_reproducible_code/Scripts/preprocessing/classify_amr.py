#!/usr/bin/env python3

from argparse import ArgumentParser
from os import chdir, cpu_count, getcwd, rename, remove
from pathlib import Path
from subprocess import run, DEVNULL
from sys import argv, stderr, exit

def classify_amr(
    file: Path, rgidb: Path, out: Path, cpu: int=1, quiet: bool=False):
    """Identifies AMR gene carrier pathogens using CARD as reference from a
    json output file produced by RGI.
    
    Arguments:
    - `file` (Path): RGI main json file.
    - `rgidb` (Path): path to RGI database.
    - `out` (Path): output file basename (suffixes are added automatically).
    - `cpu` (int, default = 1): maximum number of CPUs to use.
    """

    # Do not use more CPUs than available and ensure that at least one is used
    cpu = min(cpu, cpu_count())
    cpu = max(cpu, 1)

    # Ensure that the RGI database is named localDB and fail otherwise
    assert rgidb.stem == "localDB", "The RGI database must be named localDB."

    # RGI requires that the database is located in the working directory
    # Store current working directory and absolute paths of files
    current = getcwd()
    out = out.resolve()
    file = file.resolve()

    # Change to directory where localDB is located
    chdir(rgidb.parent)

    # Build and run command
    cmd = (
        f"micromamba run -n rgi rgi kmer_query --local -i '{file}' -k 61 "
        f"-o '{out}' -n {cpu} --rgi")
    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

    # Simplify filenames and remove generated fasta file
    rename(f"{out}_61mer_analysis_rgi_summary.txt", f"{out}.tsv")
    rename(f"{out}_61mer_analysis.json", f"{out}.json")
    remove(f"{file.stem}{file.suffix}.fasta")

    # Return to current working directory
    chdir(current)

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Identifies AMR gene carrier pathogens using CARD as reference from a "
        "json output file produced by RGI."))
    parser.add_argument(
        "-f", required=True, type=Path, metavar="FILE",
        help="json file to analyze produced by RGI")
    parser.add_argument(
        "-r", required=True, type=Path, metavar="RGIDB",
        help="path to RGI database, must be named localDB")
    parser.add_argument(
        "-o", required=True, metavar="OUT", type=Path,
        help="output file basename (suffixes are added automatically)")
    parser.add_argument(
        "-p", default=cpu_count(), type=int, metavar="CPU",
        help=f"maximum number of CPUs to use, default: {cpu_count()}")

    # Parse arguments and run detect_amr function
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    file, rgidb, out, cpu = vars(parser.parse_args()).values()
    classify_amr(file, rgidb, out, cpu)
