#!/bin/bash

set -x

# exit early if system-mode networking
ping -c1 gateway > /dev/null 2>&1
[ $? -eq 2 ] && exit 0

export KUBECONFIG=/opt/kubeconfig

retry=0
max_retry=20
until `oc get pods > /dev/null 2>&1`
do
    [ $retry == $max_retry ] && exit 1
    sleep 5
    ((retry++))
done

oc apply -f /opt/crc/routes-controller.yaml

