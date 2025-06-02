#!/bin/bash

machines=$(sed -nE 's/^PartitionName=\S+\s+Nodes=(\S+)\s+Default=\S+\s?$/\1/p' /etc/slurm/slurm.conf) #get all machines from the cluster
name=$(echo $machines | sed -nE 's/(\S+)\[[0-9]+-[0-9]+\]/\1/p') #get the machine name prefix
minVal=$(echo $machines | sed -nE 's/\S+\[([0-9]+)-[0-9]+\]/\1/p') #get the lowest index
maxVal=$(echo $machines | sed -nE 's/\S+\[[0-9]+-([0-9]+)\]/\1/p') #get the highest index

echo "Checking state of machines ${machines}..."

for i in $(seq $minVal $maxVal); #for every machine in the cluster
do
  machine=$name$i
  echo "Pinging ${machine}..."

  if ping -c1 $machine > /dev/null 2>&1; #ping once and redirect stdout and stderr to /dev/null
  then #if ping was successful
    echo "${machine} alive";
  else #if machine could not be pinged
    echo "Unable to contact ${machine}"
    mac=$(cat /etc/ethers | sed -nE "s/(^[^#]+)\s+$machine/\1/p"); #get the mac address of the machine from the ethers table
    if ! [ -z "${mac}" ]; 
    then
      echo "Waking up ${machine}...";
      wol $mac > /dev/null; # wake on lan
    else
      echo "No entry in the ethers table for ${machine}";
    fi;
  fi;
done;

exit 0
