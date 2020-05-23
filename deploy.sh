#!/bin/bash
NETWORK_NAME=nshah-network
REGION=us-west2

# Create deployment
gcloud deployment-manager deployments create nshah-deployment --config deployment.yaml

# Update deployment (if needed)
#gcloud deployment-manager deployments update nshah-deployment --config deployment.yaml

# Get K8s cluster credentials
gcloud container clusters get-credentials k8s-mz

# Setup k8s cluster pods and services
kubectl apply -f k8s.yaml
# Add authorization roles for K8S API
kubectl apply -f authz_role.yaml

# Check IP addresses of pods and services
kubectl get all -o wide

# First copy K8s credentials to local machine
./get_creds

# Let us copy the credentials over to VM in VPC
gcloud compute scp --recurse ./secrets vm-a:~/secrets --zone us-west2-a
gcloud compute scp ./get_services.sh vm-a:~ --zone us-west2-a

# Login to the VM and execute
gcloud compute ssh vm-a --zone us-west2-a --command=./get_services.sh
