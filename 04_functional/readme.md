> # Notes
> 
> Please document your script to functional annotations to make them repeatable.  
> We annotated with Kegg, VFDB, Uniprot, MiFaser, MetaCyc, and InterproSCAN.
> To do:  
> All tables are complete  
> **MiFaser (Chihuil-Anton)**  👀  
> Already included (Results need to be described **Rafa**)  
> **MetaCyc (Chihuil-Anton)**  👀  
> Already had been included (Results need to be characterized **Rafa**)  
> **Kegg, (Huawei-Mirna)**  👀  
> To be included in models  
> **VFDB, (Huawei-Mirna)**  👀  
> Few results ¿How few?  
> **Uniprot (Huawei-Mirna)** 👀  
> **Karina** obtained Table by city  
> **InterproSCAN (Chihuil-Miguel)**  👀  
> Not finished for all cities  
> Interpro.sh -i <inputfile>  

# Functional annotation

This directory contains the scripts and results of the functional annotation
subproject of CAMDA 2023.

Contents:

0. [Preamble](#0-preamble)
    - File structure
    - Software
    - Databases
    - Annotation scripts
    - Tabulation scripts
1. [City prediction](#1-city-prediction)
2. [Mystery sample prediction](#2-mystery-sample-prediction)

## [0. Preamble](#functional-annotation)

### File structure

> :heavy_exclamation_mark: **To do**:
> - Add `models/` subdirectory structure; it should store machine learning
model results (parameters and metrics).
> - Add `interproscan.tsv` abundance table created from InterProScan's outputs.
> - Add `images/` subdirectory structure.

The git repository contains the following files:

```text
04_functional/
├── data/
│   └── {genomic,metagenomic,usco,usre}/
│       ├── models/
│       └── tables/
│           ├── metacyc/
│           │   └── {cummulative,noncummulative}/
│           │       └── {scaled,unscaled}/
│           │           └── lvl{1..8}.tsv
│           ├── mifaser/
│           │   └── lvl{1..4}.tsv
│           ├── kegg.tsv
│           ├── prokka.tsv
│           ├── uniprot.tsv.gz
│           └── vfdb.tsv.gz
├── images/
├── src/
│   ├── annotators/
│   │   └── {interproscan,kegg,metacyc,mifaser,prokka,uniprot,vfdb}.sh
│   ├── tabulators/
│   │   └── {interproscan,kegg,metacyc,mifaser,prokka,uniprot,vfdb}.py
│   ├── download-genomes.py
│   ├── load-databases.sh
│   ├── metacyc-conversion.py
│   └── mg-grid-search.py
├── environment.yml
└── readme.md
```

The complete file structure can be found in Huawei:
`/home/2022_15/camda-git/04_functional`. Briefly, we describe the contents of
each file and directory (elements marked with an asterisk `*` can only be found
on the Huawei server):

- `data/genomic/`. [Downloaded genomes data](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/data/genome-metadata.csv).
- `data/metagenomic/`. CAMDA 2023 metagenomic assembly data.
- `data/usco/`. [US city coassembly and extraction data](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/readmeCoassemblyByCity_AMR_Taxonomy.md).
- `data/usre/`. [US city extracted read assembly data](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/resultsReadsKrakenAssemblyBLAST.md).
- `data/{genomic,metagenomic,usco,usre}/assemblies/`. Assemblies. `*`
- `data/{genomic,metagenomic,usco,usre}/annotations/`. Results from each
individual annotation pipeline. `*`
- `data/{genomic,metagenomic,usco,usre}/tables/`. Abundance tables by sample
produced from the annotation results.
- `data/{genomic,metagenomic,usco,usre}/models/`. Machine learning model
results (parameters and metrics).
- `images/`. Various images.
- `src/annotators/`. Annotation pipelines.
- `src/tabulators/`. Scripts to create abundance tables from annotation
results.
- `src/download-genomes.py`. Downloads genomes from [this table](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/data/genome-metadata.csv).
- `src/load-databases.sh`. Installs necessary databases for the subproject.
- `src/metacyc-conversion.py`. Helper script for `src/tabulators/metacyc.py`.
- `src/mg-grid-search.py`. Performs machine learning grid search on all input
tables.
- `environment.yml`. Conda/mamba/micromamba environment spec file.
- `readme.md`. Current file.

### Software

> :heavy_exclamation_mark: **To do**:
> - Add InterProScan version and link.

```text
Usage:  ./src/download-software.sh [software_dir]
```

The `src/download-software.sh` script installs the software packages needed for
this subproject. Some of these programs are installed via a package manager
(such as conda, mamba or micromamba) into a virtual environment at
`[software_dir]/venv/`, whereas others are downloaded as standalone versions
from their git repositories into `[software_dir]/standalone/`. To ensure
software reproducibility, we have created a spec file at `environment.yml` with
which the virtual environment can be created, and we set a specific commit ID
for each of the standalone programs, ensuring that the same version is
installed.

The most important packages included in the virtual environment are:

- [Python 3.10.9](https://www.python.org/) and its third-party libraries:
    - [Pandas 1.5.2](https://pandas.pydata.org/)
    - [Matplotlib 3.6.2](https://matplotlib.org/)
    - [Seaborn 0.12.2](https://seaborn.pydata.org/)
    - [Scikit-learn 1.2.0](https://scikit-learn.org/)
- [Prokka 1.14.6](https://github.com/tseemann/prokka)
- [BLAST 2.14.0](https://blast.ncbi.nlm.nih.gov/Blast.cgi)
- [GNU parallel 20230522](https://www.gnu.org/software/parallel)
- [KofamScan 1.3.0](https://github.com/takaram/kofam_scan)

> **Warning**. The Prokka script is modified to skip the execution of
[tbl2asn](https://www.ncbi.nlm.nih.gov/genbank/table2asn/), which we have found
to be extremely slow when working with large metagenomic assemblies; as a
consequence, it does not produce `.gbk`, `.sqn` or `.err` outputs. View lines
31-34 of `src/download-software.sh` to view how this is done.

We used two standalone programs:

- [MinPath 1.6](https://github.com/mgtools/MinPath/tree/46d3e81a4dca2310d558bea970bc002b15d44767)
- [Mi-faser 1.61](https://bitbucket.org/bromberglab/mifaser/src/8012b2676eb3d2548db569191d19c0da9f64330c/)

### Databases

> :heavy_exclamation_mark: **To do**:
> - Add InterPro database download description.

```text
Usage:  ./src/load-databases.sh [databases_dir]
```

While some of the software have databases preinstalled, we had to manually
download other databases as well. This is done with the `src/load-databases.sh`
script, which must be run after `src/download-software.sh` as it requires
BLAST. It fetches the following databases:

- The KEGG [Ontology list](https://www.genome.jp/ftp/db/kofam/ko_list.gz) and 
[HMM profiles](https://www.genome.jp/ftp/db/kofam/profiles.tar.gz) are
downloaded and extracted into `[databases_dir]/kegg/`.
- The MinPath [mapping](https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/ec.to.pwy)
and [hierarchy](https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/pwy.hierarchy)
files for [MetaCyc](https://metacyc.org/) pathways from EnvGen's
[Metagenomics Workshop](https://github.com/EnvGen/metagenomics-workshop/) are
placed into `[databases_dir]/metacyc/`.
- The [reviewed UniProt](https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz) database is downloaded into
`[databases_dir]/uniprot/` and a BLAST database is generated from it.
- The [Virulence Factor Database](http://www.mgc.ac.cn/VFs/Down/VFDB_setB_pro.fas.gz)
(VFDB) is placed in `[databases_dir]/vfdb/` and a BLAST database is produced from
it.

These databases were downloaded in June 2023, and newer versions of them might
have become available. Please download the appropiate database versions to
ensure reproducibility.

### Annotation scripts

The `src/annotators/` directory stores annotation pipeline scripts, which are
named after the software or database they employ. Each script may contain some
of the following command line options:

- `-i`: input.
- `-o`: output.
- `-d`: databases directory (same as the one from `./src/load-databases.sh`)
- `-s`: standalone software directory (created by `./src/download-software.sh`
in `[software_dir]/standalone/`)
- `-g`: used when working with genomic sequences.

When setting an output, the scripts will automatically create all intermediate
directories if they don't already exist.

For example, if the metagenomic assemblies are located in
`data/metagenomic/assemblies/` and standalone software was downloaded into
`software/standalone/`, it is possible to annotate all of the assemblies with
Mi-Faser using GNU Parallel:

```text
# Runs 5 annotations in parallel
parallel -uj 5 ./src/annotators/mifaser.sh \
  -i data/metagenomic/assemblies/{/.}.fasta \
  -o data/metagenomic/annotations/mifaser/{/.}/ \
  -s software/standalone/ \
  ::: data/metagenomic/assemblies/*.fasta
```

Any annotation pipeline can be run in parallel, except for `metacyc.sh`, which
fails unless it is run one by one. We advice executing it with the `-uj 1`
option instead.

#### Prokka

```text
Usage:  ./src/annotators/prokka.sh [-g] [-i input_fasta] [-o output_dir]
```

The `src/annotators/prokka.sh` script must be the first annotation pipeline
to be executed, as its outputs are a requirement for the other pipelines
(except for `mifaser.sh`). This script runs the modified Prokka pipeline (see
*Software* section) on the `input_fasta` file. When using the `-g` flag, this
script runs Prokka in "genomic" mode, whereas, if not provided, it will use
Prokka's `--metagenome` flag, which, as stated in Prokka's help page, can
"improve gene predictions for highly fragmented genomes." Outputs are saved
into `output_dir`.

#### Mi-Faser

```text
Usage:  ./src/annotators/mifaser.sh [-i input_fasta] [-o output_dir]
                                    [-s standalone_dir]
```

The `src/annotators/mifaser.sh` script annotates assemblies with mi-faser 
(located in `[standalone_dir]/mifaser/`), which employs its own
curated databases, finds individual enzymes, and outputs E.C. numbers. Here, we
used the `GS-21-all` database, that, according to the
[mi-faser online service page](https://services.bromberglab.org/mifaser/submit),
stores a "set of reference proteins from Eukaryota, Archea, Bacteria and
Viruses, with experimentally annotated molecular functions (confirmed E.C.
annotations)," thus making it its largest and most comprehensive database.
Similar to `src/annotators/prokka.sh`, it uses and `input_fasta` assembly file,
and outputs into `output_dir`.

#### KEGG

```text
Usage:  ./src/annotators/kegg.sh [-i input_faa] [-o output_txt]
                                 [-d databases_dir]
```

The `src/annotators/kegg.sh` script uses KofamScan to annotate Prokka's `.faa`
files with the KEGG Ontology (KO) and HMM profiles. Input is taken from
`input_faa` and results are written to `output_txt`; the `databases_dir`
parameter must be the same as originally specified to the 
`./src/load-databases.sh` script (see *Databases* section).

#### MetaCyc

```text
Usage:  ./src/annotators/metacyc.sh [-i input_gff] [-o output_tsv]
                                    [-s standalone_dir] [-d databases_dir]
```

MetaCyc pathways are predicted with `src/annotators/metacyc.sh`, based on
EnvGen's
[Metagenomics Workshop functional annotation pipeline](https://metagenomics-workshop.readthedocs.io/en/2014-11-uppsala/functional-annotation/index.html).
Just like this pipeline, the script parses Prokka's `.gff` file for the E.C.
numbers that Prokka managed to identify, which are then used to obtain a 
minimum set of MetaCyc pathways with the help of MinPath (located in
`[standalone_dir]/minpath/`). Then, MinPath's outputs are rearranged into a
table where rows are individual functions and columns are the different
functional levels (with eight in total), each more specific than the previous,
which is accomplished with the `src/metacyc-conversion.py` helper script, taken
from the [Workshop's `genes.to.kronaTable.py` script](https://github.com/EnvGen/metagenomics-workshop/blob/master/in-house/genes.to.kronaTable.py).
Unlike the Workshop's pipeline, however, coverage is not calculated, but
functional abundance information is still obtained. The script uses the
`input_gff` file as input and saves outputs in `output_tsv`; it also requires
to specify the directory where the standalone software and the databases where
downloaded. It is the only script we advice not to run in parallel as it might
not finish annotating properly when doing so.

#### InterProScan

> :heavy_exclamation_mark: **To do**:
> - Add InterProScan pipeline description.

#### UniProt and VFDB

```text
Usage:  ./uniprot.sh [-i input_faa] [-o output_tsv] [-d databases_dir]
        ./vfdb.sh [-i input_faa] [-o output_tsv] [-d databases_dir]
```

Both `src/annotators/uniprot.sh` and `src/annotators/vfdb.sh` annotate Prokka's
`.faa` outputs by running BLAST against their respective databases (UniProt
and VFDB). They both produce `.tsv` files with five columns: `qseqid`,
`sseqid`, `evalue`, `pident`, and `stilte`, all of which correspond to BLAST's
homonymous outputs. They read the `input_faa` file, and output to `output_tsv`,
using the databases located in `databases_dir`.

### Tabulation scripts

The `src/tabulators/` directory contains the scripts used to create the
abundance tables located in `data/*/tables/`, and are named after the
corresponding annotation pipeline (for example, `src/tabulators/kegg.py`
creates the abundance table from `src/annotators/kegg.sh` outputs). All scripts
have the same command line options:

- `-g`: when running on genomic or extraction data.
- `-i`: input directory.
- `-o`: output directory.

Every single table produced has a similar structure. Every row corresponds to a
sample. The first column (named `City`) contains the city the sample was taken
from. If the `-g` flag is used, the second column is `Taxon`, which may contain
any of the following values: `En`, `Es`, or `Kl`; if it is run on genomic data,
these values refer to species (*Enterobacter hormaechei*, *Escherichia coli*,
and *Klebsiella pneumoniae*), but if run on extraction data, they refer to
genera (*Enterobacter*, *Escherichia*, and *Klebsiella*). The rest of the columns
contain individual annotation attributes. For instance, the following is a
subsection of the KEGG abundance table generated from metagenomic assemblies:

| |City|K01489|K09902|K03551|K01653|K01726|
|:--|:--|:--|:--|:--|:--|:--|
|CAMDA23_MetaSUB_gCSD16_AKL_1|AKL|8|0|6|4|2|
|CAMDA23_MetaSUB_gCSD16_AKL_2|AKL|0|1|1|1|2|
|CAMDA23_MetaSUB_gCSD16_AKL_3|AKL|7|3|5|5|5|
|CAMDA23_MetaSUB_gCSD16_BER_1|BER|1|1|0|3|1|
|CAMDA23_MetaSUB_gCSD16_BER_2|BER|1|0|1|1|0|
|CAMDA23_MetaSUB_gCSD16_BER_3|BER|0|0|1|0|0|

To create this table, the following command can be used (supposing that KEGG's
outputs are placed in `data/metagenomic/annotations/kegg/`):

```text
./src/tabulators/kegg.py -i data/metagenomic/annotations/kegg/ \
  -o data/metagenomic/tables/
```

The output table is saved in `data/metagenomic/tables/kegg.tsv`.

Tables located in `data/metagenomic/tables/` were created without the `-g`
flag, but the rest of the tables (located in `genomic`, `usco`, and `usre`)
were created with it.

#### MetaCyc

MetaCyc's abundance tables have the most complicated structure. In order to
understand it, one must take a look at the `.tsv` outputs that
`src/annotators/metacyc.sh` produces, whose rows look something like this:

| |Level1|Level2|Level3|Level4|Level5|Level6|Level7|Level8|
|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|
|3.0|Biosynthesis|Lipid-Biosynthesis|sophorolipid biosynthesis| | | | | |

The first number indicates relative abundance in the sample, and the rest of
the row contains the functional category organized in a hierarchical manner, in
which "Level`n`" is a subcategory of "Level`n-1`". Note that not all levels are
filled; this is the case for most rows in the `.tsv` files produced by the
pipeline. We called these tables with empty cells "noncummulative", because the
last known level (in this example, the third) is not placed in the rest of the
levels. To convert this table into its "cummulative" counterpart, one would
fill in the missing values in the table using the last known level; for
example:

| |Level1|Level2|Level3|Level4|Level5|Level6|Level7|Level8|
|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|:-----|
|3.0|Biosynthesis|Lipid-Biosynthesis|sophorolipid biosynthesis|**sophorolipid biosynthesis**|**sophorolipid biosynthesis**|**sophorolipid biosynthesis**|**sophorolipid biosynthesis**|**sophorolipid biosynthesis**|

We created two kinds of abundance tables from both the cummulative and
noncummulative datasets: one in which we take into account the relative
abundances, and one in which we don't. Each abundance table stores information
on a single MetaCyc level. To include relative abundance information in the
final tables, we multiplied the relative abundance by the unique function count
it corresponds to; that is, we *scaled* the function counts with their relative
abundances, for which reason these tables are called "scaled" abundance tables,
as opposed to the "*unscaled*" ones, where relative abundance was not included.
As such, we produced four kinds of tables: noncummulative unscaled, 
noncummulative scaled, cummulative unscaled, and cummulative scaled tables, for
each MetaCyc level (named `lvl1.tsv` to `lvl8.tsv`), producing 32 different
tables, all of which can be found in `data/*/tables/metacyc/`. This
entire process is executed by `src/tabulators/metacyc.py`.

#### Prokka

The `src/tabulators/prokka.py` script uses Prokka's `.tsv` outputs to create
the abundance tables. Because Prokka may predict some proteins without a known
function, we excluded these "hypothetical proteins" from the final tables. The
abundance tables can be found in `data/*/tables/prokka.tsv`.

#### Mi-Faser

Mi-Faser outputs the counts of E.C. numbers for each sample. Similarly to
MetaCyc's functional categories, E.C. numbers are hierarchical and are divided
into [four different levels](https://en.wikipedia.org/wiki/List_of_enzymes).
Thus, we created a single abundance table for each E.C. level and saved into
`data/*/tables/mifaser/lvl{1..4}.tsv`, all of which is accomplished
with the `src/tabulators/mifaser.py` script.

#### InterProScan

> :heavy_exclamation_mark: **To do**:
> - Add InterProScan tabulation script description.

#### KEGG

The `src/tabulators/kegg.py` script produces a single abundance table from
the outputs of `src/annotators/kegg.sh`, using only the rows that start with
an asterisk (`*`), which correspond to annotations with the highest confidence
levels. The tables can be found in `data/*/tables/kegg.tsv`.

#### UniProt and VFDB

Because both UniProt and VFDB annotations were performed with BLAST, their
outputs have an identical structure and, thus, their tabulation scripts
(`src/tabulators/uniprot.py` and `src/tabulators/vfdb.py`) are similar.
To create the abundance tables, we only kept BLAST results with a sequence
identity greater than 80%. Furthermore, because the amount of results is large,
the tabulation process is run on multiple processors, and the final tables are
gzip-compressed (meaning that their extension is `.tsv.gz`). These tables are
located in `data/*/tables/uniprot.tsv.gz` and
`data/*/tables/vfdb.tsv.gz`.

## [1. City prediction](#functional-annotation)

First we performed a stratified k-fold split on the data to get a representative subset of the 15% of the entire dataset which was assigned to be our testing set.

After that, we used a quantile transformation to avoid the problem of the different ranges on each variable. We fitted the transformation on the trainning set and then applied it to both trainning and testing sets.

Then, we focused on exploring five algorithms to address the problem of the sample classification. Theese algorithms either were the best performing in a fast analysis using LazyPredict library or were included because we wanted to see if it could improve its performance with later enhancing.

The algorithms we considered were:
 - Random Forest
 - Support Vector Classifier
 - Multi-layer perceptron
 - Extremely Randomized Trees
 - K-nearest neighbours

For each of this models we performed a 5-fold cross validation Grid Search for hyperparameter tunning. The hyperparameters tested are described in the tables below.

Random Forest:

<center>

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Criterion     | entropy, gini index               |
| Number of estimators | 10, 50, 100, 300, 500, 750, 1200       |
| Max depth  | 3,5,8,10,12,15,20,30,35,40   |
| Random state  | 0,1,2,3,4,5,6,7 |

</center>

Support Vector Classifier:

<center>

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Kernel     | lineal, polynomial                |
| Degree | 2,3,4,5,6,7,8       |
| Random state  | 0,1,2,3,4,5,6,7 |

</center>

Multi-layer perceptron:

<center>

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Hidden layer sizes     | (100,), (50,50,), (20,20,20,)                |
| Activation function | relu, tanh, logistic       |
| Batch size | auto, 20, 50, 100       |
| Solver  | adam, sgd |
| Maximun iterations  | 100, 200, 300, 400, 500, 800, 1000, 3000 |
| Random state  | 0,1,2,3,4,5,6,7 |
| Warm start  | True, False |
| Early stopping  | True, False |
| Learning rate  | constant, adaptive, invscaling |

</center>

Extremely Randomized Trees:

<center>

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Criterion     | Entropy, Gini                |
| Number of estimators | 10, 50, 100, 300, 500, 750, 1200       |
| Max depth  | 3,5,8,10,12,15,20,30,35,40   |
| Random state  | 0,1,2,3,4,5,6,7 |

</center>

K-nearest neighbours:

<center>

| Parameter     | Values                 |
| ------------- | ---------------------- |
| Number of neighbours     | 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21               |
| Weights | uniform, distance       |

</center>

After selecting the best hyperparameters for the models we evaluated them using three metrics:
- Accuracy
- Balanced accuracy
- F1 Score

We evaluated the predictions made by each of the individual models and an ensemble of the five models using a hard voting strategy and another using a soft voting method.

At the end we compared the performance of the 7 models (5 original models + 2 ensembles) for each of the functional annotations we made. 

## [2. Mystery sample prediction](#functional-annotation)

> :heavy_exclamation_mark: **To do**:
> - Finish this section.

In order to predict which city the mystery sample comes from, we performed
functional annotation on a set of genomes of the three bacterium species
sampled from different US cities between 2015 and 2018, and on both extractions
made by the AMR team. We are planning to use unsupervised learning techniques
to analyze frequent patterns in the genomic and extracted functional
annotations and compare them with the ones found in the metagenomic samples.
Because we weren't able to find genomic sequences from all US cities, our
team's findings would be, at most, one more piece of evidence to support the
conclusion reached by the other teams.
