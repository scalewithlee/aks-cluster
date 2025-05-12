#!/usr/bin/env bash
# Bootstrap script for setting up Azure storage for Terraform state

set -e

# Variables
RESOURCE_GROUP_NAME="terraform-state-rg"
# Generate a valid storage account name (lowercase letters and numbers only)
STORAGE_ACCOUNT_NAME="tfstate$(date +%s | md5sum | head -c 8 | tr '[:upper:]' '[:lower:]')"
CONTAINER_NAME="tfstate"
LOCATION="eastus"

echo "=== Azure Terraform State Bootstrap ==="
echo "This script will create:"
echo "  - Resource Group: $RESOURCE_GROUP_NAME"
echo "  - Storage Account: $STORAGE_ACCOUNT_NAME (generated unique name)"
echo "  - Storage Container: $CONTAINER_NAME"
echo "  - Location: $LOCATION"
echo ""

# Verify Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "ERROR: Azure CLI is not installed. Please install it first."
    exit 1
fi

# Verify login status
echo "Verifying Azure CLI login status..."
if ! az account show &> /dev/null; then
    echo "You're not logged in to Azure. Please login first."
    az login
fi

# Display current subscription
SUBSCRIPTION=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION ($SUBSCRIPTION_ID)"
echo ""

# Ensure the Storage provider is registered
echo "Ensuring Microsoft.Storage provider is registered..."
az provider register --namespace Microsoft.Storage --wait

# Create resource group with retries
echo "Creating resource group $RESOURCE_GROUP_NAME..."
MAX_RETRIES=3
for (( i=1; i<=$MAX_RETRIES; i++ )); do
    if az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --output none; then
        echo "✓ Resource group created successfully."
        break
    else
        if [ $i -eq $MAX_RETRIES ]; then
            echo "ERROR: Failed to create resource group after $MAX_RETRIES attempts."
            exit 1
        fi
        echo "Retrying resource group creation (attempt $i of $MAX_RETRIES)..."
        sleep 5
    fi
done

# Create storage account with retries
echo "Creating storage account $STORAGE_ACCOUNT_NAME..."
for (( i=1; i<=$MAX_RETRIES; i++ )); do
    if az storage account create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$STORAGE_ACCOUNT_NAME" \
        --sku Standard_LRS \
        --encryption-services blob \
        --https-only true \
        --min-tls-version TLS1_2 \
        --output none; then
        echo "✓ Storage account created successfully."
        break
    else
        if [ $i -eq $MAX_RETRIES ]; then
            echo "ERROR: Failed to create storage account after $MAX_RETRIES attempts."
            exit 1
        fi
        echo "Retrying storage account creation (attempt $i of $MAX_RETRIES)..."
        sleep 10
    fi
done

# Wait for storage account to be fully provisioned
echo "Waiting for storage account to be fully provisioned..."
sleep 10

# Get storage account key with retries
echo "Getting storage account key..."
for (( i=1; i<=$MAX_RETRIES; i++ )); do
    ACCOUNT_KEY=$(az storage account keys list \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --query '[0].value' \
        -o tsv)

    if [ -n "$ACCOUNT_KEY" ]; then
        echo "✓ Storage account key retrieved successfully."
        break
    else
        if [ $i -eq $MAX_RETRIES ]; then
            echo "ERROR: Failed to get storage account key after $MAX_RETRIES attempts."
            exit 1
        fi
        echo "Retrying key retrieval (attempt $i of $MAX_RETRIES)..."
        sleep 5
    fi
done

# Create blob container with retries
echo "Creating blob container $CONTAINER_NAME..."
for (( i=1; i<=$MAX_RETRIES; i++ )); do
    if az storage container create \
        --name "$CONTAINER_NAME" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --account-key "$ACCOUNT_KEY" \
        --output none; then
        echo "✓ Storage container created successfully."
        break
    else
        if [ $i -eq $MAX_RETRIES ]; then
            echo "ERROR: Failed to create storage container after $MAX_RETRIES attempts."
            exit 1
        fi
        echo "Retrying container creation (attempt $i of $MAX_RETRIES)..."
        sleep 5
    fi
done

# Generate backend.tf file
BACKEND_FILE="infrastructure/terraform/environments/dev/backend.tf"
echo "Generating backend configuration file at $BACKEND_FILE..."

mkdir -p $(dirname "$BACKEND_FILE")

cat > "$BACKEND_FILE" << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP_NAME"
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "dev.terraform.tfstate"
  }
}
EOF

echo "✓ Backend configuration file created successfully."
echo ""
echo "=========== BOOTSTRAP COMPLETE ==========="
echo "Terraform backend is configured to use:"
echo "  Resource Group:  $RESOURCE_GROUP_NAME"
echo "  Storage Account: $STORAGE_ACCOUNT_NAME"
echo "  Container:       $CONTAINER_NAME"
echo "  State Key:       dev.terraform.tfstate"
echo ""
echo "The backend.tf file has been created at:"
echo "$BACKEND_FILE"
echo "=========================================="
