#!/bin/bash

set -euo pipefail

# A terraform cleanup script for dev work
find $HOME/capstone/ -type d -name '.terraform' -execdir terraform destroy -auto-approve \;