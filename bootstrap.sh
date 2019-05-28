#!/bin/bash
#
# A basic bootstrap script for setting up a google cloud shell environment
set -eo pipefail

# Variables
TF_VER="0.11.14"
HELM_VER="2.14.0"
TF_ZIP="https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip"
HELM_ZIP="https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VER}-linux-amd64.tar.gz"
GIT_URL="https://github.com/WarpRat/capstone"

install_tf() {
  echo "Downloading and installing terraform."
  wget $TF_ZIP -P /tmp/
  unzip -o /tmp/$(echo $TF_ZIP | awk -F'/' '{ print $6 }') -d $HOME/bin
}

install_helm() {
  echo "Downloading and installing helm"
  wget $HELM_ZIP -P /tmp/
  tar xzvf /tmp/$(echo $HELM_ZIP | awk -F'/' '{ print $5 }') -C $HOME/bin linux-amd64/helm --strip-components 1
}

# Clear the terminal and start running commands
clear

echo "Enabling all necessary GCP APIs for this project. This can take a few minutes"
# Make sure all the necessary APIs are enabled for this project
gcloud services enable container.googleapis.com \
       servicenetworking.googleapis.com \
       cloudresourcemanager.googleapis.com \
       redis.googleapis.com

# Set path to include home directory that will persist cloud shell sessions
cd
[[ -d bin ]] || mkdir bin
echo "Adding $HOME/bin to the path."
echo 'PATH=$HOME/bin:$PATH' >> .bashrc
# Enable globstar
echo 'shopt -s globstar' >> .bashrc
# Source updated bashrc
. .bashrc

# Download and install the terraform binary if it doesn't already exist or isn't up to date
if [[ -x $HOME/bin/terraform ]]
then
  TF_CUR_VER=$(terraform version | grep -o -P "(?<=Terraform v)[0-9]\.[0-9]{1,2}\.[0-9]{1,2}")
  [[ $TF_CUR_VER == $TF_VER ]] && echo "Terraform detected and up-to-date - skipping install" || install_tf
else
  install_tf
fi

# Download and install the helm binary
if [[ -x $HOME/bin/helm ]]
then
  HELM_CUR_VER=$(set +o pipefail && helm version | head -n 1 | grep -o -P "(?<=SemVer:\"v)[0-9]\.[0-9]{2}\.[0-9]{1,2}")
  [[ $HELM_CUR_VER == $HELM_VER ]] && echo "Helm detected and up-to-date - skipping install" || install_helm
else
  install_helm
fi

# Pull bootstrap terraform code to cloud shell
[[ -d capstone ]] && (cd capstone && git pull) || git clone $GIT_URL

#keep git clean by using the dev branch on my GCP project
[[ $RRENV == "test" ]] && (cd capstone && git fetch && git checkout dev && git reset --hard origin/dev)


echo 'You have successfully installed the basic software needed for this demo.'
read -p 'Would you like to proceed to the next step? ' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  ./capstone/bin/tf_bootstrap.sh
else
  echo "Stopping for now - to continue the set up process run the shell script $(pwd)/capstone/bin/tf_bootstrap.sh"
fi