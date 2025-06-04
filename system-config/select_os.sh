#!/bin/bash
USERNAME=root
machines=$(sed -nE 's/^PartitionName=\S+\s+Nodes=(\S+)\s+Default=\S+\s?$/\1/p' /etc/slurm/slurm.conf) #get all machines from the cluster
name=$(echo $machines | sed -nE 's/(\S+)\[[0-9]+-[0-9]+\]/\1/p') #get the machine name prefix
minVal=$(echo $machines | sed -nE 's/\S+\[([0-9]+)-[0-9]+\]/\1/p') #get the lowest index
maxVal=$(echo $machines | sed -nE 's/\S+\[[0-9]+-([0-9]+)\]/\1/p') #get the highest index

LAUNCH_CORRECT_OS="if ! test -f "etc/slurm/i_am_node"; then grub2-once $(grub2-once --list | sed -nE "s/^\s+([0-9]+)\s+openSUSE Leap 15.6 Calc$/\1/p"); reboot; fi" # ZMIENIC VLAB NA NAZWE OS DO OBLICZEN!!!
 
 for i in $(seq $minVal $maxVal); #for every machine in the cluster
 do
   HOSTNAME=$name$i
   ssh -l ${USERNAME} ${HOSTNAME} "${LAUNCH_CORRECT_OS}"
 done;
