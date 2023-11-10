#!/usr/bin/env python3

from argparse import ArgumentParser
from datetime import datetime as dt
from fnmatch import fnmatch
from getpass import getpass
from os import makedirs
from pathlib import Path
from sys import argv, stderr, exit
from traceback import print_exception
from warnings import filterwarnings

# Turn off paramiko's Blowfish deprecation warning
filterwarnings("ignore", message="Blowfish has been deprecated")

from paramiko import Transport, SFTPClient

def log(msg: str):
    """Logs msg to stderr with current date and time."""

    message = (
        f'{dt.now().strftime("[%y-%m-%d %H:%M:%S]:")} {msg}')
    print(message, file=stderr)

def log_traceback(msg: str, exc: Exception):
    """Logs msg to stderr when exception is catched and stops program."""

    log(msg)
    print_exception(exc, file=stderr)
    exit(1)

def download(cities: list, outdir: Path, user: str, url: str, sftpdir: str):
    """Downloads sequence files from the CAMDA SFTP server. To access the SFTP
    parameters, read and accept the data download agreement here:
    http://camda2023.bioinf.jku.at/data_download.
    
    Arguments:
    - `cities` (list): city names to download sequences of.
    - `outdir` (Path): local path into which sequences will be downloaded.
    - `user` (str): SFTP server username.
    - `url` (str): SFTP server URL.
    - `sftpdir` (str): SFTP server directory containing the files.
    """

    # Create SFTP transport
    try:
        transport = Transport((url, 22))
        log("SFTP transport created")
    except Exception as exc:
        log_traceback("Failed to create SFTP transport:", exc)

    # Create SFTP connection
    try:
        transport.connect(None, user, getpass("SFTP password: "))
        sftp = SFTPClient.from_transport(transport)
        sftp.chdir(sftpdir)
        
        log("SFTP connection successful")
    except Exception as exc:
        if transport: transport.close()
        if sftp: sftp.close()
        log_traceback("Failed to connect to SFTP server:", exc)
    
    # Download requested files
    try:

        # Create output directory and list files in remote
        makedirs(outdir, exist_ok=True)
        files = sftp.listdir()

        # For each city
        for city in cities:
            log(f"Downloading {city} samples")

            # For each remote file
            for remote in [f for f in files if fnmatch(f, f"*_{city}_*")]:

                # Simplify the filename for local file like this:
                #   CAMDA23_MetaSUB_gCSD{year}_{city}_{sample}_{n}.fastq.gz ->
                #   {year}{city}{sample}_{n}.fq.gz
                local = remote.split("_")
                local = (
                    f"{local[2][-2:]}{local[3]}{local[4].zfill(2)}"
                    f"_{local[5][0]}.fq.gz")
                
                # Download file if it doesn't exist
                if (outdir/local).exists():
                    log(f"  Skipping {local}")
                else:
                    log(f"  Downloading {local}")
                    sftp.get(remote, outdir/local)
            log(f"Finished downloading {city} samples")

    except Exception as exc:
        if transport: transport.close()
        if sftp: sftp.close()
        log_traceback("Something went wrong while retrieving files:", exc)

if __name__ == "__main__":

    # Create parser
    parser = ArgumentParser(description=(
        "Downloads sequence files from the CAMDA SFTP server corresponding to "
        "desired cities. To access the SFTP parameters, read and accept the "
        "data download agreement here: "
        "http://camda2023.bioinf.jku.at/data_download."))
    parser.add_argument(
        "CITY", default=["ALL"], nargs="+",
        help=(
            "three-letter city name (e.g. TOK), default: ALL"))
    parser.add_argument(
        "-o", required=True, type=Path, metavar="OUTDIR",
        help="local output directory")
    parser.add_argument(
        "-n", required=True, metavar="USER", help="CAMDA SFTP username")
    parser.add_argument(
        "-u", required=True, metavar="URL", help="CAMDA SFTP URL")
    parser.add_argument(
        "-d", required=True, metavar="SFTPDIR", help="CAMDA SFTP directory")
    
    # Parse arguments
    if len(argv) == 1:
        parser.print_help(stderr)
        exit(1)
    cities, outdir, user, url, sftpdir = vars(parser.parse_args()).values()
    outdir = Path(outdir)

    # Run download function
    download(cities, outdir, user, url, sftpdir)
