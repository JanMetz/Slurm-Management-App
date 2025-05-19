#!/bin/bash

   H=$(hostname)
   if [ "${H%-*}" != "dcc" ]
   then
       exit 0
   fi
   if [ -n "$SLURM_JOB_USER" -a "$SLURM_JOB_USER" != "root" ]
   then
       pkill -u $SLURM_JOB_USER
       sleep 2
       pkill -9 -u $SLURM_JOB_USER
       who | awk '$1 == "$SLURM_JOB_USER" { print $2 }' | xargs -r -n1 pkill -t
   fi
   exit 0
