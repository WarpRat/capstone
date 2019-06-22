#!/bin/bash

set -euo pipefail

# A terraform cleanup script for dev work
find $HOME/capstone/ -type d -name '.terraform' -execdir tf11 destroy -auto-approve -var gitlab_db_pass=$(cat $HOME/.capstone_secure/db.pw)\;
echo "Running it again to clean up lingering resources."
find $HOME/capstone/ -type d -name '.terraform' -execdir tf11 destroy -auto-approve -var gitlab_db_pass=$(cat $HOME/.capstone_secure/db.pw)\;