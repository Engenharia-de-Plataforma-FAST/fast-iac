#!/bin/bash

# Default values (use environment variables if set)
DEFAULT_BUCKET_NAME="${BUCKET:-fast-2025-iac-lab4}"
DEFAULT_REGION="${REGION:-us-east-1}"
DEFAULT_PROFILE="${PROFILE:-default}"

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

echo "==================================="
echo "Bootstrap Terraform Backend S3"
echo "==================================="
echo ""

# Request bucket name
echo -n "Enter S3 bucket name (default: $DEFAULT_BUCKET_NAME): "
read BUCKET_NAME
BUCKET_NAME=${BUCKET_NAME:-$DEFAULT_BUCKET_NAME}

# Request region
echo -n "Enter AWS region (default: $DEFAULT_REGION): "
read REGION
REGION=${REGION:-$DEFAULT_REGION}

# Request AWS profile
echo -n "Enter AWS profile to use (default: $DEFAULT_PROFILE): "
read AWS_PROFILE
AWS_PROFILE=${AWS_PROFILE:-$DEFAULT_PROFILE}

# Verify profile exists
if ! aws configure list --profile "$AWS_PROFILE" &>/dev/null; then
    _error "Profile '$AWS_PROFILE' not found!"
    echo "Available profiles:"
    aws configure list-profiles
    exit 1
fi

echo ""
_info "Checking if bucket $BUCKET_NAME exists..."

# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" --profile "$AWS_PROFILE" --no-cli-pager 2>/dev/null; then
    _info "Bucket $BUCKET_NAME already exists. Nothing to do."
    exit 0
else
    _info "Bucket does not exist. Creating..."

    # Create bucket
    if [ "$REGION" = "us-east-1" ]; then
        # For us-east-1, no need to specify LocationConstraint
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --profile "$AWS_PROFILE" \
            --acl private \
            --no-cli-pager > /dev/null
    else
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --profile "$AWS_PROFILE" \
            --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION" \
            --acl private \
            --no-cli-pager > /dev/null
    fi

    if [ $? -eq 0 ]; then
        echo ""

        # Block public access
        _info "Configuring public access block..."
        aws s3api put-public-access-block \
            --bucket "$BUCKET_NAME" \
            --profile "$AWS_PROFILE" \
            --public-access-block-configuration \
                "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
            --no-cli-pager

        # Enable versioning
        _info "Enabling versioning..."
        aws s3api put-bucket-versioning \
            --bucket "$BUCKET_NAME" \
            --profile "$AWS_PROFILE" \
            --versioning-configuration Status=Enabled \
            --no-cli-pager

        echo ""
        _info "Bucket $BUCKET_NAME created successfully!"
        echo ""
        _info "Terraform backend configuration:"
        echo "----------------------------------------"
        echo "backend \"s3\" {"
        echo "  bucket  = \"$BUCKET_NAME\""
        echo "  key     = \"terraform.tfstate\""
        echo "  region  = \"$REGION\""
        echo "  profile = \"$AWS_PROFILE\""
        echo "}"
        echo "----------------------------------------"
    else
        _error "Failed to create bucket!"
        exit 1
    fi
fi