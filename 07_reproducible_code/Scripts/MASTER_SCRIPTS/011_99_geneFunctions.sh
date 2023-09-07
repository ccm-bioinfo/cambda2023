#!/bin/bash

#prefix="Klebsiella-isolates"
prefix=$1

# activate anvio if not already
#source ~/virtual-envs/anvio-dev-venv/bin/activate

# export amino acid sequences
echo anvi-get-sequences-for-gene-calls --get-aa-sequences --wrap 0 -c $prefix-CONTIGS.db -o $prefix-gene-calls-aa.faa ##This line was previously run in the Alnitak cluster ***WARNING***

batchDir="$prefix-gene-calls-batches"
mkdir $batchDir

# chop file up into 25k sequences per file
split -l 50000 -d -a 4 $prefix-gene-calls-aa.faa $batchDir/$prefix-gene-calls-aa.faa-

# figure out how many batches we made
hiBatch=$(ls $batchDir/*.faa-* | tail -1 | sed 's/^.*-0*\([1-9]*\)\(.$\)/\1\2/')
numBatches=$(($hiBatch + 1))

# set up the file to concatenate into
echo -e "gene_callers_id\tsource\taccession\tfunction\te_value" > interpro-results-fmt-$prefix.tsv

ls $batchDir/ | cut -f6 -d'-' | while read line

do
echo "#!/bin/bash"
#SBATCH -N 1 #1 nodes of ram
#SBATCH -n 12 # 12 cores from each
#SBATCH --contiguous
#SBATCH --mem=12G #per node
#SBATCH -t 0-6:00:00
#SBATCH -p shared
#SBATCH --array=0-$hiBatch%$numBatches
#SBATCH --job-name='interpro-%a'
#SBATCH -o odyssey_anviIP_%a.out
#SBATCH -e odyssey_anviIP_%a.err
#SBATCH --mail-type=END

# format job array id to match the split output
#taskNum=$(printf %04d $SLURM_ARRAY_TASK_ID)
taskNum=$(echo $line)

#batch=$(echo $batchDir/$prefix-gene-calls.faa-$taskNum)
batch=$batchDir/$prefix-gene-calls-aa.faa-$taskNum

#echo $taskNum
#echo $batch

#module load jdk/1.8.0_172-fasrc01

#echo interproscan.sh -i $batch -o ${batch}.tsv -f tsv --appl TIGRFAM,Pfam,SUPERFAMILY,ProDom,Gene3D

echo /botete/mvazquez/my_interproscan/interproscan-5.62-94.0/interproscan.sh -cpu 22 -i $batch -o ${batch}.tsv -f tsv --appl TIGRFAM,Pfam,SUPERFAMILY,Gene3D
# format it manually to be safe 
#cat ${batch}.tsv | awk -F\"\t\" '{print $1 FS $4 FS $5 FS $6 FS $9}' >> interpro-results-fmt-$prefix.tsv
echo cat ${batch}.tsv \| awk -F\\\"\\t\\\" \'{print \$\1 FS \$\4 FS \$\5 FS \$\6 FS \$\9}\' \>\> interpro-results-fmt-$prefix.tsv

# > ip-$batch.sh

done > scriptsBash

split -l3 scriptsBash --additional-suffix=.sh ip 
