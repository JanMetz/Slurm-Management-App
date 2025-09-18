#!/bin/bash

echo "Resuming $@"
URL='wss://mesh.cs.put.poznan.pl';
USR='XXX';
PWD='YYY';

run_meshctrl_command(){ #$1=device power command
        DEV_ID=$(node /etc/slurm/meshctrl.js ListDevices --url $URL --loginuser $USR --loginpass $PWD --json | jq -r --arg host "$node" '.[] | select((.name | ascii_downcase)==$host) | ._id')
        node /etc/slurm/meshctrl.js DevicePower --$1 --url $URL --loginuser $USR --loginpass $PWD --id $DEV_ID
        sleep 15;
}

for node in $@;
do
    echo "Initiating power saving mode...";
    run_meshctrl_command off;
    sleep 10;
    run_meshctrl_command amtoff;
done;

exit 0
