#!/bin/bash
# Gets K8S credentials locally
K8S_CREDS=secrets
mkdir -p ${K8S_CREDS}

# Check all possible clusters, as your .KUBECONFIG may have multiple contexts:
kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

# Select the first cluster (change for your own environment)
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')
echo "Using cluster ${CLUSTER_NAME}"

# Point to the API server referring the cluster name
APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")
echo ${APISERVER} > ${K8S_CREDS}/apiserver

# Gets the token value
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo ${TOKEN} > ${K8S_CREDS}/token

# Get the certificate
FIRST_POD=$(kubectl get pod -o jsonpath="{.items[0].metadata.name}")
# Tar called from inside kubectl gives a warning, hide the message
kubectl cp ${FIRST_POD}:/var/run/secrets/kubernetes.io/serviceaccount/..data/ca.crt ${K8S_CREDS}/ca.crt > /dev/null
