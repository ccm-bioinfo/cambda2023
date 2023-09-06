#!/bin/bash
#SBATCH -N 1 #1 nodes of ram
#SBATCH -n 20 # 1 cores from each
#SBATCH --contiguous
#SBATCH --mem=12G #per node
#SBATCH -t 1-12:00:00
#SBATCH -p shared
#SBATCH --job-name="COGhp"
#SBATCH -o odyssey_COG-hp.out
#SBATCH -e odyssey_COG-hp.err
#SBATCH --mail-type=END

# activate anvio
#source ~/virtual-envs/anvio-dev-venv/bin/activate

#module load ncbi-blast/2.10.0+-fasrc01

prefix="Enterobacter-isolates"

anvi-run-ncbi-cogs -c $prefix-CONTIGS.db --search-with blastp -T 18 
