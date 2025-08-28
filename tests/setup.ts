// Global test setup
import { jest } from '@jest/globals';

// Mock Azure SDK modules globally
jest.mock('@azure/identity');
jest.mock('@azure/keyvault-secrets');
jest.mock('@azure/search-documents');
jest.mock('@azure/storage-blob');
jest.mock('@azure/openai');

// Mock environment variables
process.env.NODE_ENV = 'test';
process.env.PORT = '3000';
process.env.AZURE_CLIENT_ID = 'test-client-id';
process.env.AZURE_TENANT_ID = 'test-tenant-id';
process.env.AZURE_OPENAI_ENDPOINT = 'https://test-openai.openai.azure.com/';
process.env.AZURE_OPENAI_DEPLOYMENT_NAME = 'test-embedding';
process.env.AZURE_SEARCH_ENDPOINT = 'https://test-search.search.windows.net';
process.env.AZURE_STORAGE_ACCOUNT_NAME = 'teststorage';
process.env.AZURE_BLOB_CONTAINER_NAME = 'test-documents';
process.env.AZURE_KEYVAULT_NAME = 'test-keyvault';
process.env.JWT_ISSUER = 'https://test-auth.com/';
process.env.JWT_AUDIENCE = 'test-audience';
