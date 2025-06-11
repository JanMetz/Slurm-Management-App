#!/bin/bash

#!/bin/bash

if [ -n "$SLURM_JOB_USER" -a "$SLURM_JOB_USER" != "root" ]
then
 HOSTNAME=$(hostname)
 if ! squeue -o "%u %N" | grep -q "$SLURM_JOB_USER $HOSTNAME"; then
    who | awk -v user="$SLURM_JOB_USER" '$1 == user { print $2 }' | \
        xargs -r -n1 pkill -t
 fi
fi
exit 0
