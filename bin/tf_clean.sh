#!/bin/bash

set -euo pipefail

# A terraform cleanup script for dev work
find $HOME/capstone/ -type d -name '.terraform' -execdir terraform destroy -auto-approve \;
echo "Running it again to clean up lingering resources."
find $HOME/capstone/ -type d -name '.terraform' -execdir terraform destroy -auto-approve \;