#!/bin/bash
set -euo pipefail

# Make sure we're in the right directory
cd $HOME/capstone/terraform/

# Make sure our plan is still there
[[ -f planned_apply ]] || terraform plan -out=planned_apply

terraform apply planned_apply
