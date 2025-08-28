# CardAI MCP Server with RAG on Azure

A Model Context Protocol (MCP) server implementation with Retrieval-Augmented Generation (RAG) capabilities on Azure, built with TypeScript and Node.js 20.

## 🏗️ Architecture

This project implements an MCP server that provides document search, indexing, and retrieval capabilities using:

- **Azure AI Search** for vector + semantic search
- **Azure OpenAI** for text embeddings
- **Azure Blob Storage** for document storage
- **Azure Key Vault** for secure secrets management
- **Azure App Service** with System-Assigned Managed Identity

## 🛠️ Features

### MCP Tools

1. **`search_docs`** - Search documents using vector similarity and semantic search
2. **`index_docs`** - Index documents from Azure Blob Storage into Azure AI Search
3. **`get_doc`** - Retrieve specific documents by ID

### Security

- System-Assigned Managed Identity for Azure services authentication
- Secrets stored in Azure Key Vault with RBAC access
- JWT/OIDC token validation for API authentication
- HTTPS-only communication

### Infrastructure as Code

- Complete Bicep templates for Azure resource provisioning
- Modular architecture with reusable components
- Role-based access control (RBAC) configuration
- Development and production parameter files

## 🚀 Quick Start

### Prerequisites

- Node.js 20.x
- Azure CLI
- Azure subscription with appropriate permissions

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CardAiApp
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your Azure configuration
   ```

4. **Run tests**
   ```bash
   npm test
   ```

5. **Build the application**
   ```bash
   npm run build
   ```

6. **Start development server**
   ```bash
   npm run dev
   ```

## 🌥️ Azure Deployment

### 1. Deploy Infrastructure

First, deploy the Azure infrastructure using Bicep:

```bash
# Create resource group
az group create --name cardai-mcp-dev --location "East US"

# Deploy infrastructure
az deployment group create \
  --resource-group cardai-mcp-dev \
  --template-file infra/main.bicep \
  --parameters infra/dev.parameters.json
```

### 2. Configure Secrets

After deployment, update the Key Vault secrets with your actual values:

```bash
# Get the Key Vault name from deployment output
KEYVAULT_NAME=$(az deployment group show --resource-group cardai-mcp-dev --name main --query properties.outputs.keyVaultName.value -o tsv)

# Update JWT configuration secrets
az keyvault secret set --vault-name $KEYVAULT_NAME --name "jwt-issuer" --value "https://your-auth-provider.com/"
az keyvault secret set --vault-name $KEYVAULT_NAME --name "jwt-audience" --value "your-app-client-id"
az keyvault secret set --vault-name $KEYVAULT_NAME --name "azure-client-id" --value "your-managed-identity-client-id"
az keyvault secret set --vault-name $KEYVAULT_NAME --name "azure-tenant-id" --value "your-tenant-id"
```

### 3. Deploy Application Code

Deploy the application to Azure App Service:

```bash
# Get App Service name from deployment output
APP_NAME=$(az deployment group show --resource-group cardai-mcp-dev --name main --query properties.outputs.appServiceName.value -o tsv)

# Build and deploy
npm run build
az webapp deployment source config-zip \
  --resource-group cardai-mcp-dev \
  --name $APP_NAME \
  --src dist.zip
```

### 4. Upload Sample Documents

Upload documents to the blob storage container for indexing:

```bash
# Get storage account name
STORAGE_NAME=$(az deployment group show --resource-group cardai-mcp-dev --name main --query properties.outputs.storageAccountName.value -o tsv)

# Upload documents
az storage blob upload-batch \
  --account-name $STORAGE_NAME \
  --destination documents \
  --source ./sample-docs \
  --auth-mode login
