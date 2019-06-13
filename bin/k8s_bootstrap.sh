#!/bin/bash
set -euo pipefail

# Set up the tiller RBAC service account and binding outside of configuration management since tiller is
# needed for helm to do kubernetes configuration management.
echo "Setting up kubectl to use the new cluster"
gcloud container clusters get-credentials capstone-project-cluster --region=$(gcloud container clusters list | grep capstone-project-cluster | awk '{ print $2 }')

# Use bash exit codes to avoid failing on a second run
kubectl create serviceaccount tiller --namespace kube-system && \
  kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller && \
  helm init --service-account=tiller && \
  echo "Tiller service acocunt installed" || \
  echo "Tiller appears to have been installed already on this cluster. Moving on."

helm repo update

sleep 2
echo "Checking that helm is properly initialized"
helm version > /dev/null 2>&1 && echo "Helm appears to have initialized inside your cluster properly." \
                              || echo "Something appears to have gone wrong with helm. Please try again."

cp .capstone_secure/gcs-key.json ./capstone/helm/charts/secrets
helm upgrade gitlab-ns ./capstone/helm/charts/common --install
helm upgrade gitlab-pg ./capstone/helm/charts/secrets -f ./capstone/helm/charts/secrets/values/gitlab-pg.yaml --install --set seclit.password=$(cat .capstone_secure/db.pw) --namespace gitlab
helm upgrade google-application-credentials ./capstone/helm/charts/secrets -f ./capstone/helm/charts/secrets/values/storage-creds.yaml --install --set fileLit.gcs-application-credentials-file=gcs-key.json --namespace gitlab
helm upgrade gitlab-rails-storage ./capstone/helm/charts/secrets -f ./capstone/helm/charts/secrets/values/rails.yaml --install --namespace gitlab \
                                                    --set seclit.google_project=${GOOGLE_CLOUD_PROJECT} \
                                                    --set seclit.google_client_email=gitlab-storage-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
                                                    --set fileLit.google_json_key_string=gcs-key.json \
                                                    --set extrakey=connection
rm ./capstone/helm/charts/secrets/gcs-key.json
