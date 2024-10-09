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

# check if existing pull-secret is valid if not add the one from /opt/crc/pull-secret
existingPsB64=$(oc get secret pull-secret -n openshift-config -o jsonpath="{['data']['\.dockerconfigjson']}")
existingPs=$(echo "${existingPsB64}" | base64 -d)

echo "${existingPs}" | jq -e '.'

if [[ $? != 0 ]]; then
    pullSecretB64=$(cat /opt/crc/pull-secret)
    oc patch secret pull-secret -n openshift-config --type merge -p "{\"data\":{\".dockerconfigjson\":\"${pullSecretB64}\"}}"
fi

