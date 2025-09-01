#!/bin/bash

echo "resuming $@"
URL='wss://mesh.cs.put.poznan.pl';

check_curr_os(){
        ssh -q $1 exit

        if [ $? -ne 0 ]; then
                return 0; #correct os is running
        fi

        ssh -q $1-vlab exit

    if [ $? -ne 0 ]; then
        return 1; #vlab is running
    fi

        return 2; #other os is running
}

for node in $@;
do
        echo "Pinging ${node}..."

        if ! [ ping -c1 $node > /dev/null 2>&1 ]; #ping once and redirect stdout and stderr to /dev/null
        then #if ping was successful
                wol $node;
                sleep 100;
        fi;

        check_curr_os $node
        case $? in
                0) #correct OS
                        ;;
                1) #vlab
                        ssh lab-net-16-vlab 'sudo grub2-once 4; reboot;'
                        ;;
                2) #other OS
                        node meshctrl.js DevicePower --amtreset --url $URL --loginuser XXX --loginpass XXX --id 'j47j3K$MUFiFt6z3migKW2VxXxMXpuSvlvQaCc2dR49MDWBzYZsi@nPIqM5am7'
                        sleep 100;
                        ssh lab-net-16-vlab 'sudo grub2-once 4; reboot;'
                        ;;
                *) #not possible
                        ;;
        esac

        sleep 100;
done;

exit 0
