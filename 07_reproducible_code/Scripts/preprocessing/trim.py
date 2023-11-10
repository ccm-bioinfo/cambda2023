#!/usr/bin/env python3

from argparse import ArgumentParser
from os import rename, cpu_count
from pathlib import Path
from subprocess import run, DEVNULL
from sys import argv, stderr, exit

def trim(f1: Path, f2: Path, out: Path, cpu: int=1, quiet: bool=False):
    """Performs adapter and quality trimming on input paired-end files.
    
    Arguments:
    - `f1` (Path): forward reads file.
    - `f2` (Path): reverse reads file.
    - `out` (Path): output file basename (suffixes are added automatically).
    - `cpu` (int, default = 1): maximum number of CPUs to use.
    """

    # Do not use more CPUs than available and ensure that at least one is used
    cpu = min(cpu, cpu_count())
    cpu = max(cpu, 1)

    # Build command
    cmd = (
        f"trim_galore -length 40 -o {out.parent} --paired --cores {cpu} "
        f"--basename {out.stem} --no_report_file '{f1}' '{f2}'")

    # Run trim-galore
    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

    # Remove "_val_" from output filenames
    rename(f"{out}_val_1.fq.gz", f"{out}_1.fq.gz")
    rename(f"{out}_val_2.fq.gz", f"{out}_2.fq.gz")

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Performs adapter and quality trimming on input paired-end files."))
    parser.add_argument(
        "-1", required=True, type=Path, metavar="F1",
        help="forward reads file")
    parser.add_argument(
        "-2", required=True, type=Path, metavar="F2",
        help="reverse reads file")
    parser.add_argument(
        "-o", required=True, metavar="OUT", type=Path,
        help="output file basename (suffixes are added automatically)")
    parser.add_argument(
        "-p", default=cpu_count(), type=int, metavar="CPU",
        help=f"maximum number of CPUs to use, default: {cpu_count()}")

    # Parse arguments
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    f1, f2, out, cpu = vars(parser.parse_args()).values()

    # Run trim function
    trim(f1, f2, out, cpu)
