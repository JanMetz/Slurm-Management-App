#!/bin/bash

if [ -n "$SLURM_JOB_USER" -a "$SLURM_JOB_USER" != "root" ]
then
 HOSTNAME=$(hostname)
 if [ ! (squeue -o "%u %N" | grep "$SLURM_JOB_USER $HOSTNAME" -q) ] then
    who | awk '$1 == "$SLURM_JOB_USER" { print $2 }' | xargs -r -n1 pkill -t
 fi
fi
exit 0
