#!/bin/bash

INTERFACE="enp1s0";
RESTART_TIME=10;
SETUP_TIME=15;
SWITCH_ADDR="192.168.0.239";
REQ_MIN_SPEED=9000;

sleep_for() { # $1=ilosc sekund
  for ((i=1; i<=$1; i++));
  do
      echo -n ".";
      sleep 1;
  done
  
  echo -ne "\r\033[K"
}

restart_switch_port(){ # $1 = numer portu na switchu; $2 = licznik prob
  echo "Restarting switch port... ($2/3)";
  snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv $SWITCH_ADDR ifAdminStatus.$1 i 0;
  sleep_for $RESTART_TIME;
  snmpset -v3 -uadmin -aSHA -Aswitch10G -xDES -Xswitch10G -l authPriv $SWITCH_ADDR ifAdminStatus.$1 i 1;
  sleep_for $SETUP_TIME;
}

restart_interface(){ # $1=licznik prob
  echo "Restarting interface... ($1/3)";
  ip link set dev $INTERFACE down;
  sleep_for $RESTART_TIME;
  ip link set dev $INTERFACE up;
  sleep_for $SETUP_TIME;
}

check_speed(){
  SPEED_MB=$(ethtool $INTERFACE | sed -nE "s/^\s+Speed:\s+([0-9]+)Mb\/s/\1/p");
  
  if [ $SPEED_MB -gt $REQ_MIN_SPEED ]; then
    echo "You're good to go!";
    exit 0;
  else
    echo "Fail! Max available speed is $SPEED_MB";
  fi;
}

if test -f /sys/class/net/$INTERFACE/operstate && grep -q 'up' /sys/class/net/$INTERFACE/operstate; 
then
  echo "Interface 10GbE ($INTERFACE) is up. Checking speed...";
  check_speed;
else
  echo "Interface 10GbE ($INTERFACE) is down. Attempting to fix...";
  #test połączenia po kablu? ethtool --cable-test

  PORT=$(cat /etc/ports | sed -nE "s/(^[^#]+)\s+$(hostname)/\1/p");

  for j in {1..3}
  do
    restart_switch_port $PORT $j;
    restart_interface $j;
  
    #zrobic test przed sprawdzeniem predkosci? ethtool --test enp1s0 online
    check_speed;
  done;
fi;

echo "The interface $INTERFACE does not function properly! Removing the node from the pool...";
scontrol update nodename=$(hostname) state=fail reason="failed to start the 10GbE interface"


#snmpbulkwalk -v2c -c public 192.168.0.239 iso.3.6.1.2.1.17.7.1.2.2.1.2.1 | perl -pe ' s/SNMPv2-SMI::mib-2.17.7.1.2.2.1.2.1.//; while (/(\d+)/mg) { printf("%02x:", $1) } printf "  " '
