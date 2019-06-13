#!/bin/bash
set -euo pipefail

# Set up the tiller RBAC service account and binding outside of configuration management since tiller is
# needed for helm to do kubernetes configuration management.
echo "Setting up kubectl to use the new cluster"
gcloud container clusters get-credentials capstone-project-cluster --region=$(gcloud container clusters list | grep capstone-project-cluster | awk '{ print $2 }')
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

if [[ helm init --service-account=tiller ]]
then
  echo "Tiller service acocunt installed"
else
  echo "Tiller appears to have been installed already on this cluster. Moving on."
fi

helm repo update

sleep 2
echo "Checking that helm is properly initialized"
helm version > /dev/null 2>&1 && echo "Helm appears to have initialized inside your cluster properly." \
                              || echo "Something appears to have gone wrong with helm. Please try again."

helm upgrade capstone ./capstone/helm/charts/common --install
helm upgrade gitlab-pg ./capstone/helm/charts/secrets -f ./capstone/helm/charts/secrets/values/gitlab-pg.yaml --install --set seclit.password=$(cat .capstone_secure/db.pw)
helm upgrade google-application-credentials ./capstone/helm/charts/secrets -f ./capstone/helm/charts/secrets/values/storage-creds.yaml --install --set seclit.gcs-application-credentials-file=$(cat .capstone_secure/gcs-key.json)
PROJECT_ID=$(gcloud config get-value project) helm upgrade gitlab-rails-storage ./capstone/helm/charts/secrets -f ./capstone/helm/charts/secrets/values/rails.yaml --install \
                                                    --set seclit.connection.google_project=${PROJECT_ID} \
                                                    --set seclit.connection.google_client_email=gitlab-storage-sa@${PROJECT_ID}.iam.gserviceaccount.com \
                                                    --set seclit.connection.google_json_key_string=$(cat .capstone_secure/gcs-key.json)
