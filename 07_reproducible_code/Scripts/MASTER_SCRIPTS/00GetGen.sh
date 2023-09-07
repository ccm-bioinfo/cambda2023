#!/b|in/bash

assemblyFile="assembly_summary_refseq.txt"
taxa="Enterobacter_hormaechei"
taxDir="Enterobacter_hormaechei"

mkdir ncbi_genomes
mkdir ncbi_genomes/$taxDir

for taxon in $taxa; do

	# make sure whitespaces or lack thereof are ok
	taxonSafe=$(echo $taxon | tr ' ' '_')
	taxonGrep=$(echo $taxon | tr '_' ' ')

	# assembly directory on the ncbi ftp site is the 20th column in assembly file
	ftpDir=$(grep "$taxonGrep" $assemblyFile | awk -F"\t" '{print $20}')

	cd ncbi_genomes/$taxDir

	for dirPath in $ftpDir; do

		# get just the ID
		genomeID=$(echo "$dirPath" | sed 's/^.*\///g')
		# get the path to the genomic fasta file
		ftpPath="$dirPath/${genomeID}_genomic.fna.gz"
		# make a friendly prefix - 'Gspe' from 'Genus species'
		friendlyName=$(grep "$genomeID" ../../$assemblyFile | awk -F"\t" '{print $8}' | awk '{print $1 FS $2}' | tr -d '_,.-' | sed -E 's/^(.)[A-z0-9]* ([A-z0-9]{2}).*$/\1\2/')


		# figure out the taxon + strain id from sheet to make deflines; 9 = strain,10=additional info
		# this makes it simple to go from anvio contigs db to genome's original strain ID on NCBI
		deflineName=$(grep "$genomeID" ../../$assemblyFile | awk -F"\t" '{print $8 " " $9}' | sed 's/strain=//' | tr ' -' '_' | tr -d '/=(),.')

		genomeID="${friendlyName}_$genomeID"

		# download & uncompress
		wget $ftpPath -O $genomeID.fa.gz
		gunzip $genomeID.fa.gz

		# rename the deflines
		awk -v defline="$deflineName" '/^>/{print ">" defline "_ctg" (++i)}!/^>/' $genomeID.fa >> temp.txt
		mv temp.txt $genomeID.fa

	done

done
