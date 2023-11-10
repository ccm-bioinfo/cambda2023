#!/usr/bin/env python3

from argparse import ArgumentParser
from os import cpu_count
from subprocess import run, DEVNULL
from sys import argv, stderr, exit

def classify(files: list, db: str, output: str, cpu: int=1, quiet: bool=False):
    """Performs taxonomic classification on input `files`.
    
    Arguments:
    - `files` (list): a list of one or two sequence files.
    - `db` (str): path to Kraken2 database.
    - `output` (str): output filename without extension.
    - `cpu` (int, default = 1): maximum number of CPUs to use.
    """

    # Force files to be a list
    if type(files) != list: files = [files]

    # Ensure that at least one and at most two files are provided
    assert len(files) <= 2, "At most two files must be provided"
    assert len(files) >= 1, "At least one file must be provided"

    # Do not use more CPUs than available and ensure that at least one is used
    cpu = min(cpu, cpu_count())
    cpu = max(cpu, 1)

    # Build command
    cmd = (
        f"kraken2 --db '{db}' --threads '{cpu}' --output '{output}.output' "
        f"--report '{output}.report' '{files[0]}' ")
    
    # Add appropiate flags if two input files are provided
    if len(files) == 2: cmd += f"'{files[1]}' --gzip-compressed --paired"

    # Run command
    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Performs taxonomic classification on a single FILE or pair of FILEs, "
        "producing a Kraken output and report file. If two FILEs are "
        "provided they are treated as gzipped paired-end files."))
    parser.add_argument("FILE", nargs="+", help="sequence file(s) to classify")
    parser.add_argument(
        "-d", required=True, metavar="DB", help="kraken database directory")
    parser.add_argument(
        "-o", required=True, metavar="OUT",
        help="output file basename (suffixes are added automatically)")
    parser.add_argument(
        "-p", metavar="CPU", default=cpu_count(), type=int,
        help=f"maximum number of CPUs to use, default: {cpu_count()}")
    
    # Parse arguments and run classify function
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    files, db, output, cpu = vars(parser.parse_args()).values()
    classify(files, db, output, cpu)
