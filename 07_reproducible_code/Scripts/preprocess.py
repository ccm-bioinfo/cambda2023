#!/usr/bin/env python3

from datetime import datetime as dt
from itertools import chain
from math import ceil
from multiprocessing import Pool
from os import makedirs
from pathlib import Path
from re import findall
from sys import argv, stderr, exit
from traceback import print_exception

from preprocessing import *

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

# -----------------------
# Step 1: Parse arguments
# -----------------------

cities, krakendb, rgidb, output, user, url, sftpdir, cpu = parse(argv[1:])
log(f"Your job has started. Its configuration is:")
log(f"  Cities to analyze: {', '.join(cities)}")
log(f"  Kraken database directory: {krakendb}")
log(f"  RGI database directory: {rgidb}")
log(f"  Outputs will be save into: {output}")
log(f"  Full SFTP connection: {user}@{url}:{sftpdir}")
log(f"  Maximum number of CPUs: {cpu}")

# Define directories
folders = [
    "ExtractedCoassemblies",
    "ExtractedReadAssemblies",
    "SampleAssemblies",
    "Coassemblies"
]
raw = Path(output/"Reads/Raw")
trimmed = Path(output/"Reads/Trimmed")
assemblies = Path(output/"Assemblies")
sample_assemblies = assemblies/f"{folders[2]}"
coassemblies = assemblies/f"{folders[3]}"
read_taxonomy = Path(output/"Taxonomy/Reads")
assembly_taxonomy = Path(output/"Taxonomy/Assemblies")
coassembly_taxonomy = Path(output/"Taxonomy/Coassemblies")
extracted_reads = Path(output/"Reads/Extracted")
extracted_coassemblies = assemblies/f"{folders[0]}"
extracted_read_assemblies = assemblies/f"{folders[1]}"
amr_main = output/"AMR/Main"
amr_taxonomy = output/"AMR/Taxonomy"
functions = output/"Functions"
tables = output/"Tables"

# ----------------------
# Step 2: Download files
# ----------------------

download(cities, raw, user, url, sftpdir)

# ---------------------------
# Step 3: File validity check
# ---------------------------

log(f"Checking file validity")

# Get file basenames of input cities
bases = map(
    lambda x: x.stem[:-5],
    chain.from_iterable(Path(raw).glob(f"??{c}??_1.fq.gz") for c in cities))

# Filter out basenames that were already checked
try:
    with open(output/"bases.txt", "r") as f:
        checked = set(map(lambda x: x.strip(), f.readlines()))
except FileNotFoundError: checked = set()
bases = sorted(filter(lambda x: x not in checked, bases))

# Get file pairs
pairs = list(map(lambda x: [raw/f"{x}_{n}.fq.gz" for n in [1, 2]], bases))

# Check file pairs in parallel
def checker(pair: list): return check_fqgz(pair[0]) and check_fqgz(pair[1])

with Pool(cpu) as p:
    for i, validated in enumerate(p.imap(checker, pairs)):

        # Store basename as checked
        with open(output/"bases.txt", "a") as f: f.write(f"{bases[i]}\n")

        # If the file pair is valid, append basename to {output}/valid.txt
        if validated:
            log(f"  Sample {bases[i]} is valid")
            with open(output/"valid.txt", "a") as f: f.write(f"{bases[i]}\n")
        
        # If not, append basename to {output}/invalid.txt
        else:
            log(f"  Sample {bases[i]} found invalid")
            with open(output/"invalid.txt", "a") as f: f.write(f"{bases[i]}\n")

# Get valid basenames
with open(output/"valid.txt", "r") as file:
    valid = map(lambda x: x.strip(), file.readlines())
    valid = list(filter(lambda x: x[2:5] in cities, valid))

log(f"Finished checking file validity")

# ---------------------
# Step 4: Read trimming
# ---------------------

log(f"Trimming reads")

makedirs(trimmed, exist_ok=True)

def trimmer(base):
    global raw, trimmed
    f1, f2 = [raw/f"{base}_{n}.fq.gz" for n in [1, 2]]
    out = trimmed/base
    if Path(f"{out}_1.fq.gz").exists():
        log(f"  Skipping {base}")
    else:
        trim(f1, f2, out, cpu=1, quiet=True)
        log(f"  Finished with {base}")

with Pool(cpu) as p: p.map(trimmer, valid)

log(f"Finished trimming reads")

# ----------------
# Step 5: Assembly
# ----------------

log(f"Performing assembly")

makedirs(sample_assemblies, exist_ok=True)
makedirs(coassemblies, exist_ok=True)

for city in cities:
    samples = sorted(filter(lambda x: x[2:5] == city, valid))
    files1 = list(map(lambda x: trimmed/f"{x}_1.fq.gz", samples))
    files2 = list(map(lambda x: trimmed/f"{x}_2.fq.gz", samples))
    outputs = list(map(lambda x: sample_assemblies/f"{x}.fa", samples))

    # Sample assembly
    for i, paths in enumerate(zip(files1, files2, outputs)):
        f1, f2, output = paths
        if output.exists():
            log(f"  Skipping {samples[i]}")
        else:
            log(f"  Assembling {samples[i]}")
            assemble(f1, f2, output, cpu, quiet=True)

    # Coassembly
    coassembly = coassemblies/f"{city}.fa"
    if coassembly.exists():
        log(f"  Skipping {city} coassembly")
    else:
        log(f"  Coassembling {city}")
        assemble(files1, files2, coassembly, cpu, quiet=True)

