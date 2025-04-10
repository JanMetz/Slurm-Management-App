#!/bin/bash

 logger -t SLURM "suspending $@"
 for HOST in $(scontrol show hostnames "$1")
 do
   HNO=${HOST##*-}
   ipmitool -f /etc/ipmi.secret -I lan -H 10.10.0.$((150+$HNO)) -U root \
            power soft
 done

 exit 0
