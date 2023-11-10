#!/usr/bin/env python3

from argparse import ArgumentParser
from os import cpu_count, remove
from pathlib import Path
from shutil import which
from subprocess import run, DEVNULL
from sys import argv, stderr, exit

# Stores the directory where this script is located
DIR = Path(__file__).resolve().parent

def prokka(fasta: Path, out: Path, cpu: int=1, quiet: bool=False):
    """Performs functional annotation using a modified version of Prokka,
    skipping `tbl2asn` execution and running in metagenome mode.
    
    Arguments:
    - `fasta` (Path): fasta file to annotate.
    - `out` (Path): output directory.
    - `cpu` (int, default=1): maximum number of CPUs to use.
    """

    # Do not use more CPUs than available and ensure that at least one is used
    cpu = min(cpu, cpu_count())
    cpu = max(cpu, 1)

    # Because we'll use prokka-alt, we must specify database path manually
    db = Path(which("prokka")).parent.parent/"db"

    # Build command
    prefix = out.stem
    cmd = (
        f"perl '{DIR/'helpers/prokka'}' --outdir '{out}' --prefix '{prefix}' "
        f"--cpus {cpu} --dbdir '{db}' --metagenome '{fasta}'")

    # Run command
    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

def metacyc(gff: Path, out: Path, quiet: bool=False):
    """Identifies MetaCyc metabolic pathways in a Prokka `gff` output and 
    stores them hierarchically in a `tsv` file. Based on EnvGen's Metagenomics
    Workshop functional annotation pipeline: 
    https://metagenomics-workshop.readthedocs.io/en/2014-11-uppsala/functional-annotation/index.html

    Arguments:
    - `gff` (Path): Prokka's gff output.
    - `out` (Path): output tsv file.
    """

    # Force tsv extension on output file
    if out.suffix != ".tsv": out = out.parent/f"{out.stem}.tsv"

    # Output filename without extension
    outbase = out.parent/out.stem

    # Get EC numbers from .gff file
    cmd1 = (
        f"grep 'eC_number=' '{gff}' | cut -f 9 | cut -f 1,2 -d ';' | "
        f"sed 's/ID=//g' | sed 's/;eC_number=/\\t/g' > '{outbase}.ec'")
    if quiet: run(cmd1, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd1, shell=True)

    # Predict MetaCyc pathways with MinPath
    cmd2 = (
        f"python3 '{DIR/'helpers/minpath/MinPath.py'}' "
        f"-any '{outbase}.ec' -map '{DIR/'helpers/map.tsv'}' "
        f"-report '{outbase}.minpath'")
    if quiet: run(cmd2, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd2, shell=True)

    # Create parent hierarchies list
    cmd3 = f"grep 'minpath 1' '{outbase}.minpath' > '{outbase}.limits'"
    if quiet: run(cmd3, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd3, shell=True)

    # Get hierarchy information from predicted pathways
    cmd4 = (
        f"python3 '{DIR/'helpers/hierarchize.py'}' -i '{outbase}.ec' "
        f"-m '{DIR/'helpers/map.tsv'}' -H '{DIR/'helpers/hierarchy.tsv'}' "
        f"-n '{outbase.stem}' -l '{outbase}.limits' -o '{out}'")
    if quiet: run(cmd4, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd4, shell=True)

    # Keep only tsv file
    for ext in ["ec", "minpath", "limits"]:
        remove(f"{outbase}.{ext}")

def mifaser(f1: Path, f2: Path, out: Path, cpu: int=1, quiet: bool=False):
    """Annotates paired-end `fastq` files using mi-faser.
    
    Arguments:
    - `f1` (Path): forward reads file.
    - `f2` (Path): reverse reads file.
    - `out` (Path): output directory.
    - `cpu` (int, default=1): maximum number of CPUs to use.
    """
    
    # Do not use more CPUs than available and ensure that at least one is used
    cpu = min(cpu, cpu_count())
    cpu = max(cpu, 1)

    # Build and run command
    cmd = f"mifaser -l '{f1}' '{f2}' -d GS+ -c {cpu} -o '{out}'"

    if quiet: run(cmd, shell=True, stdout=DEVNULL, stderr=DEVNULL)
    else: run(cmd, shell=True)

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Provides three functional annotation pipelines: Prokka, Metacyc and "
        "Mi-Faser. Depends on the files and scripts stored in the helpers/ "
        "directory."))
    parser.epilog = (
        f"Run '{parser.prog} [pipeline]' to view available parameters for "
        f"a pipeline.")
    subparsers = parser.add_subparsers(dest="pipeline", title="pipelines")

    # Prokka subparser
    parser_prokka = subparsers.add_parser(
        "prokka", help="Prokka pipeline for metagenomic assemblies",
        description=(
            "Annotates a fasta file using a modified version of Prokka, "
            "skipping tbl2asn execution and running in metagenome mode."))
    parser_prokka.add_argument(
        "-f", required=True, metavar="FASTA", type=Path, dest="fasta",
        help="fasta file to annotate")
    parser_prokka.add_argument(
        "-o", required=True, metavar="OUT", type=Path, dest="out",
        help="output directory")
    parser_prokka.add_argument(
        "-p", metavar="CPU", default=cpu_count(), type=int, dest="cpu",
        help=f"maximum number of CPUs to use, default: {cpu_count()}")

    # MetaCyc subparser
    parser_metacyc = subparsers.add_parser(
        "metacyc", help="MetaCyc pipeline for Prokka's gff outputs",
        description=(
            "Annotates a gff file produced by Prokka with MinPath and the "
            "MetaCyc database as reference. Based on EnvGen's Metagenomics "
            "Workshop functional annotation pipeline: "
            "https://metagenomics-workshop.readthedocs.io/en/2014-11-uppsala/functional-annotation/index.html"))
    parser_metacyc.add_argument(
        "-f", required=True, metavar="GFF", type=Path, dest="gff",
        help="gff file produced by Prokka")
    parser_metacyc.add_argument(
        "-o", required=True, metavar="OUT", type=Path, dest="out",
        help="output tsv file")

    # Mifaser subparser
    parser_mifaser = subparsers.add_parser(
        "mifaser",
        description="Annotates paired-end fastq files with Mi-Faser.",
        help="Mi-Faser pipeline for metagenomic paired-end reads")
    parser_mifaser.add_argument(
        "-1", required=True, metavar="F1", type=Path, dest="f1",
        help="fastq forward reads file")
    parser_mifaser.add_argument(
        "-2", required=True, metavar="F1", type=Path, dest="f2",
        help="fastq reverse reads file")
    parser_mifaser.add_argument(
        "-o", required=True, metavar="OUT", type=Path, dest="out",
        help="output directory")
    parser_mifaser.add_argument(
        "-p", metavar="CPU", default=cpu_count(), type=int, dest="cpu",
        help=f"maximum number of CPUs to use, default: {cpu_count()}")

    # Parse arguments
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    elif len(argv) == 2:
        if argv[1] == "prokka": parser_prokka.print_help(stderr)
        elif argv[1] == "metacyc": parser_metacyc.print_help(stderr)
        elif argv[1] == "mifaser": parser_mifaser.print_help(stderr)
        else: parser.parse_args()
        exit(1)
    arguments = vars(parser.parse_args())

    # Run function according to chosen pipeline
    if arguments["pipeline"] == "prokka":
        arguments.pop("pipeline")
        prokka(**arguments)
    elif arguments["pipeline"] == "metacyc":
        arguments.pop("pipeline")
        metacyc(**arguments)
    elif arguments["pipeline"] == "mifaser":
        arguments.pop("pipeline")
        mifaser(**arguments)
