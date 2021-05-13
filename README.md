# Firewall blacklist #

Simple script which uses FireHOL's (https://iplists.firehol.org) list of bad IPs and generate iptables firewall.

## Schedule ##
It's good to run it once per day to refresh the firewall. Have something like this in crontab:
```
0 3 * * * /root/fw-blacklist.sh >> /var/log/fw-blacklist.log
```
Full refresh might take few minutes depending of the PC speed and the size of the list.

## Notes ##

Maybe it's good to include blocking outbound connections too. That would prevent possible communication to known botnet command & control servers.
