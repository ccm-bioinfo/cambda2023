#!/usr/bin/env python3

from argparse import ArgumentParser
from collections import deque
from gzip import open as gzopen
from sys import argv, stderr, exit

from Bio.SeqIO import parse

def check_fqgz(file: str) -> bool:
    """Returns `True` if input `file` is a valid `fastq.gz` file, and `False`
    otherwise."""

    try:
        with gzopen(file, "rt") as handle: deque(parse(handle, "fastq"), 0)
    except: return False
    return True

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Validates an input fastq.gz FILE, returning an exit code of 0 if "
        "successful, and 1 otherwise."))
    parser.add_argument("FILE", help="fastq.gz file")

    # Parse argument and run function
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    if not check_fqgz(vars(parser.parse_args())["FILE"]): exit(1)
