#!/bin/bash
#wickd - daemon do sieci; ifstatus enp1s0
if test -f /sys/class/net/enp1s0/operstate && cat /sys/class/net/enp1s0/operstate | grep 'up' -q; 
then
echo "enp1s0 up";
else
echo "enp1s0 down";
echo "resetting port on the switch..."
snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv 192.168.0.239 ifAdminStatus.39 i 0
snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv 192.168.0.239 ifAdminStatus.39 i 1
ip link set dev enp1s0 up
fi;

#ifspeed 
#jeżeli ifspeed zawiedzie to jeszcze jeden restart
#ifspeed
#jeżeli ifspeed znowu zawiedzie to ustawić stan węzła na failed

#lab-sec ma porty 1-16
#lab-net ma porty 17-32
#snmpbulkwalk -v2c -c public 192.168.0.239 iso.3.6.1.2.1.17.7.1.2.2.1.2.1 | perl -pe ' s/SNMPv2-SMI::mib-2.17.7.1.2.2.1.2.1.//; while (/(\d+)/mg) { printf("%02x:", $1) } printf "  " '
#scontrol show node lab-net-57
