#!/bin/bash
set -euo pipefail

# sed function to make things easier
sed_values() {
    sed -i "s/$1/$2/g" capstone/helm/values/gitlab_values.yaml
}

# Set up the tiller RBAC service account and binding outside of configuration management since tiller is
# needed for helm to do kubernetes configuration management.
echo "Setting up kubectl to use the new cluster"
gcloud container clusters get-credentials capstone-project-cluster --region=$(gcloud container clusters list | grep capstone-project-cluster | awk '{ print $2 }')

# Use bash exit codes to avoid failing on a second run
kubectl create serviceaccount tiller --namespace kube-system && \
  kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin --serviceaccount=kube-system:tiller && \
  helm init --service-account=tiller && \
  echo "Tiller service acocunt installed" && \
  sleep 30 || \
  echo "Tiller appears to have been installed already on this cluster. Moving on."

helm repo add gitlab https://charts.gitlab.io/
helm repo update

echo "Checking that helm is properly initialized"
helm version > /dev/null 2>&1 && echo "Helm appears to have initialized inside your cluster properly." \
                              || echo "Something appears to have gone wrong with helm. Please try again."

cp ~/.capstone_secure/gcs-key.json ~/capstone/helm/charts/secrets/
cat > ~/capstone/helm/charts/secrets/rails.yaml <<EOF
provider: Google
google_project: ${GOOGLE_CLOUD_PROJECT}
google_client_email: gitlab-storage-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
google_json_key_strin: $(cat ~/.capstone_secure/gcs-key.json)
EOF

helm upgrade gitlab-ns ~/capstone/helm/charts/common --install
helm upgrade gitlab-pg ~/capstone/helm/charts/secrets -f ~/capstone/helm/charts/secrets/values/gitlab-pg.yaml --install --set seclit.password=$(cat ~/.capstone_secure/db.pw) --namespace gitlab
helm upgrade google-application-credentials ~/capstone/helm/charts/secrets -f ~/capstone/helm/charts/secrets/values/storage-creds.yaml --install --set fileLit.gcs-application-credentials-file=gcs-key.json --namespace gitlab
helm upgrade gitlab-rails-storage ~/capstone/helm/charts/secrets -f ~/capstone/helm/charts/secrets/values/rails.yaml --install --namespace gitlab \
                                                    --set fileLit.connection=rails.yaml
rm ~/capstone/helm/charts/secrets/gcs-key.json ~/capstone/helm/charts/secrets/rails.yaml

# Set environment variables for everything we need to sed into the gitlab values.yaml
export GITLAB_INGRESS=$(gcloud compute addresses describe gitlab --region us-west1 --format 'value(address)')
export DB_NAME=$(gcloud compute project-info describe --format 'value(commonInstanceMetadata[db_name])')
export DB_IP=$(gcloud sql instances describe ${DB_NAME} --format 'value(ipAddresses[0].ipAddress)')
export REDIS_IP=$(gcloud redis instances describe gitlab --region=us-west1 --format 'value(host)')
export USER_EMAIL=$(gcloud config get-value account 2> /dev/null)
sed_values '__DB_IP__' ${DB_IP}
sed_values '__REDIS_IP__' ${REDIS_IP}
sed_values '__CERT_MANAGER_EMAIL__' ${USER_EMAIL}
sed_values '__INGRESS_IP__' ${GITLAB_INGRESS}

helm install --name gitlab -f capstone/helm/values/gitlab_values.yaml --version 1.7.1 --namespace gitlab gitlab/gitlab

export GITLAB_HOSTNAME=$(kubectl get ingresses.extensions gitlab-unicorn -n gitlab -o jsonpath='{.spec.rules[0].host}')
echo "Your GitLab URL is: https://${GITLAB_HOSTNAME}"

echo "You can log in to your instance and start using it with the username root and the following password:"
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o go-template='{{.data.password}}' | base64 -d && echo

echo "Please save this password somewhere and set up a less privileged user for daily tasks."