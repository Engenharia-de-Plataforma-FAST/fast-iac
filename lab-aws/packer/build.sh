#!/bin/bash

# =============================================================================
# PACKER BUILD SCRIPT - FAST IAC
# =============================================================================
# 
# USAGE EXAMPLES:
#   ./build.sh                                           # Prompts for SSH key (default: ~/.ssh/id_ed25519)
#   SSH_PRIVATE_KEY=~/.ssh/my_key ./build.sh             # Custom SSH key via env var
#   IMAGE_NAME="custom-fast" ./build.sh                  # Custom image name
#   REGION=us-west-2 INSTANCE_TYPE=t3.small ./build.sh   # Custom region/instance
#   AWS_PROFILE=prod ./build.sh                          # Custom AWS profile
#   ENVIRONMENT=prod OWNER="Prod Team" ./build.sh        # Custom tags
# =============================================================================

set -e  # Exit on any error

# Default Configuration (use environment variables if set, otherwise defaults)
REGION="${REGION:-us-east-1}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t2.micro}"
SSH_USERNAME="${SSH_USERNAME:-ec2-user}"
AWS_PROFILE="${AWS_PROFILE:-batatinha}"
ANSIBLE_PLAYBOOK_PATH="${ANSIBLE_PLAYBOOK_PATH:-../ansible/main.yml}"
IMAGE_NAME="${IMAGE_NAME:-fast}"
IMAGE_DESCRIPTION="${IMAGE_DESCRIPTION:-FAST Image}"

# Tag Configuration (use environment variables if set, otherwise defaults)
ENVIRONMENT="${ENVIRONMENT:-dev}"
PROJECT_NAME="${PROJECT_NAME:-fast}"
OWNER="${OWNER:-DevOps Team}"
LAB_NAME="${LAB_NAME:-Packer}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to list available SSH keys
list_available_keys() {
    _info "Available SSH keys in ~/.ssh/:"
    echo ""
    
    # List private keys
    if ls ~/.ssh/id_* 2>/dev/null | grep -v "\.pub$" >/dev/null 2>&1; then
        _info "Private keys:"
        ls -la ~/.ssh/id_* 2>/dev/null | grep -v "\.pub$" | while read -r line; do
            echo "  $line"
        done
        echo ""
    else
        _warning "No private keys found in ~/.ssh/"
    fi
    
    # List public keys
    if ls ~/.ssh/*.pub 2>/dev/null >/dev/null 2>&1; then
        _info "Public keys:"
        ls -la ~/.ssh/*.pub 2>/dev/null | while read -r line; do
            echo "  $line"
        done
        echo ""
    else
        _warning "No public keys found in ~/.ssh/"
    fi
}

# Function to validate SSH key exists
validate_ssh_key() {
    local private_key="$1"
    local expanded_key="${private_key/#\~/$HOME}"
    
    if [ ! -f "$expanded_key" ]; then
        echo ""
        _error "Private key not found: $expanded_key"
        echo ""
        list_available_keys
        return 1
    fi
    return 0
}

# Function to get public key from private key
get_public_key() {
    local private_key="$1"
    local expanded_key="${private_key/#\~/$HOME}"
    
    # Try to get public key from corresponding .pub file
    local pub_key_file="${expanded_key}.pub"
    if [ -f "$pub_key_file" ]; then
        cat "$pub_key_file"
    else
        # Generate public key from private key
        ssh-keygen -y -f "$expanded_key" 2>/dev/null || {
            _error "Failed to extract public key from $expanded_key"
            return 1
        }
    fi
}

echo "================================="
echo "Packer Build - FAST IAC"
echo "================================="
echo ""

# Prompt for SSH private key if not provided via environment variable
if [ -z "$SSH_PRIVATE_KEY" ]; then
    echo ""
    _info "SSH Key Configuration"
    echo -n "Enter SSH private key path [~/.ssh/id_ed25519]: "
    read -r user_key
    
    if [ -z "$user_key" ]; then
        SSH_PRIVATE_KEY="~/.ssh/id_ed25519"
    else
        SSH_PRIVATE_KEY="$user_key"
    fi
else
    _info "Using SSH private key from environment: $SSH_PRIVATE_KEY"
fi

# Validate SSH key exists first
_info "Processing SSH keys..."

# Validate the SSH key exists and list available keys if not
if ! validate_ssh_key "$SSH_PRIVATE_KEY"; then
    _error "SSH key validation failed"
    exit 1
fi

# Get SSH public key (we know the key exists now)
SSH_PUBLIC_KEY=$(get_public_key "$SSH_PRIVATE_KEY")

if [ -z "$SSH_PUBLIC_KEY" ]; then
    _error "Failed to extract SSH public key from $SSH_PRIVATE_KEY"
    exit 1
fi

_info "Configuration:"
_info "  Region: $REGION"
_info "  Instance Type: $INSTANCE_TYPE"
_info "  SSH Username: $SSH_USERNAME"
_info "  AWS Profile: $AWS_PROFILE"
_info "  SSH Private Key: $SSH_PRIVATE_KEY"
_info "  Image Name: $IMAGE_NAME"
_info "  Image Description: $IMAGE_DESCRIPTION"
_info "  Ansible Playbook: $ANSIBLE_PLAYBOOK_PATH"
echo ""
_info "Tags:"
_info "  Environment: $ENVIRONMENT"
_info "  Project: $PROJECT_NAME"
_info "  Owner: $OWNER"
_info "  Lab: $LAB_NAME"
echo ""

# Initialize Packer
_info "Initializing Packer..."
packer init .

if [ $? -ne 0 ]; then
    _error "Packer init failed!"
    exit 1
fi

# Validate Configuration
_info "Validating Packer configuration..."
packer validate \
    -var="ssh_private_key_file=$SSH_PRIVATE_KEY" \
    -var="ssh_public_key=$SSH_PUBLIC_KEY" \
    -var="region=$REGION" \
    -var="instance_type=$INSTANCE_TYPE" \
    -var="ssh_username=$SSH_USERNAME" \
    -var="aws_profile_name=$AWS_PROFILE" \
    -var="ansible_playbook_path=$ANSIBLE_PLAYBOOK_PATH" \
    -var="image_name=$IMAGE_NAME" \
    -var="image_description=$IMAGE_DESCRIPTION" \
    -var="environment=$ENVIRONMENT" \
    -var="project_name=$PROJECT_NAME" \
    -var="owner=$OWNER" \
    -var="lab_name=$LAB_NAME" \
    .

if [ $? -ne 0 ]; then
    _error "Packer validation failed!"
    exit 1
fi

# Build Image
_info "Building AMI..."
packer build --force \
    -var="ssh_private_key_file=$SSH_PRIVATE_KEY" \
    -var="ssh_public_key=$SSH_PUBLIC_KEY" \
    -var="region=$REGION" \
    -var="instance_type=$INSTANCE_TYPE" \
    -var="ssh_username=$SSH_USERNAME" \
    -var="aws_profile_name=$AWS_PROFILE" \
    -var="ansible_playbook_path=$ANSIBLE_PLAYBOOK_PATH" \
    -var="image_name=$IMAGE_NAME" \
    -var="image_description=$IMAGE_DESCRIPTION" \
    -var="environment=$ENVIRONMENT" \
    -var="project_name=$PROJECT_NAME" \
    -var="owner=$OWNER" \
    -var="lab_name=$LAB_NAME" \
    .

if [ $? -eq 0 ]; then
    echo ""
    _info "AMI build completed successfully!"
    _info "Check the output above for the new AMI ID"
else
    _error "AMI build failed!"
    exit 1
fi

