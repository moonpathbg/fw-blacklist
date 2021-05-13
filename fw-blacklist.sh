#!/bin/bash

# Path to iptables.
IPTABLES="/sbin/iptables";

# List of known bad IPs.
URL="https://iplists.firehol.org/files/firehol_level1.netset";

# Temp storage
FILE="/tmp/fw-blacklist.txt";

# Chain containing all the bad ips and subnets.
CHAIN="BLACKLIST";

# Download the list of bad IPs. If download fails exit and do nothing.
wget -qc $URL -O $FILE
if [ $? -ne 0 ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') Download failed!"
  exit 1
fi;
echo "$(date '+%Y-%m-%d %H:%M:%S') Download success."

# Flush the chain if it's already there, and if not, create it and send traffic to it.
$IPTABLES -L $CHAIN -n
if [ $? -eq 0 ]; then
  $IPTABLES -F $CHAIN
else
  $IPTABLES -N $CHAIN
  $IPTABLES -I INPUT -j $CHAIN
  $IPTABLES -I FORWARD -j $CHAIN
fi;

# Walk through the list of IPs. We're escaping 127* subnet as this will break some local communication. 
# If required, private subnet exceptions should be inserted here by chaining another "egrep -v ..."
# Matching bad IP will generate log entry. The limit makes sure the log does not explode with block events
# by allowing only 1 log entry per minute after the first burst of 10..
for IP in $( cat $FILE | egrep -v '^;' | egrep -v '^#' | egrep -v '^127' | awk '{ print $1}' ); do
  $IPTABLES -A $CHAIN -s $IP -j LOG --log-prefix "[BLACKLIST DROP]" -m limit --limit 1/min --limit-burst 10
  $IPTABLES -A $CHAIN -s $IP -j DROP
done

# Delete temp storage file.
unlink $FILE
echo "$(date '+%Y-%m-%d %H:%M:%S') Iptables rules installed."
