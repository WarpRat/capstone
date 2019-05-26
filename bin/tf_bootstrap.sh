#!/bin/bash
set -euo pipefail

validate_project() { echo "$PROJECT_LIST" | grep -F -q -x "$1"; }

sed_tfvars() {
    sed -i "s/__PROJECT_NAME__/$1/" capstone/terraform/**/terraform.tfvars
}

clear

if [ -z $GOOGLE_CLOUD_PROJECT ]
then
  echo "It doesn't look like the \$GOOGLE_CLOUD_PROJECT environment variable is set"
  echo "This script is designed to run in GCP Cloud Shell"
  exit 1
fi

echo "It looks like the current GCP project is set to $GOOGLE_CLOUD_PROJECT"
read -p "Would you like to launch the resources into this GCP project? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  sed_tfvars $GOOGLE_CLOUD_PROJECT
else
  echo
  read -p 'Would you like to specify a project ID here (alternatively you can switch projects in cloud shell and rerun this script)? (y/n) ' -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo -e "\nGathering available projects . . .\n"
    PROJECT_LIST=$(gcloud projects list | awk '{ print $1 }' | tail -n +2)
    echo "The following projects are available to your cloud shell:"
    for i in $PROJECT_LIST; do
      echo $i
    done
    read -p "What is the ID of the GCP project you'd like to use? " -r project_id
    validate_project "$project_id" \
    && sed_tfvars "$project_id" \
    || (echo "That project isn't in available in this GCP account.";\
         echo "Start a new project through the GCP console, or figure out what project you want to use and try again.";\
         echo "You can return to this script by running $(pwd)/capstone/bin/tf_bootstrap.sh"; exit 1)
  fi
fi

echo -e "\nPreparing to initialize terraform"
sleep 2
clear

# TODO: This will likely require multiple terraform applies in a specific order. Should probably pull all of this into tf_apply.sh
cd terraform
terraform init
terraform plan -out=planned_apply

echo
echo "The terraform plan above will be executed in the next step. Proceeding past this point will cost (at least a little) real money."
read -p "Are you sure you want to proceed? (y/n) " -n 1 -read

if [[ $REPLY =~ ^[Yy]$ ]]
then
  $HOME/capstone/bin/tf_apply.sh
else
  echo -e "\nThere is no need to rerun the full bootstrap script. You can resume from this point by running the following script $HOME/capstone/bin/tf_apply.sh when you're ready."
  exit 0
fi