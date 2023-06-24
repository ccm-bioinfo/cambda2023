Assembled
To extract reads that belong to genus _Escherichia_, _Klebsiella_ and _Enterobacter_  
server: Alnitak   
dir: /data/camda2023/taxonomy  
 `ls read-level |cut -d'.' -f1|cut -d'_' -f1-5 |while read line; do extract_kraken_reads.py -k read-level/${line}.output -r read-level/${line}.report -s1 ../trimmed/${line}_1.fastq.gz -s2 ../trimmed/${line}_2.fastq.gz -o extraction/${line}_Es_1.fq -o2 extraction/${line}_Es_2.fq -t 561 --fastq-output --include-children; done >>extraction/Es.log`  
We use prefix (En) _Escherichia_, (Kl) _Klebsiella_ and (En) _Enterobacter_    
Script  extract_kraken_reads.py was used.  

To do:  
[ ] This reads need to be assembled 
[ ] Then blasted against curated AMR database. 
[ ] Then the presence/absence need to be produced  
[ ] Then a classification algorithm will predict the city  
