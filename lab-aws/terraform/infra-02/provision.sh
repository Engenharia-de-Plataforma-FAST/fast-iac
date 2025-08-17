#!/bin/bash

# =============================================================================
# TERRAFORM PROVISION SCRIPT - FAST LAB 2
# =============================================================================
# 
# USAGE EXAMPLES:
#   ./provision.sh                                            # Use all defaults
#   OWNER="Turma 2025" ./provision.sh                         # Custom owner
#   LAB_NAME="Enterprise Lab" ./provision.sh                  # Custom lab name
#   ENVIRONMENT=prod OWNER="Prod Team" ./provision.sh         # Multiple overrides
#   INSTANCE_AMI=fast-20241029 AMI_OWNER=self ./provision.sh  # Custom AMI
#   PROFILE=myprofile BUCKET=my-bucket ./provision.sh         # Custom AWS profile/bucket
#   REGION=us-west-2 ./provision.sh                           # Different region
# =============================================================================

# Backend Configuration (use environment variables if set, otherwise defaults)
BUCKET="${BUCKET:-fast-2025-iac-lab2}"
PROFILE="${PROFILE:-batatinha}"
REGION="${REGION:-us-east-1}"
STATE_KEY="${STATE_KEY:-lab2/terraform.tfstate}"

# Default Terraform Variables (use environment variables if set, otherwise defaults)
INSTANCE_AMI="${INSTANCE_AMI:-al2023-ami*x86_64}"
AMI_OWNER="${AMI_OWNER:-amazon}"
# INSTANCE_AMI="${INSTANCE_AMI:-fast-20241029230820}"
# AMI_OWNER="${AMI_OWNER:-self}"
ENVIRONMENT="${ENVIRONMENT:-dev}"
PROJECT_NAME="${PROJECT_NAME:-fast}"
OWNER="${OWNER:-DevOps Team}"
LAB_NAME="${LAB_NAME:-Lab2}"

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

echo "================================="
echo "Terraform Provision - FAST Lab 2"
echo "================================="
echo ""

_info "Configuration:"
_info "  Backend: s3://$BUCKET/$STATE_KEY"
_info "  Region: $REGION"
_info "  Environment: $ENVIRONMENT"
_info "  Project: $PROJECT_NAME"
_info "  Owner: $OWNER"
_info "  Lab: $LAB_NAME"
_info "  AMI: $INSTANCE_AMI (owner: $AMI_OWNER)"
echo ""

# Initialize Terraform Backend
_info "Initializing Terraform..."
terraform init \
    -backend-config="bucket=$BUCKET" \
    -backend-config="profile=$PROFILE" \
    -backend-config="region=$REGION" \
    -backend-config="key=$STATE_KEY"

if [ $? -ne 0 ]; then
    _error "Terraform init failed!"
    exit 1
fi

# Validate Configuration
_info "Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    _error "Terraform validation failed!"
    exit 1
fi

# Plan Infrastructure
_info "Planning infrastructure changes..."
terraform plan \
    -var="instance_ami=$INSTANCE_AMI" \
    -var="ami_owner=$AMI_OWNER" \
    -var="environment=$ENVIRONMENT" \
    -var="project_name=$PROJECT_NAME" \
    -var="owner=$OWNER" \
    -var="lab_name=$LAB_NAME"

if [ $? -ne 0 ]; then
    _error "Terraform plan failed!"
    exit 1
fi

# Apply Infrastructure
_info "Applying infrastructure..."
terraform apply \
    -var="instance_ami=$INSTANCE_AMI" \
    -var="ami_owner=$AMI_OWNER" \
    -var="environment=$ENVIRONMENT" \
    -var="project_name=$PROJECT_NAME" \
    -var="owner=$OWNER" \
    -var="lab_name=$LAB_NAME"

if [ $? -eq 0 ]; then
    echo ""
    _info "Infrastructure deployed successfully!"
    _info "Use 'terraform output' to see connection details"
else
    _error "Deployment failed!"
    exit 1
fi
