# Metapangenomics
To be able to look for genes with resistance to antibiotics in mysterious cities. The CAMDA 2023 team has decided to create a metapangenome for the bacteria: Escherichia, Klebsiella and Enterobacter.
This occurred to us due to the publication made in [2020 by Utter, et al](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-020-02200-2#Bib1).
Next, we will list the steps we are following to be able to replicate this research work.

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
