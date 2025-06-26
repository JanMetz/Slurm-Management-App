#!/bin/bash

restart_switch_port(){ #$1 = numer portu na switchu $2 = licznik prob
  echo "Restarting switch port... ($2/3)";
  snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv 192.168.0.239 ifAdminStatus.$1 i 0;
  sleep 10;
  snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv 192.168.0.239 ifAdminStatus.$1 i 1;
}

restart_interface(){
  echo "Restarting interface... ($1/3)";
  ip link set dev enp1s0 down;
  sleep 10;
  ip link set dev enp1s0 up;
}

if test -f /sys/class/net/enp1s0/operstate && cat /sys/class/net/enp1s0/operstate | grep 'up' -q; 
then
  echo "Interface 10GbE (enp1s0) is up. You're good to go!";
else
  echo "Interface 10GbE (enp1s0) is down. Attempting to fix...";
  #test połączenia po kablu? ethtool --cable-test

  for i in {1..3}
  do
    PORT=$(cat /etc/ports | sed -nE "s/(^[^#]+)\s+$(hostname)/\1/p");
    restart_switch_port $PORT $i;
    restart_interface $i;
  
    #zrobic test przed sprawdzeniem predkosci? ethtool --test enp1s0 online
     
    SPEED_MB=$(ethtool eth0 | sed -nE "s/^\s+Speed:\s+([0-9]+)Mb\/s/\1/p");
  
    if [ $SPEED_MB -gt 9000 ]; then
      echo "Successfuly fixed the connection";
      exit 0;
    else
      echo "Restarting not successful, max available speed is $SPEED_MB";
    fi;
  done;

  echo "Failed to fix the connection";
  scontrol update nodename=$(hostname) state=fail reason="failed to start the 10GbE interface"
fi;



#snmpbulkwalk -v2c -c public 192.168.0.239 iso.3.6.1.2.1.17.7.1.2.2.1.2.1 | perl -pe ' s/SNMPv2-SMI::mib-2.17.7.1.2.2.1.2.1.//; while (/(\d+)/mg) { printf("%02x:", $1) } printf "  " '
