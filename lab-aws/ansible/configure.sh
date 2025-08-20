#!/bin/bash

# =============================================================================
# ANSIBLE CONFIGURATION SCRIPT - FAST IAC LAB
# =============================================================================

set -e

# Check if running from ansible directory
if [ ! -f "main.yml" ] || [ ! -f "inventory.ini" ]; then
    echo "ERROR: This script must be run from the ansible directory"
    exit 1
fi

# Install required collections
echo "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

# Run Ansible playbook
ansible-playbook -i inventory.ini main.yml