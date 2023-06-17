#!/bin/bash

queryFile=missingAmr.fasta
dataFolder=/data/camda2023/assembled/

# create a folder to store links to all fastas and the makeblastdb files and run script inside that folder

# creates symbolic links to all the fasta files
find ${dataFolder} -type f -name "*fasta" -exec ln -s {} . ';'

# create sample list
ls | grep "fasta" > sampleList.txt


while read assembly; do
	makeblastdb -in ${assembly} -dbtype nucl
	blastn -db ${assembly}-query ${queryFile} -outfmt "7 qacc sacc qlen slen qcovs length pident" -out ${queryFile}_vs_${assembly}.blast.txt
done < sampleList.txt

cat ${queryFile}*.blast.txt > blastAll.txt