log(f"Finished performing assembly")

# ----------------
# Step 6: Taxonomy
# ----------------

log(f"Performing taxonomic classification")

makedirs(read_taxonomy, exist_ok=True)
makedirs(assembly_taxonomy, exist_ok=True)
makedirs(coassembly_taxonomy, exist_ok=True)

for city in cities:
    samples = sorted(filter(lambda x: x[2:5] == city, valid))

    # Read classification
    log(f"  Classifying {city} reads")

    files1 = list(map(lambda x: trimmed/f"{x}_1.fq.gz", samples))
    files2 = list(map(lambda x: trimmed/f"{x}_2.fq.gz", samples))
    outputs = list(map(lambda x: read_taxonomy/f"{x}", samples))
    for i, paths in enumerate(zip(files1, files2, outputs)):
        f1, f2, output = paths

        if Path(f"{output}.report").exists():
            log(f"    Skipping {samples[i]}")
        else:
            log(f"    Classifying {samples[i]}")
            classify([f1, f2], krakendb, output, cpu)
    
    log(f"  Finished classifying {city} reads")

    # Assembly classification
    log(f"  Classifying {city} assemblies")

    files = list(map(lambda x: sample_assemblies/f"{x}.fa", samples))
    outputs = list(map(lambda x: assembly_taxonomy/f"{x}", samples))
    for i, paths in enumerate(zip(files, outputs)):
        file, output = paths

        if Path(f"{output}.report").exists():
            log(f"    Skipping {samples[i]}")
        else:
            log(f"    Classifying {samples[i]}")
            classify(file, krakendb, output, cpu)
    
    log(f"  Finished classifying {city} assemblies")

    # Coassembly classification
    file = coassemblies/f"{city}.fa"
    output = coassembly_taxonomy/f"{city}"
    if Path(f"{output}.report").exists():
        log(f"  Skipping {city} coassembly classification")
    else:
        log(f"  Classifying {city} coassembly")
        classify(file, krakendb, output, cpu)

log(f"Finished performing taxonomic classification")

# ------------------
# Step 7: Extraction
# ------------------

log(f"Extracting reads and coassembly contigs of interest")

makedirs(extracted_reads, exist_ok=True)
makedirs(extracted_coassemblies, exist_ok=True)

# Name: taxid
genera = {"En": 547, "Es": 561, "Kl": 570}

def extractor(params: list):
    if (
        (len(params[0]) == 2 and not Path(f"{params[4]}_1.fq.gz").exists()) or
        (len(params[0]) == 1 and not Path(f"{params[4]}.fa").exists())):
        extract(*params)

for city in cities:
    log(f"  Extracting from {city}")

    # Build parameter list
    params = []
    samples = sorted(filter(lambda x: x[2:5] == city, valid))

    for genus, taxid in genera.items():
        for sample in samples:

            # Paired-end read extraction parameters
            files = [trimmed/f"{sample}_{n}.fq.gz" for n in [1, 2]]
            kout = read_taxonomy/f"{sample}.output"
            krep = read_taxonomy/f"{sample}.report"
            out = extracted_reads/f"{sample}_{genus}"
            params.append([files, kout, krep, taxid, out, True])

        # Coassembly extraction parameters
        files = [coassemblies/f"{city}.fa"]
        kout = coassembly_taxonomy/f"{city}.output"
        krep = coassembly_taxonomy/f"{city}.report"
        out = extracted_coassemblies/f"{city}_{genus}"
        params.append([files, kout, krep, taxid, out, True])

    # Run extraction in parallel
    with Pool(cpu) as p:
        p.map(extractor, params)

    log(f"  Finished extracting from {city}")

log(f"Finished extraction")

# -------------------------------
# Step 8: Extracted read assembly
# -------------------------------

log(f"Assembling extracted reads")

makedirs(extracted_read_assemblies, exist_ok=True)

for city in cities:
    log(f"  Assembling {city} extracted reads")

    for genus in genera.keys():

        # Get files from the corresponding city and genus, and assemble
        f1 = sorted(extracted_reads.glob(f"??{city}??_{genus}_1.fq.gz"))
        f2 = sorted(extracted_reads.glob(f"??{city}??_{genus}_2.fq.gz"))
        output = extracted_read_assemblies/f"{city}_{genus}.fa"

        if output.exists():
            log(f"    Skipping {city}_{genus}")
        else:
            log(f"    Assembling {city}_{genus}")
            assemble(f1, f2, output, cpu, True)

    log(f"  Finished assembling {city} extracted reads")

log(f"Finished assembling extracted reads")

# ---------------------
# Step 9: AMR detection
# ---------------------

log(f"Detecting AMR")

