#!/usr/bin/env bash
#
# Enable port forwarding when using Private Internet Access
#
# Usage:
#  ./port_forwarding.sh

path="/usr/local/etc/openvpn"

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
  echo 'Loading port forward assignment information...'
  if [ "$(uname)" == "Linux" ]; then
    client_id=`head -n 100 /dev/urandom | sha256sum | tr -d " -"`
  fi
  if [ "$(uname)" == "Darwin" ]; then
    client_id=`head -n 100 /dev/urandom | shasum -a 256 | tr -d " -"`
  fi
  if [ "$(uname)" == "FreeBSD" ]; then
    client_id=`head -n 100 /dev/urandom | shasum -a 256 | tr -d " -"`
  fi

  # Retrieve port from PIA. If valid, store in port.id for next script.
  json=`curl "http://209.222.18.222:2000/?client_id=$client_id" 2>/dev/null`
  if [ "$json" == "" ]; then
    json='Port forwarding is already activated on this connection, has expired, or you are not connected to a PIA region that supports port forwarding'
    echo $json
    exit 1
  else 
    echo $json | jq -r '.port' > $path/port.id
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

port_forward_assignment

$path/deluge_port_forward.sh

exit 0
