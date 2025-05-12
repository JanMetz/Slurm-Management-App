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

 #tablice mozna stworzyc samemu, albo zapytac CS
 #dodac sposob na wybieranie odpowiedniego systemu innego niz vlab
 # trzeba miec roota!
 #os_id=$(grub2-once --list | sed -nE "s/^\s+([0-9]+)\s+VLab$/\1/p")
 #grub2-once os_id
 #reboot 

 #./meshcmd amtpower --host lab-net-57 --password PWD --bootmode 3 --bootdevice 0  --bootname "Windows Boot Manager HD" --restart - sprawdzic czy dziala dla pozostalych kompow w labie
 #password to hasło do systemu meshcentral, nie do komputera
 #można skonfigurować uwierzytelnianie za pomocą klucza RSA, ale wymaga to wersji Enterprise (Intel EMA)
