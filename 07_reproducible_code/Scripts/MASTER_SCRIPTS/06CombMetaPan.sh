#!/bin/bash

prefix="Klebsiella-isolates"
readsStart=11  # which column in anvio layers table is the start of the metagenomes

#sites=(td bm supp)  # important that td is first if that will be the one onto which others are added

#sites=(MIN)  # important that td is first if that will be the one onto which others are added
sites=(NYC SAN)  # important that td is first if that will be the one onto which others are added
for site in ${sites[*]}; do

	anvi-export-misc-data -p $prefix-$site-10-PAN/$prefix-$site-10-PAN.db -t items -o $prefix-$site-items.txt
	anvi-export-misc-data -p $prefix-$site-10-PAN/$prefix-$site-10-PAN.db -t layers -o $prefix-$site-layers.txt

	# delete the unprocessed columns from TD so don't end up with two sets of TD metagenomes (formatted + unformatted)
	anvi-delete-misc-data -p $prefix-BAL-10-PAN/$prefix-BAL-10-PAN.db -t layers --keys-to-remove $(head -1 $prefix-$site-layers.txt | cut -f$readsStart- - | tr '\t' ',')

	# select metapan rings from items data and add oral habitat as prefix
	awk -F"\t" -v site=$site 'BEGIN{site=toupper(site)}; NR==1{print $1 FS site"-"$9 FS site"-"$10 FS site"-"$11 FS site"-"$12} NR>1 {print $1 FS $9 FS $10 FS $11 FS $12}'  $prefix-$site-items.txt >  $prefix-$site-items.tmp
	# prepend capitalized site ID before each metagenome's coverage of the genomes
	cat $prefix-$site-layers.txt | cut -f1,$readsStart- > $prefix-$site-layers.tmp
	#cut -d\' \' -f1,$readsStart- $prefix-$site-layers.txt \| sed \"s/SRS/\U$site-SRS/g\" \> $prefix-$site-layers.tmp

	# trim off junk from SRS filenames in header
	# sed -i\"\" \'s/_DENOVO_DUPLICATES_MARKED_TRIMMED//g\' $prefix-$site-layers.tmp

	# import this data back into the td data
	anvi-import-misc-data -p $prefix-BAL-10-PAN/$prefix-BAL-10-PAN.db -t items $prefix-$site-items.tmp
	anvi-import-misc-data -p $prefix-BAL-10-PAN/$prefix-BAL-10-PAN.db -t layers $prefix-$site-layers.tmp

done > pruebamet.sh
