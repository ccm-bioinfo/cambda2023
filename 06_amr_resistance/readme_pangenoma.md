## Pangenomics  
A pangenome with genomic data of genera  _Escherichia_, _Klebsiella_, and _Enterobacter_ from the US cities in the challenge, with samples collected near 2017 can extend information about genes with antibiotic resistance. NCBI Genomes, see [Genomes Table](data/genome-metadata.csv) from the selected dates and places were downloaded and AMR annotated.
- [] Blast  
- [] [genomes CARD AMR annotation](data/230623_genomes_card_counts.tsv)  
- [] Full table  


## Metapangenomics
The CAMDA 2023 team has decided to create a meta pangenome for the bacterial genus: _Escherichia_, _Klebsiella_, and _Enterobacter_. The following approach follows the ideas presented in [2020 by Utter, et al](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-020-02200-2#Bib1).
Next, we will list the steps to replicate this research work.

To do:
1. Replicate the metapangenome of the oral microbiome.
2. Download the Escherichia, Klebsiella, and Enterobacter genomes that have been uploaded to NCBI in 2018
3. Obtain the trimming reads of the metagenomic data by city.
4. build the pangenome
5. Build the metapangenome
6. Discussion of the results with the CAMDA 2023 team

Doing
* We verified that the BetterLab server had the necessary programs to run the metapangenome.
- anvi’o (installed)
- Prodigal (installed)
- InterProScan (version 5.30-69) (installed?)
- bowtie2 (installed)
- BLASTP (installed)
- MUSCLE  (installed)
* Once the programs have been verified, we continue to replicate the data. However, we had some problems running the data due to the format of the files.

Done

Issues
BetterLab doesn't let you upload files larger than 3gb, apparently it's a problem with the "gz" format.

We don't know if InterProScan is already installed in BetterLab.


# Pangenome

We constructed a pangenome with the genomes that are in `/data/camda2023/genomes/.gff`. 
We use ppanggolin because is the time to compute the pangenome with large database of genomes is minimum compared with anvi-o and get_homologues.


We run the following comands in the directory `/home/haydee/camda2023/ppanggolin2/`:

~~~
ppanggolin cluster --pangenome pangenome.h5 --cpu 8
ppanggolin graph --pangenome pangenome.h5 --cpu 8
ppanggolin partition --pangenome pangenome.h5 --cpu 8
ppanggolin rgp --pangenome pangenome.h5 --cpu 8
ppanggolin write -p pangenome.h5 --regions --output rgp
ppanggolin spot --pangenome pangenome.h5 --cpu 8
ppanggolin write -p pangenome.h5 --spots --output spots
ppanggolin write -p pangenome.h5 --stats --output statistics
ppanggolin draw --pangenome pangenome.h5 --ucurve --output draw_ucurve
ppanggolin draw --pangenome pangenome.h5 --tile_plot --output draw_tile
ppanggolin draw --pangenome pangenome.h5 --tile_plot --nocloud --output draw_tile_nocloud
ppanggolin write -p pangenome.h5 --gexf --output gexf
ppanggolin write -p pangenome.h5 --json --output graph
ppanggolin write -p pangenome.h5 --Rtab --output pres-abs
ppanggolin write -p pangenome.h5 --csv --output matrix
ppanggolin write -p pangenome.h5 --partitions --output partitions
ppanggolin write -p pangenome.h5 --projection --output projection
ppanggolin write -p pangenome.h5 --families_tsv --output families
~~~
{: .language-bash}

To obtain the genes associated to each partition we run:

`ppanggolin fasta -p pangenome.h5 --output Persistent_Genes --genes persistent`
`ppanggolin fasta -p pangenome.h5 --output Cloud_Genes --genes cloud`
`ppanggolin fasta -p pangenome.h5 --output Shell_Genes --genes shell`

Also we obtain the proteins:

`ppanggolin fasta -p pangenome.h5 --output Shell_Protein --prot_families shell`
`ppanggolin fasta -p pangenome.h5 --output Cloud_Protein --prot_families cloud`
`ppanggolin fasta -p pangenome.h5 --output Persistent_Protein --prot_families persistent`

## Blast

First we add the identifier to each gene in each of the files `cloud_genes.faa`, `persistent_genes.faa` and `shell_genes.faa` that we obtain with ppanggolin. To do this, we use vi to replace `>` by `>cloud|`, `>persistent|` and `>shell|`.

We run blast with the table [`missingAmr_20230606_with_species.fasta`](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/codigos/data_preparation/data/missingAmr_20230606_with_species.fasta) as `query`.

We use the parameter from script [blastScript.sh](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/codigos/data_preparation/blastScript.sh)

~~~
mkdir tblastx_all/cloud/database
mkdir tblastx_all/cloud/output
mkdir tblastx_all/persistent/database
mkdir tblastx_all/persistent/output
mkdir tblastx_all/shell/database
mkdir tblastx_all/shell/output
~~~
{: language-bash}

`makeblastdb -in cloud_genes.fna -dbtype nucl -out tblastx_all/cloud/database/cloud_genes`

`tblastx -query missingAmr_20230606_with_species.fasta -db tblastx_all/cloud/database/cloud_genes -outfmt "7 qacc sacc qlen slen qcovs length pident" > tblastx_all/cloud/output/missingAmr_vs_cloud.blast`

`makeblastdb -in persistent_genes.fna -dbtype nucl -out tblastx_all/persistent/database/persistent_genes`

`tblastx -query missingAmr_20230606_with_species.fasta -db tblastx_all/persistent/database/persistent_genes -outfmt "7 qacc sacc qlen slen qcovs length pident" > tblastx_all/persistent/output/missingAmr_vs_persistent.blast`

`makeblastdb -in shell_genes.fna -dbtype nucl -out tblastx_all/shell/database/shell_genes`

`tblastx -query missingAmr_20230606_with_species.fasta -db tblastx_all/shell/database/shell_genes -outfmt "7 qacc sacc qlen slen qcovs length pident" > tblastx_all/shell/output/missingAmr_vs_shell.blast`

## Parse blast-outputs

We use the script [parse_blast.py](https://github.com/ccm-bioinfo/cambda2023/blob/main/06_amr_resistance/codigos/data_preparation/parse_blast.py)

First, we separate the output of blast in files with just one genome.

`cat /data/camda2023/genomes/genome-metadata.csv |cut -d',' -f1 |while read line; do grep $line missingAmr_vs_cloud.blast >$line.blast ; done`

`cat /data/camda2023/genomes/genome-metadata.csv |cut -d',' -f1 |while read line; do grep $line missingAmr_vs_persistent.blast >$line.blast ; done`

`cat /data/camda2023/genomes/genome-metadata.csv |cut -d',' -f1 |while read line; do grep $line missingAmr_vs_shell.blast >$line.blast ; done`

The we use the following to create the scripts for each of the previous files:

`ls *1.blast | while read line; do echo $line; cp parse_blast.py parse_blast_${line}.py; perl -p -i -e 's/SUSTITUIR1/'"$line"'/' parse_blast_${line}.py ; perl -p -i -e 's/SUSTITUIR2/temp_'"${line}"'/' parse_blast_${line}.py ; perl -p -i -e 's/SUSTITUIR3/output_'"${line}"'\.tsv/' parse_blast_${line}.py ; done`

Finally, we run all the scripts

`ls *1.blast.py | while read line; do python $line; done`

All the outputs can be found in the followings directory:

`/home/haydee/camda2023/tblastx_all/cloud/output/output*.tsv`
`/home/haydee/camda2023/tblastx_all/persistent/output/output*.tsv`
`/home/haydee/camda2023/tblastx_all/shell/output/output*.tsv`


