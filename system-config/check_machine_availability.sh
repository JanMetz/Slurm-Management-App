 #!/bin/bash
 machines=$(sed -nE 's/^PartitionName=\S+\s+Nodes=(\S+)\s+Default=\S+\s?$/\1/p' /etc/slurm/slurm.conf) #get all machines from the cluster
 name=$(echo $machines | sed -nE 's/(\S+)\[[0-9]+-[0-9]+\]/\1/p') #get the machine name prefix
 minVal=$(echo $machines | sed -nE 's/\S+\[([0-9]+)-[0-9]+\]/\1/p') #get the lowest index
 maxVal=$(echo $machines | sed -nE 's/\S+\[[0-9]+-([0-9]+)\]/\1/p') #get the highest index

 echo "checking state of machines ${machines}"
 
 for i in $(seq $minVal $maxVal); #for every machine in the cluster
 do
   machine=$name$i
   if ping -c1 $machine > /dev/null 2>&1; #ping once and redirect stdout and stderr to /dev/null
   then #if ping was successful
     echo "${machine} alive";
   else #if machine could not be pinged
     wol $(arp -a $machine | grep -oP '(([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2}))') > /dev/null #get the mac address of the machine from the arp table then wake on lan
     echo "waking up ${machine}..."
   fi;
 done;
