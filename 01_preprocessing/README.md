# Preprocessing

This directory contains scripts for the preprocessing stage of the
[CAMDA 2023](http://camda.info/) challenge.

Antimicrobial resistance and taxonomic classification data for CAMDA 2023 is
published at Zenodo:

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7905440.svg)](https://doi.org/10.5281/zenodo.7905440)

It consists of a single `zip` file with the following directory structure:

```text
c23.zip
├── amr/
│   ├── tsv/
│   │   └── <basename>.tsv
│   ├── amr-counts.tsv
│   ├── amr-presence.tsv
│   ├── amr-counts-strict.tsv
│   └── amr-presence-strict.tsv
├── functions/
│   ├── html/
│   │   └── <basename>.html
│   └── tsv/
│       └── <basename>.tsv
├── taxonomy/
│   ├── assembly-level/
│   │   └── <basename>.report
│   ├── read-level/
│   │   └── <basename>.report
│   ├── assembly-biom.json
│   ├── assembly-biom.tsv
│   ├── read-biom.json
│   └── read-biom.tsv
├── amr_patterns.tsv
└── basenames.txt
```

The `<basename>` elements correspond to the original filename without extension.
Data is structured as follows (elements marked with an asterisk `*` can also
be found in this repository):

- `basenames.txt` contains the list of samples or basenames. `*`
- `taxonomy/assembly-level/` and `taxonomy/read-level/` contain
[Kraken2](https://ccb.jhu.edu/software/kraken2/) classification reports on
assembly, and read-level data.
- `taxonomy/assembly-biom.json` and `taxonomy/read-biom.json` are JSON files in
[BIOM](https://biom-format.org/) format produced from the reports on assembly,
and read-level data. `*`
- `taxonomy/assembly-biom.tsv` and `taxonomy/read-biom.tsv` are TSV files
produced from their respective JSON files. `*`
- `amr/tsv/` contains [RGI](https://github.com/arpcard/rgi)'s
TSV outputs with information on the identified antimicrobial resistance markers
for every sample, using the [CARD](https://card.mcmaster.ca/) database.
- `amr/amr-counts.tsv` is a contingency table of the number of times each gene
was found in each sample. `*`
- `amr_patters.tsv` is a TSV file containing the AMR markers and AST resistance
groups that were detected from 150 isolates that were collected from a hospital
of the USA between 2016 and 2017. It has four columns: `*`
    - `ID`. The isolate identifier.
    - `Species`. The species from which the AMR markers and AST resistance groups
    were extracted. Three different bacteria species were isolated:
    *Enterobacter hormaechei*, *Escherichia coli*, and *Klebsiella pneumoniae*.
    - `AST-based group`. The AST resistance group detected in every isolate. It
    can be one of three:
        - "3GC" refers to *third-generation cephalosporin resistance*. An
        isolate may be classified as 3GC-*resistant* or 3GC-*susceptible*.
        - "CP CRE" means that the isolate is an *carbapenem-resistant
        Enterobacterales* (CRE) and contains *carbapenemase* (CP) genes.
        - "Non-CP CRE" means that the isolate is an CRE but does not contain
        CP genes.
    - `WGS - AMR markers`. Contains a list of AMR markers that were identified
    in each isolate with Illumina short-reads sequencing (NGS).

> To do: Add functional annotation data description.

The following table contains detailed information on every sampled city.

|ID_city|City           |Latitude	|Longitude   |Climate|Year  |Samples|
|-------|---------------|-----------|------------|-------|------|-------|
|AKL	|Auckland       |-36.8508827| 174.7644881|Cfb    |2016  |14     |
|BAL	|Baltimore      | 39.2903848| -76.6121893|Cfa    |2017  |13     |
|BER	|Berlin         | 52.5200066|  13.404954 |Cfb    |2016  |15     |
|BOG	|Bogota         |  4.7109886| -74.072092 |Cfb    |2016  |15     |
|DEN	|Denver         | 39.7392358|-104.990251 |BSk    |2016-7|44     |
|DOH	|Doha           | 25.2854473|  51.5310398|BWh    |2016-7|27     |
|ILR	|Ilorin         |  8.5373356|   4.5443923|Aw     |2016-7|33     |
|LIS	|Lisbon         | 38.7222524|  -9.1393366|Csa    |2016  |14     |
|MIN	|Mineapolis     | 44.977753	| -93.2650108|Dfa    |2017  |6      |
|NYC	|New York City  | 40.7127753| -74.0059728|Cfa    |2016-7|46     |
|SAC	|Sacramento	    | 38.5815719|-121.4943996|Csa    |2016  |16     |
|SAN	|San Antonio	| 29.4251905| -98.4945922|Cfa    |2017  |16     |
|SAO	|Sao Paulo	    |-23.5557714| -46.6395571|Cfa    |2017  |25     |
|TOK	|Tokyo	        | 35.6761919| 139.6503106|Cfa    |2016-7|49     |
|VIE	|Vienna         | 48.2081743|  16.3738189|Cfb    |2017  |16     |
|ZRH    |Zurich	        | 47.3768866|   8.541694 |Cfb    |2017  |16     |

## Scripts documentation

This section describes the usage of every script found in `src`. Many of them
use the `basename` parameter, which refers to the original filename without its
extension. Two main requirements to run these scripts are the
[Conda](https://docs.conda.io/en/latest/) package manager[^conda] and the
[Docker](https://www.docker.com/) container deployment system[^docker].

[^conda]: Anaconda, Inc. (2017). Conda - conda documentation. Retrieved from
https://docs.conda.io/en/latest/

[^docker]: Merkel, D. (2014, Mar 1). Docker: lightweight Linux containers for
consistent development and deployment. Linux J., 2014(239).
https://dl.acm.org/doi/10.5555/2600239.2600241

### Initialization: `initialize.sh`

```text
Usage:  ./src/initialize.sh
```

This script creates a Conda virtual environment in `venv/` using the
`anaconda`, `bioconda`, `conda-forge`, and `defaults` channels, with the
following packages: `bedtools`, `bowtie2`, `kraken2`, `krona`, `megahit`,
`numpy`, `picard`, `prokka`, `samtools`, and `trim-galore`. It also pulls the
RGI[^rgi] Docker image as described
[here](https://github.com/arpcard/rgi#install-rgi-using-docker-singularity),
and clones [Minpath's GitHub repository](https://github.com/mgtools/MinPath).
This step requires Docker.

[^rgi]: Alcock, B. P., Huynh, W., Chalil, R., Smith, K. W., Raphenya, A. R.,
Wlodarski, M. A., Edalatmand, A., Petkau, A., Syed, S. A., Tsang, K. K., Baker,
S. J. C., Dave, M., McCarthy, M. C., Mukiri, K. M., Nasir, J. A., Golbon, B.,
Imtiaz, H., Jiang, X., Kaur, K., … McArthur, A. G. (2022, Oct 20). CARD 2023:
expanded curation, support for machine learning, and resistome prediction at
the Comprehensive Antibiotic Resistance Database. *Nucleic Acids Res., 51*(D1),
D690-D699. [10.1093/nar/gkac920](https://doi.org/10.1093/nar/gkac920)

### Database loading: `load-dbs.sh`

```text
Usage:  ./src/load-dbs.sh
```

This scripts downloads the standard Kraken2 and full RGI databases, and places
them into `krakenDB/` and `localDB/` directories respectively. The Kraken2
database version is from
[March 13th, 2023](https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20230314.tar.gz), whereas the RGI database uses
[CARD v3.2.6](https://card.mcmaster.ca/download/0/broadstreet-v3.2.6.tar.bz2),
and is loaded into RGI after download. This step requires Docker.

### Data download: `download.sh`

```text
Usage:  ./src/download.sh [username]@[url]:[directory] [files]
```

Downloads raw sample `files` into `raw/` from CAMDA 2023 SFTP server, skips if
already done. The `username`, `url` and `directory` parameters, as well as the
password can be found [here](http://camda2023.bioinf.jku.at/data_download). The
`files` parameter accepts file globbing.

### Adapter and quality trimming: `trim.sh`

```text
Usage:  ./src/trim.sh [basename]
```

This script trims the raw metagenome of a `basename` located in `raw/`,
skipping if already done, and outputs results to `trimmed/[basename]_1.fastq.gz`
and `trimmed/[basename]_2.fastq.gz`. It uses the `trim-galore`
package[^trimgalore] configured to discard reads whose length is below 40.
This step requires `venv/` to be activated.

[^trimgalore]: Krueger, F., James, F., Ewels, P., Afyounian, E., Weinstein, M.,
Schuster-Boeckler, B., Hulselmans, G., & sclamons. (2023).
*FelixKrueger/TrimGalore: v0.6.10 - add default decompression path (0.6.10)*.
Zenodo. [10.5281/zenodo.7598955](https://doi.org/10.5281/zenodo.7598955)

### Assembly: `assemble.sh`

```text
Usage:  ./src/assemble.sh [basename]
```

This script assembles the trimmed metagenomic reads of a `basename` located in
`trimmed/`, skipping if already done, and outputs the assembly to
`assembled/[basename].fasta`. It uses `megahit`[^megahit] to perform the
assembly. This step requires `venv/` to be activated.

[^megahit]: Li, D., Liu, C. M., Luo, R., Sadakane, K., & Lam, T. W. (2015,
May 15). MEGAHIT: an ultra-fast single-node solution for large and complex
metagenomics assembly via succinct de Bruijn graph. *Bioinformatics, 31*(10),
1674-1676.
[10.1093/bioinformatics/btv033](https://doi.org/10.1093/bioinformatics/btv033)

### Taxonomic classification: `classify.sh`

```text
Usage:  ./src/classify.sh [basename]
```

Performs taxonomic classification with the `kraken2` software[^kraken2] on both
the trimmed and the assembled metagenomes of a `basename`, skipping if already
done. Outputs to `taxonomy/read-level/[basename].report` and
`taxonomy/assembly-level/[basename].report` for read-level, and assembly-level
taxonomy, respectively. This step requires `venv/` to be activated.

[^kraken2]: Wood, D. E., Lu, J., & Langmead, B. (2019, Nov 28). Improved
metagenomic analysis with Kraken 2. *Genomy Biology, 20*(257).
[10.1186/s13059-019-1891-0](https://doi.org/10.1186/s13059-019-1891-0)

### AMR detection: `detect-amr.sh`, `get-amr-counts.py` and `get-amr-counts-strict.py`

```text
Usage:  ./src/detect-amr.sh [basename]
        ./src/get-amr-counts.py
        ./src/get-amr-counts-strict.py
```

The first script runs
[RGI main](https://github.com/arpcard/rgi#using-rgi-main-genomes-genome-assemblies-metagenomic-contigs-or-proteomes)
on the assembled metagenome of a `basename`, skipping if already done, and
producing outputs in `amr/[basename].tsv` and `amr/[basename].json`. It uses
DIAMOND in place of BLAST to speed up alignment, reports low quality hits,
nudges loose hits to strict, and includes loose hits in results. This step
requires Docker.

The second script creates the `amr/amr-counts.tsv` contingency table with gene 
counts per sample (as found in the Zenodo repository), and the 
`amr/amr-presence.tsv` which only reports gene presence per sample (and is not
stored in the Zenodo repository, but can be found in this GitHub repository).
The third script does the same exact thing as `get-amr-counts.py`, but only
considers AMR markers with a strict cut-off; its outputs can be found in
`amr/amr-counts-strict.tsv` and `amr/amr-presence-strict.tsv`.

### Functional annotation: `annotate-funcs.sh`

```text
Usage:  ./src/annotate-funcs.sh [basename]
```

> To do: Add functional annotation script documentation.
