#!/bin/bash

# CardAI MCP Server - Deployment Script
set -e

# Configuration
RESOURCE_GROUP_NAME="cardai-mcp-dev"
LOCATION="East US"
TEMPLATE_FILE="infra/main.bicep"
PARAMETERS_FILE="infra/dev.parameters.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        log_error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 20.x."
        exit 1
    fi
    
    # Check Node.js version
    NODE_VERSION=$(node -v | cut -d'.' -f1 | cut -d'v' -f2)
    if [ "$NODE_VERSION" -lt 20 ]; then
        log_error "Node.js version must be 20 or higher. Current version: $(node -v)"
        exit 1
    fi
    
    log_info "All prerequisites satisfied."
}

# Deploy infrastructure
deploy_infrastructure() {
    log_info "Deploying Azure infrastructure..."
    
    # Create resource group if it doesn't exist
    log_info "Creating resource group: $RESOURCE_GROUP_NAME"
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION" --output table
    
    # Deploy Bicep template
    log_info "Deploying Bicep template..."
    az deployment group create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --template-file "$TEMPLATE_FILE" \
        --parameters "$PARAMETERS_FILE" \
        --output table
        
    log_info "Infrastructure deployment completed."
}

# Get deployment outputs
get_deployment_outputs() {
    log_info "Retrieving deployment outputs..."
    
    OUTPUTS=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name main \
        --query properties.outputs \
        --output json)
    
    APP_SERVICE_NAME=$(echo "$OUTPUTS" | jq -r '.appServiceName.value')
    KEY_VAULT_NAME=$(echo "$OUTPUTS" | jq -r '.keyVaultName.value')
    STORAGE_ACCOUNT_NAME=$(echo "$OUTPUTS" | jq -r '.storageAccountName.value')
    SEARCH_SERVICE_NAME=$(echo "$OUTPUTS" | jq -r '.searchServiceName.value')
    OPENAI_SERVICE_NAME=$(echo "$OUTPUTS" | jq -r '.openaiServiceName.value')
    APP_SERVICE_URL=$(echo "$OUTPUTS" | jq -r '.appServiceUrl')
    
    log_info "App Service: $APP_SERVICE_NAME"
    log_info "Key Vault: $KEY_VAULT_NAME"
    log_info "Storage Account: $STORAGE_ACCOUNT_NAME"
    log_info "Search Service: $SEARCH_SERVICE_NAME"
    log_info "OpenAI Service: $OPENAI_SERVICE_NAME"
    log_info "App Service URL: $APP_SERVICE_URL"
}

# Configure secrets
configure_secrets() {
    log_info "Configuring Key Vault secrets..."
    
    log_warn "Please update these secrets manually with your actual values:"
    log_warn "1. JWT Issuer: az keyvault secret set --vault-name $KEY_VAULT_NAME --name \"jwt-issuer\" --value \"https://your-auth-provider.com/\""
    log_warn "2. JWT Audience: az keyvault secret set --vault-name $KEY_VAULT_NAME --name \"jwt-audience\" --value \"your-app-client-id\""
    log_warn "3. Azure Client ID: az keyvault secret set --vault-name $KEY_VAULT_NAME --name \"azure-client-id\" --value \"your-managed-identity-client-id\""
    
    # Get tenant ID automatically
    TENANT_ID=$(az account show --query tenantId --output tsv)
    az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "azure-tenant-id" --value "$TENANT_ID"
    log_info "Updated azure-tenant-id secret with current tenant ID."
}

# Build application
build_application() {
    log_info "Building application..."
    
    # Install dependencies
    npm ci
    
    # Run linting
    npm run lint
    
    # Run tests
    npm test
    
    # Build TypeScript
    npm run build
    
    log_info "Application built successfully."
}

# Deploy application
deploy_application() {
    log_info "Deploying application to App Service..."
    
    # Create deployment package
    zip -r deployment.zip dist node_modules package.json package-lock.json
    
    # Deploy to App Service
    az webapp deployment source config-zip \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$APP_SERVICE_NAME" \
        --src deployment.zip
    
    # Clean up
    rm deployment.zip
    
    log_info "Application deployed successfully."
    log_info "App Service URL: $APP_SERVICE_URL"
}

# Main deployment function
main() {
    log_info "Starting CardAI MCP Server deployment..."
    
    check_prerequisites
    
    # Ask for confirmation
    read -p "Deploy infrastructure to resource group '$RESOURCE_GROUP_NAME'? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled."
        exit 0
    fi
    
    deploy_infrastructure
    get_deployment_outputs
    configure_secrets
    build_application
    deploy_application
    
    log_info "Deployment completed successfully!"
    log_info "Next steps:"
    log_info "1. Update Key Vault secrets with your actual JWT/OIDC configuration"
    log_info "2. Upload sample documents to the blob storage container"
    log_info "3. Test the MCP tools through the application endpoint"
}

# Handle script arguments
case "${1:-}" in
    "infrastructure")
        check_prerequisites
        deploy_infrastructure
        get_deployment_outputs
        ;;
    "application")
        check_prerequisites
        get_deployment_outputs
        build_application
        deploy_application
        ;;
    "secrets")
        check_prerequisites
        get_deployment_outputs
        configure_secrets
        ;;
    *)
        main
        ;;
esac
