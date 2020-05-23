#!/bin/bash

# K8S credentials file
K8S_CREDS=secrets

APISERVER=$(cat ${K8S_CREDS}/apiserver)
TOKEN=$(cat ${K8S_CREDS}/token)

# Explore the API with TOKEN
# curl --header "Authorization: Bearer ${TOKEN}" --insecure \
#     -X GET ${APISERVER}/api 

curl --silent --cacert ${K8S_CREDS}/ca.crt --header "Authorization: Bearer ${TOKEN}" \
    -X GET ${APISERVER}/api/v1/namespaces/default/endpoints/headless-service

echo ""
echo "Hostname: ${HOSTNAME}"

IP_LIST=$(curl --silent --cacert ${K8S_CREDS}/ca.crt --header "Authorization: Bearer ${TOKEN}" \
    -X GET ${APISERVER}/api/v1/namespaces/default/endpoints/headless-service \
    | grep ip)

echo "Headless Service is on these IPs:"
echo ${IP_LIST}

IP=$(echo ${IP_LIST} | awk '{print $3}' FS='[ ,":]*')
echo "Picked an IP: ${IP}"
curl ${IP}