```

## 📁 Project Structure

```
.
├── src/
│   ├── index.ts              # MCP server entry point
│   ├── server.ts             # Main MCP server implementation
│   ├── config.ts             # Configuration management
│   ├── services/
│   │   └── azure-auth.ts     # Azure authentication service
│   ├── tools/
│   │   ├── search-docs.ts    # Document search implementation
│   │   ├── index-docs.ts     # Document indexing implementation
│   │   └── get-doc.ts        # Document retrieval implementation
│   └── utils/
│       └── logger.ts         # Logging utility
├── tests/
│   ├── setup.ts              # Jest test setup
│   ├── services/
│   │   └── azure-auth.test.ts
│   └── tools/
│       ├── search-docs.test.ts
│       ├── index-docs.test.ts
│       └── get-doc.test.ts
├── infra/
│   ├── main.bicep            # Main infrastructure template
│   ├── dev.parameters.json   # Development parameters
│   └── modules/              # Bicep modules
│       ├── app-service.bicep
│       ├── app-service-plan.bicep
│       ├── key-vault.bicep
│       ├── storage-account.bicep
│       ├── search-service.bicep
│       ├── openai-service.bicep
│       ├── log-analytics.bicep
│       ├── app-insights.bicep
│       └── key-vault-secrets.bicep
├── .github/workflows/
│   └── ci.yml               # CI/CD pipeline
└── README.md
```

## 🧪 Testing

The project includes comprehensive unit tests with mocked Azure SDK calls:

```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm run test:watch
```

### Test Coverage

- **Azure Authentication Service** - JWT validation, secret management
- **Search Tools** - Document search, vector embeddings
- **Index Tools** - Document processing, blob storage integration
- **Get Document Tools** - Document retrieval, pagination

## 📊 Monitoring

The deployment includes:

- **Application Insights** for application performance monitoring
- **Log Analytics** for centralized logging
- **Azure Monitor** for infrastructure monitoring

Access monitoring dashboards in the Azure portal to track:
- Request performance and errors
- Search query patterns
- Document indexing metrics
- Resource utilization

## 🔧 Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment (development/production) | `production` |
| `PORT` | Server port | `3000` |
| `AZURE_CLIENT_ID` | Managed Identity client ID | `abcd-1234-...` |
| `AZURE_TENANT_ID` | Azure tenant ID | `efgh-5678-...` |
| `AZURE_OPENAI_ENDPOINT` | OpenAI service endpoint | `https://....openai.azure.com/` |
| `AZURE_OPENAI_DEPLOYMENT_NAME` | Embedding model deployment | `text-embedding-ada-002` |
| `AZURE_SEARCH_ENDPOINT` | Search service endpoint | `https://....search.windows.net` |
| `AZURE_STORAGE_ACCOUNT_NAME` | Storage account name | `mystorageaccount` |
| `AZURE_BLOB_CONTAINER_NAME` | Blob container name | `documents` |
| `AZURE_KEYVAULT_NAME` | Key Vault name | `my-keyvault` |
| `JWT_ISSUER` | JWT token issuer | `https://auth.example.com/` |
| `JWT_AUDIENCE` | JWT token audience | `my-app-id` |

### Azure Resources Configuration

The Bicep templates create the following resources:

- **App Service Plan** (Linux, B1 SKU)
- **App Service** with Node.js 20 runtime
- **Key Vault** with RBAC authentication
- **Storage Account** with blob container
- **Azure AI Search** with semantic search enabled
- **Azure OpenAI** with text-embedding-ada-002 model
- **Application Insights** and Log Analytics

## 🚨 Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Verify Managed Identity is properly configured
   - Check Key Vault access policies and RBAC roles
   - Ensure secrets are properly set in Key Vault

2. **Search Index Issues**
   - Confirm Azure AI Search service is running
   - Check if the search index was created correctly
   - Verify API keys are valid

3. **Document Indexing Failures**
   - Check blob storage permissions
   - Verify document formats are supported
   - Monitor Application Insights for detailed error logs

4. **Embedding Generation Errors**
   - Confirm Azure OpenAI deployment is active
   - Check quota and rate limits
   - Verify model deployment configuration

### Debugging

Enable debug logging by setting `NODE_ENV=development` to see detailed logs for:
- Azure service calls
- Document processing steps
- Search query execution
- Authentication flows

## 📄 API Documentation

### MCP Tools

#### search_docs

Search documents using vector similarity and semantic search.

**Parameters:**
- `query` (string, required): Search query
- `top` (number, optional): Number of results (default: 5, max: 50)
- `filter` (string, optional): OData filter expression

**Response:** JSON array of search results with document metadata and scores.

#### index_docs

Index documents from Azure Blob Storage into Azure AI Search.

**Parameters:**
- `blobPath` (string, required): Blob path or prefix to index
- `forceReindex` (boolean, optional): Force reindexing existing documents

**Response:** JSON summary of indexing operation with statistics.

#### get_doc

Retrieve a specific document by ID.

**Parameters:**
- `documentId` (string, required): Document identifier
- `includeContent` (boolean, optional): Include full content (default: true)

**Response:** JSON document with metadata and optional content.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Version History

- **v1.0.0** - Initial release with core MCP server functionality
  - Document search, indexing, and retrieval
  - Azure integration with managed identity
  - Complete infrastructure automation
  - Comprehensive test suite

## 📞 Support

For support and questions:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review [Azure documentation](https://docs.microsoft.com/azure/)
3. Open an issue in the GitHub repository
4. Contact the development team

---

Built with ❤️ using TypeScript, Azure, and the Model Context Protocol.
