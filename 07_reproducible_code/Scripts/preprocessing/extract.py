#!/usr/bin/env python3

from argparse import ArgumentParser
from subprocess import run, DEVNULL
from sys import argv, stderr, exit

def extract(
    files: list, kout: str, krep: str, taxid: int, out: str, quiet: bool=False
    ):
    """Extracts sequences assigned to a `taxid` from assemblies (when `files`
    has one element) or paired-end reads (when `files` has two elements).

    Arguments:
    - `files` (list): one or two sequence files.
    - `kout` (str): Kraken output path.
    - `krep` (str): Kraken report path.
    - `taxid` (int): NCBI taxonomic identifier.
    - `out` (str): output file basename.
    """

    # Force files to be a list
    if type(files) != list: files = [files]

    # Ensure that at least one and at most two files are provided
    assert len(files) <= 2, "At most two files must be provided"
    assert len(files) >= 1, "At least one file must be provided"

    # If the input is paired-end
    if len(files) == 2:
        cmd = (
            f"extract_kraken_reads.py -s '{files[0]}' -s2 '{files[1]}' "
            f"-t {taxid} -k '{kout}' -r '{krep}' -o '{out}_1.fq' "
            f"-o2 '{out}_2.fq' --include-children --fastq-output && gzip "
            f"'{out}_1.fq' '{out}_2.fq'")
    else:
        cmd = (
            f"extract_kraken_reads.py -s '{files[0]}' -t {taxid} -k '{kout}' "
            f"-r '{krep}' -o '{out}.fa' --include-children")

    # Run command
    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Extracts sequences assigned to a specific taxid using Kraken's "
        "outputs from a single FILE or paired-end FILEs. At least one and at "
        "most two FILEs must be provided."))
    parser.add_argument(
        "FILE", nargs="+",
        help="sequence file(s) from which to perform extraction")
    parser.add_argument(
        "-k", required=True, metavar="KOUT", help="kraken output file")
    parser.add_argument(
        "-r", required=True, metavar="KREP", help="kraken report file")
    parser.add_argument(
        "-t", required=True, metavar="TAXID", help="taxid of interest")
    parser.add_argument(
        "-o", required=True, metavar="OUT",
        help="output file basename (suffixes are added automatically)")
    
    # Parse arguments and run extract function
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    files, kout, krep, taxid, out = vars(parser.parse_args()).values()
    extract(files, kout, krep, taxid, out)
