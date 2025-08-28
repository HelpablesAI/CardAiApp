# CardAI MCP Server - Product Requirements Document (PRD)

## Project Overview

The CardAI MCP Server is a Model Context Protocol (MCP) server implementation that provides Retrieval-Augmented Generation (RAG) capabilities on Microsoft Azure. This server enables intelligent document search, indexing, and retrieval through Azure's AI services.

## Technical Specifications

### Core Technology Stack
- **Language**: TypeScript
- **Runtime**: Node.js 20.x
- **Protocol**: Model Context Protocol (MCP)
- **Cloud Platform**: Microsoft Azure

### MCP Tools Implementation
The server implements three primary MCP tools:

1. **search_docs** - Vector and semantic document search
2. **index_docs** - Document indexing from Azure Blob Storage  
3. **get_doc** - Document retrieval by ID

### Azure Services Architecture

#### RAG Backend Components
- **Document Storage**: Azure Blob Storage
- **Vectorization**: Azure OpenAI embeddings (text-embedding-ada-002)
- **Search Engine**: Azure AI Search (vector + semantic retrieval)

#### Security Implementation
- **Authentication**: System-Assigned Managed Identity on App Service
- **Secrets Management**: Azure Key Vault (az-search-key, az-openai-key)
- **Access Control**: App Service identity with Key Vault Secrets User role
- **API Security**: JWT/OIDC validation helper

### Infrastructure as Code (IaC)
Complete Bicep template implementation providing:

#### Azure Resources
- App Service (Linux) with Node.js 20 runtime
- Azure AI Search with semantic search capabilities
- Azure OpenAI service with embedding model deployment
- Azure Blob Storage with document container
- Azure Key Vault with RBAC configuration
- Application Insights and Log Analytics for monitoring

#### Deployment Automation
- Modular Bicep templates in `/infra` directory
- Development parameters in `dev.parameters.json`
- Role assignment automation for managed identity
- Automated secret provisioning to Key Vault

### Repository Structure
```
├── src/                     # MCP server implementation
│   ├── index.ts            # Server entry point  
│   ├── server.ts           # MCP server logic
│   └── tools/              # MCP tool implementations
├── tests/                   # Jest unit tests
├── infra/                   # Bicep IaC templates
├── .github/workflows/       # CI/CD pipeline
└── README.md               # Deployment instructions
```

### Testing Strategy
- **Unit Tests**: Jest framework with Azure SDK mocking
- **Tool Coverage**: Individual tests for search, index, and retrieval tools
- **Integration Tests**: End-to-end Azure service interaction testing
- **CI/CD Pipeline**: Automated testing in GitHub Actions

### Deployment Pipeline
GitHub Actions workflow implementing:
- Automated testing (`npm ci`, `npm run build`, `npm test`)
- Security scanning and linting
- Artifact creation and deployment to Azure App Service
- Environment-specific deployments (dev/staging/prod)

## Success Criteria

### Functional Requirements
✅ Complete MCP server scaffold with all three tools
✅ Working RAG implementation using Azure AI services  
✅ Secure authentication with managed identity
✅ Infrastructure automation with Bicep
✅ Comprehensive test suite with mocked dependencies

### Technical Requirements  
✅ TypeScript implementation with Node.js 20
✅ Buildable and testable without external dependencies
✅ Production-ready security configuration
✅ Scalable Azure architecture
✅ Complete documentation and deployment guides

### Operational Requirements
✅ Automated CI/CD pipeline
✅ Monitoring and logging integration
✅ Infrastructure provisioning automation  
✅ Secret management with Key Vault
✅ Role-based access control implementation

This PRD serves as the blueprint for the CardAI MCP Server implementation, ensuring all technical requirements are met while providing a robust, scalable, and secure solution for document intelligence capabilities.
