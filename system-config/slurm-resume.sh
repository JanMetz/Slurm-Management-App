#!/bin/bash
CONF_FILE="auth.meshcentral";
PASSWD=$(cat "$CONF_FILE" | sed -nE "s/(^[^#]+)\s+passwd/\1/p");
USER=$(cat "$CONF_FILE" | sed -nE "s/(^[^#]+)\s+user/\1/p");
URL=$(cat "$CONF_FILE" | sed -nE "s/(^[^#]+)\s+url/\1/p");

for node in $@;
do
  echo "Pinging ${node}..."
  DEV_ID=$(cat abc | sed -nE "s/(^[^#]+)\s+$node/\1/p");

  if ping -c1 $node > /dev/null 2>&1; #ping once and redirect stdout and stderr to /dev/null
  then #if ping was successful
    node meshctrl.js DevicePower --amtoff --url $URL --loginuser $USER --loginpass $PASSWD --id $DEV_ID
    #pxe na wlasciwy system
  else #if machine could not be pinged
    #pxe na wlasciwy system
  fi;
done;

exit 0
