#!/usr/bin/env bash
# Checks to see if VPN is up. Restarts VPN if necessary and runs port forward script.
# Added as a cron job to run periodically.

intf="tun0"
path="/usr/local/etc/openvpn"
logfile="$path/VPN.log"

check=$(ifconfig $intf 2>&1 | awk '/does not exist/ {f=1}; BEGIN{f=0}; END{print f}')

# If we got a 1, then it should be restarted.
if [ "check" == "1" ]; then
    echo $(date) "VPN down. Restarting VPN..." >> $logfile
    service openvpn start
fi
