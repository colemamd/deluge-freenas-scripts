#!/usr/bin/env bash
#
# Assign PIA assigned port forward to Deluge
#

path="/usr/local/etc/openvpn"
logfile="$path/VPN.log"
cred="$path/deluge.credentials"
intf="tun0"
addr="$(ifconfig $intf | awk '/inet/ {print $2}')"

# Set the port in Deluge
user=$(sed -n 1p $cred)
pass=$(sed -n 2p $cred)
port=$(cat $path/port.id)

if deluge-console "connect localhost:58846 $user $pass; config -s listen_ports ($port $port); config -s listen_interface '$addr'; config -s outgoing_interface '$addr'"; then
  echo $(date) "Deluge port set to $port" >> $logfile
else
  echo "Deluge failed to connect, exiting..."
  exit 1
fi

exit 0
