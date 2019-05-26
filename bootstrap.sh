#!/bin/bash
#
# A basic bootstrap script for setting up a google cloud shell environment

# Variables
TF_ZIP='https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip'
HELM_ZIP='https://storage.googleapis.com/kubernetes-helm/helm-v2.14.0-linux-amd64.tar.gz'
GIT_URL=''

# Set path to include home directory that will persist cloud shell sessions
cd
echo 'PATH=$HOME/bin:$PATH' >> .bashrc
. .bashrc

# Download and install the terraform binary
wget $TF_ZIP -P /tmp/
unzip /tmp/$TF_ZIP -d $HOME/bin

# Download and install the helm binary
wget $HELM_ZIP -P /tmp/
tar -C $HOME/bin xzvf /tmp/$HELM_ZIP 

# Pull bootstrap terraform code to cloud shell
git pull $GIT_URL

echo 'You have successfully installed the basic software needed for this demo.'
read -p 'Would you like to proceed to the next step?' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  ./capstone/bin/tf_bootstrap.sh
else
  echo "Stopping for now - to continue the set up process run the shell script $(pwd)/capstone/bin/tf_bootstrap.sh"
fi