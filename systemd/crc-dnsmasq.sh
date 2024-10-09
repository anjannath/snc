#!/bin/bash

set -x

# exit early if user-mode networking
ping -c1 gateway > /dev/null 2>&1
[ $? -eq 0 ] && exit 0

hostName=$(hostname)
ip=$(ip -4 addr show br-ex | grep -oP '(?<=inet\s)192+(\.\d+){3}')
iip=$(hostname -i)

cat << EOF > /etc/dnsmasq.d/crc-dnsmasq.conf
listen-address=$ip
expand-hosts
log-queries
local=/crc.testing/
domain=crc.testing
address=/apps-crc.testing/$ip
address=/api.crc.testing/$ip
address=/api-int.crc.testing/$ip
address=/$hostName.crc.testing/$iip
EOF