for folder in folders:
    inp = assemblies/f"{folder}"
    out = amr_main/f"{folder}"

    # Separated folder name with spaces for logging
    name = " ".join(findall(r'[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)', folder))
    makedirs(out, exist_ok=True)
    log(f"  AMR detection in {name} started")

    for city in cities:
        for file in sorted(inp.glob(f"*{city}*.fa")):
            base = file.stem
            if (out/f"{base}.tsv").exists():
                log(f"    Skipping {base}")
            else:
                log(f"    Detecting AMR in {base}")
                detect_amr(file, rgidb, out/base, cpu, True)
    
    log(f"  Finished detecting AMR in {name}")

log(f"Finished detecting AMR")

# -------------------------------
# Step 10: AMR pathogen detection
# -------------------------------

log(f"Detecting AMR pathogens")

def amr_classifier(params: list):
    if Path(f"{params[2]}.tsv").exists():
        log(f"    Skipping {params[0].stem}")
    else:
        log(f"    Finished with {params[0].stem}")
        classify_amr(*params)

for folder in folders:
    inp = amr_main/f"{folder}"
    out = amr_taxonomy/f"{folder}"
    makedirs(out, exist_ok=True)
    name = " ".join(findall(r'[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)', folder))

    log(f"  AMR-based classification of {name} started")

    params = []
    for city in cities:
        params += [[file, rgidb, out/file.stem, 1, True] for file in sorted(
            inp.glob(f"*{city}*.json"))]

    # Use half the CPUs as memory usage may be high
    with Pool(ceil(cpu/2)) as p: p.map(amr_classifier, params)

    log(f"  Finished AMR-based classification of {name}")

log(f"Finished detecting AMR pathogens")

# ------------------------------
# Step 11: Functional annotation
# ------------------------------

log(f"Performing functional annotation")

annotators = ["Prokka", "MetaCyc", "MiFaser"]

for ann in annotators:
    log(f"  Annotating with {ann}")
    makedirs(functions/ann, exist_ok=True)

    for base in valid:
        if ann == "Prokka":
            for base in valid:
                params = {
                    "fasta": sample_assemblies/f"{base}.fa",
                    "out": functions/f"{ann}/{base}",
                    "cpu": cpu,
                    "quiet": True}
                if params["out"].exists(): log(f"    Skipping {base}")
                else:
                    log(f"    Annotating {base}")
                    prokka(**params)

        elif ann == "MetaCyc":
            for base in valid:
                params = {
                    "gff": functions/f"Prokka/{base}/{base}.gff",
                    "out": functions/f"{ann}/{base}.tsv",
                    "quiet": True}
                if params["out"].exists(): log(f"    Skipping {base}")
                else:
                    log(f"    Annotating {base}")
                    metacyc(**params)

        elif ann == "MiFaser":
            params = {
                "f1": trimmed/f"{base}_1.fq.gz",
                "f2": trimmed/f"{base}_2.fq.gz",
                "out": functions/f"{ann}/{base}",
                "cpu": cpu,
                "quiet": True}
            if params["out"].exists(): log(f"    Skipping {base}")
            else:
                log(f"    Annotating {base}")
                mifaser(**params)

    log(f"  Finished annotating with {ann}")

log(f"Finished performing functional annotation")

# -------------------
# Step 12: Tabulation
# -------------------

log(f"Performing tabulation")

# Taxonomy
makedirs(tables/"Taxonomy", exist_ok=True)

log(f"  Creating BIOM files from Reads")
tabulate.taxonomy(read_taxonomy, tables/"Taxonomy/Reads")

log(f"  Creating BIOM files from Assemblies")
tabulate.taxonomy(assembly_taxonomy, tables/"Taxonomy/Assemblies")

# AMR
gene_aro = tabulate.amr_mapper(rgidb)

for folder in folders:

    name = " ".join(findall(r'[A-Z]?[a-z]+|[A-Z]+(?=[A-Z]|$)', folder))
    log(f"  Creating AMR tables from {name}")

    # Main
    makedirs(tables/f"AMR/Main/{folder}", exist_ok=True)
    tabulate.amr_genes(amr_main/f"{folder}", tables/f"AMR/Main/{folder}", cpu)

    # Taxonomy
    makedirs(tables/f"AMR/Taxonomy/{folder}", exist_ok=True)
    tabulate.amr_pathogens(
        amr_taxonomy/f"{folder}", tables/f"AMR/Taxonomy/{folder}",
        gene_aro, cpu)

# MetaCyc
log(f"  Creating MetaCyc tables")
makedirs(tables/f"Functions/MetaCyc", exist_ok=True)
tabulate.metacyc_functions(
    functions/"MetaCyc", tables/f"Functions/MetaCyc/Level", cpu)

# MiFaser
log(f"  Creating MiFaser tables")
makedirs(tables/f"Functions/MiFaser", exist_ok=True)
tabulate.mifaser_functions(
    functions/"MiFaser", tables/f"Functions/MiFaser/Level", cpu)

log(f"Finished tabulating")

log(f"Pipeline finished!")
