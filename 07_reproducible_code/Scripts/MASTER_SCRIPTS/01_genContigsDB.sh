#!/bin/bash
#SBATCH -N 1 #1 node
#SBATCH -n 6 # 1 cores from each
#SBATCH --contiguous
#SBATCH --mem=12G #per node
#SBATCH -t 0-12:00:00
#SBATCH -p shared
#SBATCH --job-name="HaemCont"
#SBATCH -o odyssey_cont.out
#SBATCH -e odyssey_cont.err
#SBATCH --mail-type=END


### bash 01_genContigsDB.sh "first name bacteria"
### $ bash 01_genContigsDB.sh Enterobacter

genus=$1
# need to activate venv directly because node receiving job doesn't like bashrc aliases
#source ~/virtual-envs/anvio-dev-venv/bin/activate

# clean up fasta deflines in contig file at the start for smooth downstream
echo anvi-script-reformat-fasta -o $genus-isolates-CLEAN.fa --simplify-names --seq-type NT -r $genus-isolates-contigIDs.txt $genus-isolates.fa

echo mv $genus-isolates-CLEAN.fa $genus-isolates.fa

# make the contig db
echo anvi-gen-contigs-database -f $genus-isolates.fa -n $genus -o $genus-isolates-CONTIGS.db

# get bacterial single-copy gene, 16S, info from hmm collections
echo anvi-run-hmms -c $genus-isolates-CONTIGS.db --num-threads 18

# get the functional annotation started
#sbatch 99_geneFunctions.sh

# make bt of contigs for mapping later
#module load samtools/1.5-fasrc01 bowtie2/2.3.2-fasrc01
#bowtie2-build $genus-isolates.fa $genus-isolates

# start next step
#sbatch 02_btmapHMP.sh
