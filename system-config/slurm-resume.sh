#!/bin/bash

restart_with_correct_os(){ #$1=hostname maszyny
     ssh root@$1 "grub2-once 3; reboot" #musza koniecznie byc klucze!
}


for node in $@;
do
  echo "Pinging ${node}..."

  if ping -c1 $node > /dev/null 2>&1; #ping once and redirect stdout and stderr to /dev/null
  then #if ping was successful
    #intel amt restart + pxe
  else #if machine could not be pinged
    #intel amt poweron + pxe
  fi;
done;

exit 0
