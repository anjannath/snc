#!/bin/bash

set -x

export KUBECONFIG="/opt/kubeconfig"

retry=0
max_retry=20
until `oc get secret > /dev/null 2>&1`
do
    [ $retry == $max_retry ] && exit 1
    sleep 5
    ((retry++))
done

PASS_DEVELOPER=$(cat /opt/crc/pass_developer)
PASS_KUBEADMIN=$(cat /opt/crc/pass_kubeadmin)

podman run --rm -ti xmartlabs/htpasswd developer $PASS_DEVELOPER > /tmp/htpasswd.developer
podman run --rm -ti xmartlabs/htpasswd kubeadmin $PASS_KUBEADMIN > /tmp/htpasswd.kubeadmin

cat /tmp/htpasswd.developer > /tmp/htpasswd.txt
cat /tmp/htpasswd.kubeadmin >> /tmp/htpasswd.txt
sed -i '/^\s*$/d' /tmp/htpasswd.txt

oc create secret generic htpass-secret  --from-file=htpasswd=/tmp/htpasswd.txt -n openshift-config --dry-run=client -o yaml > /tmp/htpass-secret.yaml
oc replace -f /tmp/htpass-secret.yaml

rm -rf /opt/crc/pass_developer /opt/crc/pass_kubeadmin
