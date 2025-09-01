#!/bin/bash

echo "resuming $@"
URL='mesh.cs.put.poznan.pl';
USR='XXX';
PWD='YYY';

check_curr_os(){
        ssh -q $1 exit

        if [ $? -eq 0 ]; then
                return 0; #correct os is running
        fi

        ssh -q $1-vlab exit

        if [ $? -eq 0 ]; then
                return 1; #vlab is running
        fi

        return 2; #other os is running
}

wait_for_wakeup(){
        echo "Waiting for $1 to wake up...";
        for i in $(seq 1 55); do #wait until the host becomes reachable (max 55s)
        if ping -c 1 -W 1 $1 > /dev/null 2>&1; then
                echo "$1 woken up!"
                if [ $i -gt 1 ]; then
                        sleep 40; #sleep until OS loads, but only if the machine needed to wakeup
                fi;
                return 0;
        fi
        done

        echo "$1 did not wake up..."
        return 1;
}

for node in $@;
do
        echo "Pinging ${node}..."

        if ! [ ping -c1 $node > /dev/null 2>&1 ]; #ping once and redirect stdout and stderr to /dev/null
        then #if ping was not successful
                wol $node;
                wait_for_wakeup $node;
        fi;

        check_curr_os $node
        case $? in
                0) #correct OS
                        echo "$node is running correct OS"
                        ;;
                1) #vlab
                        echo "$node is running vlab"
                        ssh $node-vlab 'sudo grub2-once 4; sudo reboot;'
                        sleep 15;
                        wait_for_wakeup $node
                        ;;
                2) #other OS
                        echo "$node is running other OS"
                        DEV_ID=$(node /etc/slurm/meshctrl.js ListDevices --url $URL --loginuser $USR --loginpass $PWD --json | jq -r --arg host "$node" '.[] | select((.name | ascii_downcase)==$host) | ._id')
                        node /etc/slurm/meshctrl.js DevicePower --amtreset --url $URL --loginuser $USR --loginpass $PWD --id $DEV_ID
                        sleep 15;
                        wait_for_wakeup $node;
                        ssh $node-vlab 'sudo grub2-once 4; reboot;'
                        sleep 15;
                        wait_for_wakeup $node
                        ;;
                *) #not possible
                        echo "something went wrong..."
                        ;;
        esac
done;

exit 0
