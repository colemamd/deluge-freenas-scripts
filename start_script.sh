#!/usr/bin/env bash
#This script is called by OpenVPN on startup. It starts Deluge and the portforward script.

path="/usr/local/etc/openvpn"

# Wait for Deluge to startup
sleep 5

$path/port_forwarding.sh

exit 0