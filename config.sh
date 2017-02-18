#!/bin/bash
# 
# Generate tinc config
#

NETNAME="overlay"
INTERFACE=overlay0
SUPERNODES=''
SUBNETS=''

read -p 'Host name: ' HOST
read -p 'Host Tinc IP: ' TINC_IP
read -p 'Host Public IP/Hostname (or blank): ' PUBLIC_IP

while : ; do
    read -p 'Connect To (or blank): ' CONNECT_TO
    [[ $CONNEC_TO ]] && SUPERNODES="$SUPERNODES $CONNECT_TO" || break
done

while : ; do
    read -p 'Subnet (or blank): ' SUBNET
    [[ $SUBNET ]] && SUBNETS="$SUBNETS $SUBNET" || break
done

mkdir -p hosts

#### Daemon Config
cat > tinc.conf << _EOF_
Forwarding = kernel
Interface = $INTERFACE

Name = $HOST

_EOF_

for S in $SUPERNODES; do
    echo "ConnectTo = $S" >> tinc.conf
done

#### Host Config
HOST_CONF=hosts/${HOST}

rm $HOST_CONF

if [ `which tinc` ]; then
    tinc -n $NETNAME generate-keys 4096
else
    tincd -n $NETNAME -K 4096
fi

echo "" >> $HOST_CONF

[[ $PUBLIC_IP ]] \
&& echo "Address = $PUBLIC_IP" >> $HOST_CONF

echo "IndirectData = yes" >> $HOST_CONF
echo "SelfIP = $TINC_IP" >> $HOST_CONF   # used by tinc-up
for S in $TINC_IP $SUBNETS ; do
    echo "Subnet = $S" >> $HOST_CONF
done

echo "******** Daemon Config ********"
cat tinc.conf
echo ""
echo "******** Host Config $HOST ********"
cat $HOST_CONF
echo ""


