#!/bin/bash

if systemctl status slurmd | grep 'active (running)' -q;
then
echo "slurmd up"
else
echo "slurmd down"
systemctl start slurmd
fi;

if systemctl status munge | grep 'active (running)' -q && munge -n | grep -q 'MUNGE:';
then
echo "munge up"
else
echo "munge down"
systemctl start munge
fi;

if getent passwd voytek | grep -q '' && ldapsearch -LLL -ZZ -x '(uid=voytek)' dn | grep -q '';
then 
echo "ldap  up"
else 
echo "ldap down"
fi;

if test -f /etc/munge/munge.key && sha512sum /etc/munge/munge.key | grep 'cde7fc8b9b582f527d71f2e93c1b7441d08ed04219d6f342e351bd328a301bce0434e2a2b9eb1d4fb68c7bbd1cb48d1518cafb5f71c08a3071ec4d20e50bff83' -q;
then
echo "found munge key";
else 
echo "did not find munge key";
reboot
fi;

#wickd - daemon do sieci; ifstatus enp1s0
if test -f /sys/class/net/enp1s0/operstate && cat /sys/class/net/enp1s0/operstate | grep 'up' -q; 
then
echo "enp1s0 up";
else
echo "enp1s0 down";
ip link set dev enp1s0 up
#zrestartowac port na switchu
fi;

if snmpget -v2c -cpublic 192.168.0.239 ifOperStatus.39 | grep 'down' -q;
then
echo "Port on the switch is down..."
snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv 192.168.0.239 ifAdminStatus.39 i 1
echo "Setting up port on the switch..."
fi;

#lab-sec ma porty 1-16
#lab-net ma porty 17-32
#snmpbulkwalk -v2c -c public 192.168.0.239 iso.3.6.1.2.1.17.7.1.2.2.1.2.1 | perl -pe ' s/SNMPv2-SMI::mib-2.17.7.1.2.2.1.2.1.//; while (/(\d+)/mg) { printf("%02x:", $1) } printf "  " '
#scontrol show node lab-net-57
