#!/bin/bash
set -euo pipefail

# Set up the tiller RBAC service account and binding outside of configuration management since tiller is
# needed for helm to do kubernetes configuration management.
echo "Setting up kubectl to use the new cluster"
glcoud container clusters get-credentials capstone-project-cluster --region=$(gcloud container clusters list | grep capstone-project-cluster | awk '{ print $2 }')
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

helm init --service-account=tiller
helm update

echo "Checking that helm is properly initialized"
helm version > /dev/null 2>&1 && echo "Helm appears to have initialized inside your cluster properly." \
                              || echo "Something appears to have gone wrong with helm. Please try again."
