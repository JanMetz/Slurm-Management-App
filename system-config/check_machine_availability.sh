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
     wol $(cat /etc/ethers | sed -nE "s/(.*)$machine/\1/p") > /dev/null #get the mac address of the machine from the ethers table then wake on lan
     echo "Waking up ${machine}..."
   fi;
 done;

 #maki musza byc na sztywno - nie ma jak brac ich dynamicznie - mozna przygotowac zeby bralo format isc-dhcp-server albo etc-ethers; 
 #tablice mozna stworzyc samemu, albo zapytac CS
 #dodac sposob na wybieranie odpowiedniego systemu innego niz vlab
