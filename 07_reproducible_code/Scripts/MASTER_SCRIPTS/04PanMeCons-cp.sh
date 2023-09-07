#!/bin/bash

# 20171016 - assign gene fams by interproscan
prefix="Klebsiella-isolates"

indiv="Klebsiella-isolates"
# make a two-column table of which contigs go with which genomes for later, easy since original contigs had this already
sed 's/_ctg[0-9]*$//' $prefix-contigIDs.txt > $prefix-renaming-manual.tsv

# list of habitats to iterate over
#sites=(td bm supp)
sites=(BAL MIN)
mcl=10
#mcls=(8 10 12) # for varying mcl
#site="td" # for varying mcl

for site in ${sites[*]}; do
	#for mcl in ${mcls[*]}; do  # for varying mcl

	echo "#!/bin/bash
	#SBATCH -N 1 #1 node
	#SBATCH -n 1 
	#SBATCH --contiguous
	#SBATCH --mem=60G #per node
	#SBATCH -t 1-18:00:00
	#SBATCH -p shared
	#SBATCH --job-name=\"fin-$site-$indiv\"
	#SBATCH -o odyssey_metapan-$site-$indiv.out
	#SBATCH -e odyssey_metapan-$site-$indiv.err
	#SBATCH --mail-type=END

	#source ~/virtual-envs/anvio-dev-venv/bin/activate
	#module load mcl/14.137-fasrc01 ncbi-blast/2.6.0+-fasrc01 #blast-2.6.0+-fasrc01

	anvi-merge profs_mapped_${indiv}_$site/*/PROFILE.db -c $indiv-cp-CONTIGS.db -o $indiv-$site-MERGED -W

	anvi-import-collection -c $indiv-cp-CONTIGS.db -p $indiv-$site-MERGED/PROFILE.db -C Genomes --contigs-mode $indiv-COLLECTION-MAPPER.txt
	anvi-summarize -c $indiv-cp-CONTIGS.db -p $indiv-$site-MERGED/PROFILE.db -C Genomes -o $indiv-$site-SUMMARY

	echo 'done summarizing'

	bash anvi-script-gen-internal-genomes-table.sh $indiv-$site

	sed \"s/$indiv-$site-cp-CONTIGS.db/$indiv-cp-CONTIGS.db/g\" $indiv-$site-internal-genomes-table.txt > tmp
	mv tmp $indiv-$site-internal-genomes-table.txt

	anvi-gen-genomes-storage -i $indiv-$site-internal-genomes-table.txt -o $indiv-$site-cp-GENOMES.db
	anvi-pan-genome --mcl-inflation $mcl -o $indiv-$site-$mcl-PAN -g $indiv-$site-cp-GENOMES.db -n $indiv-$site-$mcl --use-ncbi-blast -T 12

	anvi-meta-pan-genome -i $indiv-$site-internal-genomes-table.txt -g $indiv-$site-cp-GENOMES.db -p $indiv-$site-$mcl-PAN/*PAN.db
	
	" > finish-$site.sh

	#sleep 10

done
