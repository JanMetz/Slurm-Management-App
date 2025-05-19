#!/bin/bash

machines=$(sed -nE 's/^PartitionName=\S+\s+Nodes=(\S+)\s+Default=\S+\s?$/\1/p' /etc/slurm/slurm.conf) #get all machines from the cluster

scontrol update NodeName=$machines State=RESUME # reset to IDLE

echo "Cleanup done at $(date)" >> /var/log/slurm/cleanup.log
