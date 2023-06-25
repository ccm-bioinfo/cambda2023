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

## 0. Software and databases

The `src/download-software.sh` script installs the software packages needed for
this subproject. Some of these programs are installed via a package manager
(such as conda, mamba or micromamba) into a virtual environment at
`software/venv/`, whereas others are downloaded as standalone versions from
their git repositories into `software/standalone/`. To ensure software
reproducibility, we have created a spec file at `software/environment.yml`
with which the virtual environment can be created, and we set a specific commit
ID for each of the standalone programs, ensuring that the same version is
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
> To do: Add InterProScan version and link.

**The Prokka script is modified to skip the execution of
[tbl2asn](https://www.ncbi.nlm.nih.gov/genbank/table2asn/), which we have found
to be extremely slow when working with large metagenomic assemblies; as a
consequence, it does not produce `.gbk`, `.sqn` or `.err` outputs. View lines
41-44 of `src/download-software.sh` to view how this is done.**

We used two standalone programs:

- [MinPath 1.6](https://github.com/mgtools/MinPath/tree/46d3e81a4dca2310d558bea970bc002b15d44767)
- [Mi-faser 1.61](https://bitbucket.org/bromberglab/mifaser/src/8012b2676eb3d2548db569191d19c0da9f64330c/)

While some of this software have databases preinstalled, we had to manually
download other databases as well. This is done with the `src/load-databases.sh`
script, which must be run after `src/download-software.sh` as it requires
BLAST. It fetches the following databases:

- The KEGG [Ontology list](https://www.genome.jp/ftp/db/kofam/ko_list.gz) and 
[HMM profiles](https://www.genome.jp/ftp/db/kofam/profiles.tar.gz) are
downloaded and extracted into `data/databases/kegg/`.
- The MinPath [mapping](https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/ec.to.pwy)
and [hierarchy](https://raw.githubusercontent.com/EnvGen/metagenomics-workshop/master/reference_db/metacyc/pwy.hierarchy)
files for [MetaCyc](https://metacyc.org/) pathways from EnvGen's
[Metagenomics Workshop](https://github.com/EnvGen/metagenomics-workshop/) are
placed into `data/databases/metacyc/`.
- The [reviewed UniProt](https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz) database is downloaded into
`data/databases/uniprot/` and a BLAST database is generated from it.
- The [Virulence Factor Database](http://www.mgc.ac.cn/VFs/Down/VFDB_setB_pro.fas.gz)
(VFDB) is placed in `data/database/vfdb/` and a BLAST database is produced from
it.

> To do: Add InterPro database download description.

These databases were downloaded in early June, 2023, and newer versions of them
might become available. Please ensure you download the appropiate database
versions to ensure reproducibility.

## 1. City prediction

We used seven different functional annotation pipelines, from which we produced
sixteen abundance tables that contain the number of functions found in each
metagenomic assembly. These tables were then used as training and validation
data for machine learning algorithms in order to identify the best annotation
or combination of annotations to predict the city from which a sample comes
from.

The files and directories related to city prediction have the following
structure:

```text
funcional/
├── data/
│   └── metagenomic/
│       ├── models/
│       │   ├── metacyc/
│       │   │   └── {cummulative,noncummulative}/{scaled,unscaled}/lvl{1..8}.tsv
│       │   ├── mifaser/
│       │   │   └── lvl{1,2,3,4}.tsv
│       │   └── {kegg,interproscan,uniprot,vfdb}.tsv
│       └── tables/    # same structure as models/
└── src/
    ├── mg-annotators/
    │   └── {kegg,metacyc,mifaser,interproscan,prokka,uniprot,vfdb}.sh
    ├── mg-tabulators/
    │   └── {kegg,metacyc,mifaser,interproscan,uniprot,vfdb}.py
    ├── mg-annotate.sh
    ├── mg-grid-search.py  # to be created
    └── metacyc-conversion.py
```

Briefly, we describe the contents of each file and directory:

- `data/metagenomic/tables/` stores abundance tables of samples against
functional annotations obtained through the different strategies.
- `data/metagenomic/models/` contains performance results of the machine
learning grid search applied on all of the functional annotation strategies.
- `src/mg-annotators/` contains the annotation scripts.
- `src/mg-tabulators/` stores the scripts used to create the abundance tables.
- `src/mg-annotate.sh` automatically performs all of the annotations on the
assemblies using the scripts of `src/mg-annotators/`.
- `src/mg-grid-search.py` performs the machine learning grid search on all
abundance tables.
- `src/metacyc-conversion.py` is a helper script for
`src/mg-annotators/metacyc.sh`.

### 1.1. Functional annotation

Before starting to annotate, it is important to place the metagenomic
assemblies into the `data/metagenomic/assemblies/` directory. You can do it by
creating symlinks like this (supposing you are in the `funcional/` root
directory):

```text
$ mkdir -p data/metagenomic/assemblies/
$ cd data/metagenomic/assemblies/
$ parallel ln -s {} {/} ::: /full/path/to/assemblies/*.fasta
$ cd ../../..
```

Any annotation can be performed using the following command:

```text
$ ./src/mg-annotators/xxx.sh [basename]
```

Where `xxx` can be any of `kegg`, `metacyc`, `mifaser`, `interproscan`,
`prokka`, `uniprot` or `vfdb`, and `[basename]` is the filename without
extension or directory (e.g. `CAMDA23_MetaSUB_gCSD17_SAN_3`). All pipelines use
12 CPUs.

To run a pipeline on all assemblies, you can use GNU parallel, specifying the
number of jobs with the `-j` parameter:

```text
$ parallel -uj 5 ./src/mg-annotators/xxx.sh {/.} ::: data/metagenomic/assemblies/*.fasta
```

**Warning**: The `src/mg-annotators/metacyc.sh` script fails when running in
parallel for reasons we are yet to find out; for now, we advice running it
sequentially instead.

Or you can use this convenience script to run all pipelines on all assemblies,
executing any number of jobs simultaneously (except for the MetaCyc pipeline), 
and skipping already finished annotations:

```text
$ ./src/mg-annotate.sh [number of jobs]
```

The `src/mg-annotators/prokka.sh` script must be the first annotation pipeline
to be executed, as its outputs are a requirement for the other pipelines
(except for `mifaser.sh`). This script runs the modified Prokka pipeline (see
*Software and databases* section) using the `--metagenome` flag, which, as
stated in Prokka's help page, can "improve gene predictions for highly
fragmented genomes." It takes a metagenomic assembly located in
`data/metagenomic/assemblies/[basename].fasta` and outputs into
`data/metagenomic/annotations/prokka/[basename]/`.

The `src/mg-annotators/mifaser.sh` script annotates assemblies with mi-faser 
(located in `software/standalone/mifaser/`), which employs its own curated
databases, finds individual enzymes, and outputs E.C. numbers. Here, we used
the `GS-21-all` database, that, according to the
[mi-faser online service page](https://services.bromberglab.org/mifaser/submit),
stores a "set of reference proteins from Eukaryota, Archea, Bacteria and
Viruses, with experimentally annotated molecular functions (confirmed E.C.
annotations)," thus making it its largest and most comprehensive database.
Similar to `src/mg-annotators/prokka.sh`, it uses the
`data/metagenomic/assemblies/[basename].fasta` assembly file as input, and
outputs into `data/metagenomic/annotations/mifaser/[basename]/`.

The `src/mg-annotators/kegg.sh` script uses KofamScan (located in
`software/standalone/kofamscan/`) to annotate Prokka's `.faa` files with the
KEGG Ontology (KO) and HMM profiles. Input is taken from
`data/metagenomic/annotations/prokka/[basename]/[basename].faa` and results
are written to `data/metagenomic/annotations/kegg/[basename].txt`.

MetaCyc pathways are predicted with `src/mg-annotators/metacyc.sh`, based on
EnvGen's
[Metagenomics Workshop functional annotation pipeline](https://metagenomics-workshop.readthedocs.io/en/2014-11-uppsala/functional-annotation/index.html).
Just like this pipeline, the script parses Prokka's `.gff` file for the E.C.
numbers that Prokka managed to identify, which are then used to obtain a 
minimum set of MetaCyc pathways with the help of MinPath (located in
`software/standalone/minpath/`). Then, MinPath's outputs are rearranged into a
table where rows are individual functions and columns are the different
functional levels (with eight in total), each more specific than the previous,
which is accomplish with `src/metacyc-conversion.py` helper script, taken from
the [Workshop's `genes.to.kronaTable.py` script](https://github.com/EnvGen/metagenomics-workshop/blob/master/in-house/genes.to.kronaTable.py).
Unlike the Workshop's pipeline, however, coverage is not calculated, but
functional abundance information is still obtained. The script uses the
`data/metagenomic/annotations/prokka/[basename]/[basename].gff` file as input
and saves outputs in `data/metagenomic/annotations/metacyc/[basename].tsv`. It
is the only script we advice not to run in parallel as it might not finish
annotating properly when doing so.

> To do: InterProScan pipeline description.

Both `src/mg-annotators/uniprot.sh` and `src/mg-annotators/vfdb.sh` annotate
Prokka's `.faa` outputs by running BLAST against their respective databases
(UniProt and VFDB). They both produce `.tsv` files with five columns: `qseqid`,
`sseqid`, `evalue`, `pident`, and `stilte`, all of which correspond to BLAST's
homonymous outputs. They read the
`data/metagenomic/annotations/prokka/[basename]/[basename].faa` file, and
output to `data/metagenomic/annotations/uniprot/[basename].tsv` and
`data/metagenomic/annotations/vfdb/[basename].tsv`, respectively.

### 1.2. Abundance table creation

The `src/mg-tabulators/` directory contains the scripts used to create the
abundance tables located in `data/metagenomic/tables/`, and are named after the
corresponding annotation pipeline (for example, `src/mg-tabulators/kegg.py`
creates the abundance table from `src/mg-annotators/kegg.sh` outputs).

### 1.3. Model training

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

## 2. Mystery sample prediction

> To do.
