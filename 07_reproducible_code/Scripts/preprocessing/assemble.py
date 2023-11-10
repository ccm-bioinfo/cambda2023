#!/usr/bin/env python3

from argparse import ArgumentParser
from os import cpu_count, rename
from pathlib import Path
from shutil import rmtree
from subprocess import run, DEVNULL
from sys import argv, stderr, exit

def assemble(
    f1: list|str, f2: list|str, output: Path, cpu: int=1, quiet: bool=False):
    """Assembles single or list of paired-end files `f1` and `f2`, using `cpu`
    threads, and saves output assembly into `output`.
    
    Arguments:
    - `f1` (list or str): forward read file(s).
    - `f2` (list or str): reverse read file(s).
    - `output` (Path): output assembly fasta file.
    - `cpu` (int, default = 1): maximum number of CPUs to use.
    """

    # Do not use more CPUs than available and ensure that at least one is used
    cpu = min(cpu, cpu_count())
    cpu = max(cpu, 1)

    # Concatenate input files with commas if inputs are lists
    if type(f1) == list or type(f2) == list:
        f1 = ",".join(map(str, f1))
        f2 = ",".join(map(str, f2))

    # A temporary directory to store assembly results
    outdir = output.parent/f"{output.stem}-assembly"

    # Run MEGAHIT
    cmd = f"megahit -1 '{f1}' -2 '{f2}' -t {cpu} -o '{outdir}'"
    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

    # Move assembly file out of output directory and remove extra files
    rename(outdir/"final.contigs.fa", output)
    rmtree(outdir)

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Assembles paired-end reads and produces a single fasta file."))
    parser.add_argument(
        "-1", nargs="+", required=True,
        help="forward read files", metavar="F1")
    parser.add_argument(
        "-2", nargs="+", required=True,
        help="reverse read files", metavar="F2")
    parser.add_argument(
        "-o", required=True, type=Path, metavar="OUTPUT",
        help="output assembly fasta file")
    parser.add_argument(
        "-p", default=cpu_count(), type=int, metavar="CPU",
        help=f"maximum number of CPUs to use, default: {cpu_count()}")

    # Parse arguments
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    f1, f2, output, cpu = vars(parser.parse_args()).values()

    # Run assemble function
    assemble(f1, f2, output, cpu)
