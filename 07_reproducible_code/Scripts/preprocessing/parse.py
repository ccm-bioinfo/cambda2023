#!/usr/bin/env python3

from argparse import ArgumentParser
from os import cpu_count
from pathlib import Path
from sys import stderr, exit

def parse(arguments: list):

    # Create parser
    parser = ArgumentParser(
        description=(
            "Performs the preprocessing stage on selected city or cities. "
            "By default, all cities are analyzed when no CITY is specified. "
            "Visit https://github.com/ccm-bioinfo/cambda2023 for more "
            "information."),
        epilog=(
            "Access the SFTP parameters by reading and accepting the data "
            "download agreement here: "
            "http://camda2023.bioinf.jku.at/data_download. Download and "
            "extract the Kraken database from "
            "https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20230314.tar.gz, "
            "and the RGI database from [link]."))
    
    # Define arguments
    parser.add_argument(
        "cities", nargs="*", default=["ALL"], metavar="CITY",
        help="three-letter city name (e.g. AKL, BER, etc.)")
    parser.add_argument(
        "-k", type=Path, required=True, dest="krakendb", metavar="KRAKENDB",
        help="path to Kraken database")
    parser.add_argument(
        "-r", type=Path, required=True, dest="rgidb", metavar="RGIDB",
        help="path to RGI database (must be named localDB)")
    parser.add_argument(
        "-o", type=Path, required=True, dest="output", metavar="OUTPUT",
        help="output directory")
    parser.add_argument(
        "-n", type=str, required=True, dest="user", metavar="USER",
        help="CAMDA SFTP server username")
    parser.add_argument(
        "-u", type=str, required=True, dest="url", metavar="URL",
        help="CAMDA SFTP server URL")
    parser.add_argument(
        "-d", type=str, required=True, dest="sftpdir", metavar="SFTPDIR",
        help="CAMDA SFTP server directory containing sequence files")
    parser.add_argument(
        "-p", type=int, default=cpu_count(), dest="cpu", metavar="CPU",
        help=f"maximum number of CPUs to use, default: {cpu_count()}")

    # Parse and fix arguments
    if len(arguments) == 0:
        parser.print_help(stderr)
        exit(1)
    args = vars(parser.parse_args(arguments))

    # Remove invalid cities, raise error if all input cities are invalid
    all_cities = (
        "AKL BAL BER BOG DEN DOH ILR LIS "
        "MIN NYC SAC SAN SAO TOK VIE ZRH").split()
    args["cities"] = all_cities if "ALL" in args["cities"] else list(
        filter(lambda city: city in all_cities, args["cities"]))

    if len(args["cities"]) == 0:
        print(
            f"{parser.prog}: error: no valid city names, please try again",
            file=stderr)
        exit(1)
    
    # Check Kraken database files
    for file in ["hash.k2d", "opts.k2d", "taxo.k2d"]:
        path = args["krakendb"]/file
        if not path.exists():
            print(
                f"{parser.prog}: error: {path} does not exist, please "
                f"check your Kraken2 database directory", file=stderr)
            exit(1)

    # Check RGI database files
    if args["rgidb"].stem != "localDB":
        print(
            f"{parser.prog}: error: your RGI database isn't named localDB/, "
            f"please rename it and try again", file=stderr)
        exit(1)
    for file in [
        "61mer_database.json", "amr_61mer.txt",
        "card.json", "loaded_databases.json"]:
        path = args["rgidb"]/file
        if not path.exists():
            print(
                f"{parser.prog}: error: {path} does not exist, please "
                f"check your RGI database directory", file=stderr)
            exit(1)
    
    # Do not use more CPUs than available and ensure that at least one is used
    args["cpu"] = min(args["cpu"], cpu_count())
    args["cpu"] = max(args["cpu"], 1)

    return list(args.values())
