#!/usr/bin/env bash
#This script is called by OpenVPN on startup. It starts Deluge and the portforward script.

path="/usr/local/etc/openvpn"

service deluged start

# Wait for Deluge to startup
sleep 5

$path/deluge_port_forward.sh &

exit 0