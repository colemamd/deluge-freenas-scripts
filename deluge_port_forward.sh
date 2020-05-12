#!/usr/bin/env bash
#
# Enable port forwarding when using Private Internet Access
#
# Usage:
#  ./deluge_port_forward.sh

path="/usr/local/etc/openvpn"
logfile="/media/VPN.log"
cred="$path/deluge.credentials"
addr="$(ifconfig tun2 | awk '/inet/ {print $2}')"

error( )
{
  echo "$@" 1>&2
  exit 1
}

error_and_usage( )
{
  echo "$@" 1>&2
  usage_and_exit 1
}

usage( )
{
  echo "Usage: `dirname $0`/$PROGRAM"
}

usage_and_exit( )
{
  usage
  exit $1
}

version( )
{
  echo "$PROGRAM version $VERSION"
}

port_forward_assignment( )
{
  echo "Loading port forward assignment information..."
  if [ ! -f "$path/.pia_client_id" ]; then
    if `hash sha256sum` 2>/dev/null; then
      client_id=`head -n 100 /dev/urandom | sha256sum | tr -d " -"` > "$path/.pia_client_id"
    elif `hash` shasum 2>/dev/null; then
      client_id=`head -n 100 /dev/urandom | shasum -a 256 | tr -d " -"` > "$path/.pia_client_id"
    else
      echo "Please install shasum or sha256sum, and make sure it is visible in your \$PATH"
    fi
  fi
  pia_client_id=`cat $path/.pia_client_id`
  json=`curl "http://209.222.18.222:2000/?client_id=$pia_client_id" 2>/dev/null`
  if [ "$json" == "" ]; then
    json="Port forwarding is already activated on this connection, has expired, or you are not connected to a PIA region that supports port forwarding"
    port="$(cat $path/port.id)"
  else
    port="$(echo $json | jq -r '.port')" > port.id
  fi

  # Set the port in Deluge
  user=$(sed -n 1p $cred)
  pass=$(sed -n 2p $cred)
  if deluge-console "connect localhost:58846 $user $pass; config [-s listen_ports $port $port] [outgoing_interface $addr]"; then
    echo $(date) "Deluge port set to $port and outgoing interface to $addr" >> $logfile
  else
    echo "Deluge failed to connect, exiting..."
    exit 1
  fi
}

EXITCODE=0
PROGRAM=`basename $0`
VERSION=2.1

while test $# -gt 0
do
  case $1 in
  --usage | --help | -h )
    usage_and_exit 0
    ;;
  --version | -v )
    version
    exit 0
    ;;
  *)
    error_and_usage "Unrecognized option: $1"
    ;;
  esac
  shift
done

sleep 10
port_forward_assignment

exit 0
