#!/bin/bash
set -eo pipefail

#TODO: Consider adding an option to supress apply output if private key output is needed to access from remote state
tf_apply() {
    cd $1
    terraform init
    terraform plan -out=planned_apply $2
    read -p "Apply this plan? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      terraform apply planned_apply
    else
      echo -e "\nThere is no need to rerun the full bootstrap script. You can resume from this point by running the following script $HOME/capstone/bin/tf_apply.sh when you're ready."
    fi
}

tf_apply $HOME/capstone/terraform/service-accounts
tf_apply $HOME/capstone/terraform/storage
tf_apply $HOME/capstone/terraform/database "-var gitlab_db_pass=$(cat $HOME/.capstone_secure/db.pw)"
tf_apply $HOME/capstone/terraform/cluster

echo "Finished installing infrastructure, time to configure the cluster"
sleep 2
$HOME/capstone/bin/k8s_bootstrap.sh
