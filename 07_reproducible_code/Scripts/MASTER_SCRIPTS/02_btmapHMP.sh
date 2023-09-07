#!/bin/bash

# 20171016 - assign gene fams by interproscan
## $bash  02_btmapHMP.sh Enterobacter-isolates 
prefix=$1

# this sets up the site suffixe to iterate through in parallel
#sites=(bm td supp)
sites=(BAL MIN SAN NYC SAC DEN)
#sites=(BAL)

# iterate through each habitat - this will create a custom script for each habitat that is an array over all that sites metagenomes
for site in ${sites[*]}; do
##Create a link sinbolik

mkdir hmp_all_$site
cd hmp_all_$site
find /data/camda2023/trimmed/ -name "*${site}*" -exec ln -s {} . ';'
cd ../
########
mkdir bt_mapped_${prefix}_$site
mkdir batches_$site

# make batches for each sites samples
#ls --color=none hmp_all_$site/*1.fastq | split -l 8 -d -a 3 - batches_$site/$site-
ls --color=none hmp_all_$site/*1.fastq.gz | split -l 8 -d -a 3 - batches_$site/$site-

# figure out the upper bound of the array for slurm
hiBatch=$(ls batches_$site/$site-* | tail -1 | sed 's/^.*-0*\([1-9]*\)\(.$\)/\1\2/')
numBatches=$(($hiBatch + 1))

echo 'hiBatch' $hiBatch >> vie ## delete
echo 'numBatches' $numBatches >> vie ## delete

echo "#!/bin/bash
#SBATCH -N 1 #1 nodes of ram
#SBATCH -n 12 # 1 cores from each
#SBATCH --contiguous
#SBATCH --mem=18G #per node
#SBATCH -t 0-06:00:00
#SBATCH -p shared
#SBATCH --array=0-$hiBatch%$numBatches
#SBATCH --job-name='bt-$site'
#SBATCH -o odyssey_bt-$site-%a.out
#SBATCH -e odyssey_bt-$site-%a.err
#SBATCH --mail-type=NONE

# format this array element id to match batch name
taskNum=\$(printf %03d \$SLURM_ARRAY_TASK_ID)

#module load samtools/1.5-fasrc02 bowtie2/2.3.2-fasrc02 xz/5.2.2-fasrc01

# set what batch we are on
batch=\"batches_$site/$site-\$taskNum\"

# loop through metagenomes to map in this batch
for FQ in \$(cat \$batch); do 

# FQ was the R1 path so extract the R2 path from it
r2=\$(echo \"\$FQ\" | sed 's/_1.fastq.gz/_2.fastq.gz/')

bowtie2 -x $prefix -1 \$FQ -2 \$r2 --no-unal --threads 18 | samtools view -b - | samtools sort -@ 12 - > \$(echo \"\$FQ\" | sed 's/hmp_all_$site/bt_mapped_${prefix}_$site/; s/\_1.fastq.*$/.bam/')

# index as next anvio step requires indexed bams
samtools index \$(echo \"\$FQ\" | sed 's/hmp_all_$site/bt_mapped_${prefix}_$site/; s/\_1.fastq.*$/.bam/')

done

" > bt-$site-array.sh #&& bash bt-$site-array.sh && rm bt-$site-array.sh # save this file and submit it then delete for housekeeping

#" > bt-$site-array.sh && sbatch bt-$site-array.sh && rm bt-$site-array.sh # save this file and submit it then delete for housekeeping
#sleep 30

done
