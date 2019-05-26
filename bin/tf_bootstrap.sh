#!/bin/bash

validate_project() { echo "$PROJECT_LIST" | grep -F -q -x "$1"; }

sed_tfvars() {
    sed -i "s/__PROJECT_NAME__/$1/" ../terraform/terraform.tfvars
}

clear

if [ -z $GOOGLE_CLOUD_PROJECT ]
then
  echo "It doesn't look like the \$GOOGLE_CLOUD_PROJECT environment variable is set"
  echo "This script is designed to run in GCP Cloud Shell"
  exit 1
fi

echo "It looks like the current GCP project is set to $GOOGLE_CLOUD_PROJECT"
read -p 'Would you like to launch the resources into this GCP project? (y/n)' -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]
then
  sed_tfvars $GOOGLE_CLOUD_PROJECT
else
  read -p "Would you like to specify a project ID here (alternatively you can switch projects in cloud shell and rerun this script)? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo -e "\nGathering available projects . . ."
    PROJECT_LIST=$(gcloud projects list | awk '{ print $1 }' | tail -n +2)
    echo "The following projects are available to your cloud shell"
    for i in $PROJECT_LIST; do
      echo $i
    done
    read -p "What is the ID of the GCP project you'd like to use?" -r project_id
    validate_project "$project_id" \
    && sed_tfvars "$project_id" \
    || (echo "That project isn't in available in this GCP account.";\
         echo "Start a new project through the GCP console, or figure out what project you want to use and try again.";\
         echo "You can return to this script by running $(pwd)/capstone/bin/tf_bootstrap.sh"; exit 1)
  fi
fi