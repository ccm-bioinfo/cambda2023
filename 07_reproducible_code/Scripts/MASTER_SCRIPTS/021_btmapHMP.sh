#!/b|in/bash
for site in BAL DEN MIN NYC SAC SAN; do ls batches_$site/ | while read line; do task=$(echo $line | cut -f2 -d'-'); echo $task; echo cp  bt-${site}-array.sh  bt-${site}-array-$task.sh; echo sed -i 's/$(printf %03d $SLURM_ARRAY_TASK_ID)/'$task'/g'  bt-${site}-array-$task.sh; echo bash bt-${site}-array-$task.sh; done; done Hay que agregarlo al script
