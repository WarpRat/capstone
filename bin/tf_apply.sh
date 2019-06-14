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

sleep 3
clear
echo "Do you own a domain name that you'd like to use for this gitlab server?"
echo "This is not required, however the certificate mananger will be unable to issue a valid certificate otherwise."
echo "You can still create the cluster and install gitlab, however the Kubernetes gitlab runner will not register properly."
echo "It is highly recommended that you use a proper domain name."
read -p "Would you like you enter your domain name now? (y/n) " -n 1 -r

if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo
  echo "Gitlab will automatically add subdomains for gitlab and registry,"
  echo "using an unused domain or unused subdomain will allow DNS to be configured with a wildcard."
  read -p "What is the domain name you'd like to use? " domain_name
  echo
  echo "Thanks! Now is a good time to set up DNS records for gitlab.${domain_name} and registry.${domain_name}."
  echo "Alternatively a wildcard DNS record for *.${domain_name} works as well."
  cd
  sed -i "s/__INGRESS_IP__.xip.io/${domain_name}/" capstone/helm/values/gitlab_values.yaml
  read -p "Press any key when you're ready to continue. Setting DNS up now will allow it to propagate while the cluster is provisioned." -n 1 -r
else
  echo
  echo "No problem. See the README for an explanation of the limitations of not using a domain name."
  read -p "Press any key to continue." -n 1 -r
fi


tf_apply $HOME/capstone/terraform/cluster

echo
echo "Finished installing infrastructure, time to configure the cluster"
sleep 2
$HOME/capstone/bin/k8s_bootstrap.sh
