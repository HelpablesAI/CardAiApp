# CardAI MCP Server - Deployment Script (PowerShell)
param(
    [string]$Command = "",
    [string]$ResourceGroup = "cardai-mcp-dev",
    [string]$Location = "East US"
)

# Configuration
$TemplateFile = "infra/main.bicep"
$ParametersFile = "infra/dev.parameters.json"

# Helper functions
function Write-InfoLog($message) {
    Write-Host "[INFO] $message" -ForegroundColor Green
}

function Write-WarnLog($message) {
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Write-ErrorLog($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

# Check prerequisites
function Test-Prerequisites {
    Write-InfoLog "Checking prerequisites..."
    
    # Check Azure CLI
    if (!(Get-Command az -ErrorAction SilentlyContinue)) {
        Write-ErrorLog "Azure CLI is not installed. Please install it first."
        exit 1
    }
    
    # Check if logged into Azure
    try {
        az account show --output none
    } catch {
        Write-ErrorLog "Not logged into Azure. Please run 'az login' first."
        exit 1
    }
    
    # Check Node.js
    if (!(Get-Command node -ErrorAction SilentlyContinue)) {
        Write-ErrorLog "Node.js is not installed. Please install Node.js 20.x."
        exit 1
    }
    
    # Check Node.js version
    $nodeVersion = node -v
    $majorVersion = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    if ($majorVersion -lt 20) {
        Write-ErrorLog "Node.js version must be 20 or higher. Current version: $nodeVersion"
        exit 1
    }
    
    Write-InfoLog "All prerequisites satisfied."
}

# Deploy infrastructure
function Deploy-Infrastructure {
    Write-InfoLog "Deploying Azure infrastructure..."
    
    # Create resource group if it doesn't exist
    Write-InfoLog "Creating resource group: $ResourceGroup"
    az group create --name $ResourceGroup --location $Location --output table
    
    # Deploy Bicep template
    Write-InfoLog "Deploying Bicep template..."
    az deployment group create `
        --resource-group $ResourceGroup `
        --template-file $TemplateFile `
        --parameters $ParametersFile `
        --output table
        
    Write-InfoLog "Infrastructure deployment completed."
}

# Get deployment outputs
function Get-DeploymentOutputs {
    Write-InfoLog "Retrieving deployment outputs..."
    
    $outputs = az deployment group show `
        --resource-group $ResourceGroup `
        --name main `
        --query properties.outputs `
        --output json | ConvertFrom-Json
    
    $global:AppServiceName = $outputs.appServiceName.value
    $global:KeyVaultName = $outputs.keyVaultName.value
    $global:StorageAccountName = $outputs.storageAccountName.value
    $global:SearchServiceName = $outputs.searchServiceName.value
    $global:OpenAIServiceName = $outputs.openaiServiceName.value
    $global:AppServiceUrl = $outputs.appServiceUrl.value
    
    Write-InfoLog "App Service: $global:AppServiceName"
    Write-InfoLog "Key Vault: $global:KeyVaultName"
    Write-InfoLog "Storage Account: $global:StorageAccountName"
    Write-InfoLog "Search Service: $global:SearchServiceName"
    Write-InfoLog "OpenAI Service: $global:OpenAIServiceName"
    Write-InfoLog "App Service URL: $global:AppServiceUrl"
}

# Configure secrets
function Set-KeyVaultSecrets {
    Write-InfoLog "Configuring Key Vault secrets..."
    
    Write-WarnLog "Please update these secrets manually with your actual values:"
    Write-WarnLog "1. JWT Issuer: az keyvault secret set --vault-name $global:KeyVaultName --name `"jwt-issuer`" --value `"https://your-auth-provider.com/`""
    Write-WarnLog "2. JWT Audience: az keyvault secret set --vault-name $global:KeyVaultName --name `"jwt-audience`" --value `"your-app-client-id`""
    Write-WarnLog "3. Azure Client ID: az keyvault secret set --vault-name $global:KeyVaultName --name `"azure-client-id`" --value `"your-managed-identity-client-id`""
    
    # Get tenant ID automatically
    $tenantId = az account show --query tenantId --output tsv
    az keyvault secret set --vault-name $global:KeyVaultName --name "azure-tenant-id" --value $tenantId
    Write-InfoLog "Updated azure-tenant-id secret with current tenant ID."
}

# Build application
function Build-Application {
    Write-InfoLog "Building application..."
    
    # Install dependencies
    npm ci
    
    # Run linting
    npm run lint
    
    # Run tests
    npm test
    
    # Build TypeScript
    npm run build
    
    Write-InfoLog "Application built successfully."
}

# Deploy application
function Deploy-Application {
    Write-InfoLog "Deploying application to App Service..."
    
    # Create deployment package
    $deploymentZip = "deployment.zip"
    if (Test-Path $deploymentZip) {
        Remove-Item $deploymentZip
    }
    
    Compress-Archive -Path "dist", "node_modules", "package.json", "package-lock.json" -DestinationPath $deploymentZip
    
    # Deploy to App Service
    az webapp deployment source config-zip `
        --resource-group $ResourceGroup `
        --name $global:AppServiceName `
        --src $deploymentZip
    
    # Clean up
    Remove-Item $deploymentZip
    
    Write-InfoLog "Application deployed successfully."
    Write-InfoLog "App Service URL: $global:AppServiceUrl"
}

# Main deployment function
function Start-Deployment {
    Write-InfoLog "Starting CardAI MCP Server deployment..."
    
    Test-Prerequisites
    
    # Ask for confirmation
    $confirmation = Read-Host "Deploy infrastructure to resource group '$ResourceGroup'? (y/N)"
    if ($confirmation -ne 'y' -and $confirmation -ne 'Y') {
        Write-InfoLog "Deployment cancelled."
        return
    }
    
    Deploy-Infrastructure
    Get-DeploymentOutputs
    Set-KeyVaultSecrets
    Build-Application
    Deploy-Application
    
    Write-InfoLog "Deployment completed successfully!"
    Write-InfoLog "Next steps:"
    Write-InfoLog "1. Update Key Vault secrets with your actual JWT/OIDC configuration"
    Write-InfoLog "2. Upload sample documents to the blob storage container"
    Write-InfoLog "3. Test the MCP tools through the application endpoint"
}

# Handle script arguments
switch ($Command.ToLower()) {
    "infrastructure" {
        Test-Prerequisites
        Deploy-Infrastructure
        Get-DeploymentOutputs
    }
    "application" {
        Test-Prerequisites
        Get-DeploymentOutputs
        Build-Application
        Deploy-Application
    }
    "secrets" {
        Test-Prerequisites
        Get-DeploymentOutputs
        Set-KeyVaultSecrets
    }
    default {
        Start-Deployment
    }
}
