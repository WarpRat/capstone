#!/bin/bash
set -euo pipefail

#TODO: Consider adding an option to supress apply output if private key output is needed to access from remote state
tf_apply() {
    cd $1
    terraform plan -out=planned_apply
    read -p "Apply this plan?"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      terraform apply planned_apply
    else
      echo -e "\nThere is no need to rerun the full bootstrap script. You can resume from this point by running the following script $HOME/capstone/bin/tf_apply.sh when you're ready."
    fi
}

