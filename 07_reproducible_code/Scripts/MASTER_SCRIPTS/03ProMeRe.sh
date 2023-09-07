#!/bin/bash

# 20171016 - assign gene fams by interproscan
prefix="Klebsiella-isolates"

# need to activate venv directly because node receiving job order doesn't play with bashrc aliases

# habitats to iterate over
#sites=(bm td supp)
#sites=(BAL NYC SAN)
sites=(MIN)

# for each habitat we generate a custom job array
for site in ${sites[*]}; do

	mkdir profs_mapped_${prefix}_$site

	# make batches for each sites samples but leaving commented off as the bowtie2 batches work here too
	#ls --color=none hmp_all_$site/*1.fastq | split -l 8 -d -a 3 - batches_$site/$site-

	# find high number of batches we made before
	hiBatch=$(ls batches_$site/$site-* | tail -1 | sed 's/^.*-0*\([1-9]*\)\(.$\)/\1\2/')
	numBatches=$(($hiBatch + 1))

	echo "#!/bin/bash
	#SBATCH -N 1 #1 nodes of ram
	#SBATCH -n 12 # 1 cores from each
	#SBATCH --contiguous
	#SBATCH --mem=18G #per node
	#SBATCH -t 0-08:00:00
	#SBATCH -p shared
	#SBATCH --array=0-$hiBatch%$numBatches
	#SBATCH --job-name='pro-$site'
	#SBATCH -o odyssey_prof-$site-%a.out
	#SBATCH -e odyssey_prof-$site-%a.err
	#SBATCH --mail-type=NONE

	taskNum=\$(printf %03d \$SLURM_ARRAY_TASK_ID)

	#source ~/virtual-envs/anvio-dev-venv/bin/activate

	batch=\"batches_$site/$site-\$taskNum\"

	# for each fastq that was mapped
	for FQ in \$(cat \$batch); do

		# recreate the name of the bam from the name of the fastq
		bam=\$(echo \"\$FQ\" | sed 's/hmp_all_$site/bt_mapped_$prefix\_$site/; s/\_1.fastq.*$/.bam/')
		echo 'bam is:'$bam >> Recur

		# generate a profile
		anvi-profile -i \$bam -c $prefix-CONTIGS.db -W -M 0 -T 12 --write-buffer-size 500 -o \$(echo \"\$bam\" | sed 's/bt/profs/; s/.bam//')

		#anvi-profile -i \$bam -c $prefix-cp-CONTIGS.db -W -M 0 -T 12 --write-buffer-size 500 -o \$(echo \"\$bam\" | sed 's/bt/profs/; s/.bam//')

	done
	" > prof-$site.sh 

	#" > prof-$site.sh && sbatch prof-$site.sh && rm prof-$site.sh

	#sleep 25
done
