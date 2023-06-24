## Taxonomic assignation - Extraction by genus - City binning - Assembly - AMR 
In this pipeline, we first found reads taxonomy assignation using Kraken2, then 
we extracted and binned all reads that belonged to the same city. Next, we run RGI
to predict the 180 CARD models that belong to the mysterious sample and blastn with 
our manually-curated dataset. Finally, metagenome samples resistance profile was compared
against mysterious city AMR profile.  
First Kraken2 was used to assign taxonomy to reads of each sample; then, reads were extracted using [kraken-tools](https://github.com/jenniferlu717/KrakenTools) 

### Extraction  
taxonomy Ids 
| Genus     | TaxId    | Species     |   TaxId  |    
|-----|-----|-----|-----|
|_Escherichia_|561|_Escherichia coli_|562   |  
|_Enterobacter_|547|_Enterobacter hormaechei_| 158836 |  
|_Klebsiella_|570|_Klebsiella pneumoniae_|573|  
   
 Reads will be saved in `extraction` directory.  
 _Escherichia_   
`find read-level -type f -exec basename {} \; |cut -d'.' -f1 |sort |uniq |while read SAMPLE; do echo extract_kraken_reads.py -k read-level/${SAMPLE}.output -r read-level/${SAMPLE}.report -s1 ../trimmed/${SAMPLE}_1.fastq.gz -s2 ../trimmed/${SAMPLE}_2.fastq.gz -o extraction/${SAMPLE}_En_1.fq -o2 extraction/${SAMPLE}_En_2.fq -t 547 --fastq-output --include-children ; extract_kraken_reads.py -k read-level/${SAMPLE}.output -r read-level/${SAMPLE}.report -s1 ../trimmed/${SAMPLE}_1.fastq.gz -s2 ../trimmed/${SAMPLE}_2.fastq.gz -o extraction/${SAMPLE}_Es_1.fq -o2 extraction/${SAMPLE}_Es_2.fq -t 561 --fastq-output --include-children ; done`


 _Enterobacter_   
 `find read-level -type f -exec basename {} \; |cut -d'.' -f1 |sort |uniq |while read SAMPLE; do echo extract_kraken_reads.py -k read-level/${SAMPLE}.output -r read-level/${SAMPLE}.report -s1 ../trimmed/${SAMPLE}_1.fastq.gz -s2 ../trimmed/${SAMPLE}_2.fastq.gz -o extraction/${SAMPLE}_En_1.fq -o2 extraction/${SAMPLE}_En_2.fq -t 547 --fastq-output --include-children ; extract_kraken_reads.py -k read-level/${SAMPLE}.output -r read-level/${SAMPLE}.report -s1 ../trimmed/${SAMPLE}_1.fastq.gz -s2 ../trimmed/${SAMPLE}_2.fastq.gz -o extraction/${SAMPLE}_En_1.fq -o2 extraction/${SAMPLE}_En_2.fq -t 547 --fastq-output --include-children ; done`

_Klebsiella_     
`find read-level -type f -exec basename {} \; |cut -d'.' -f1 |sort |uniq |while read SAMPLE; do echo extract_kraken_reads.py -k read-level/${SAMPLE}.output -r read-level/${SAMPLE}.report -s1 ../trimmed/${SAMPLE}_1.fastq.gz -s2 ../trimmed/${SAMPLE}_2.fastq.gz -o extraction/${SAMPLE}_En_1.fq -o2 extraction/${SAMPLE}_En_2.fq -t 547 --fastq-output --include-children ; extract_kraken_reads.py -k read-level/${SAMPLE}.output -r read-level/${SAMPLE}.report -s1 ../trimmed/${SAMPLE}_1.fastq.gz -s2 ../trimmed/${SAMPLE}_2.fastq.gz -o extraction/${SAMPLE}_Kl_1.fq -o2 extraction/${SAMPLE}_Kl_2.fq -t 570 --fastq-output --include-children ; done`

In some cities, these organisms are among the low-abundance genus.  
![OTU abundances](fig/Abundances_Denver_SFC_EsEnKl.jpeg)  

### AMR annotation  
Alnitak   
[ ] CARD:   Anton 👀
Counts: /data/camda2023/extraction/extraction-amr-counts.tsv  (492 Ids, some of them included in the mysterious sample)  
Presence_absence: /data/camda2023/extraction/extraction-amr-presence.tsv  
[ ] blastn     Fonty 👀



![Hierarchical clustering with USA Cities](fig/230623_ModeAMR_ETBC.png)
![Full hierarchical Clustering](fig/230623_Mode_Full_AMR_ETBC.png)
