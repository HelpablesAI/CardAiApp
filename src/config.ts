import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export interface Config {
  port: number;
  nodeEnv: string;
  azure: {
    clientId: string;
    tenantId: string;
    openai: {
      endpoint: string;
      deploymentName: string;
    };
    search: {
      endpoint: string;
    };
    storage: {
      accountName: string;
      containerName: string;
    };
    keyVault: {
      name: string;
    };
  };
  jwt: {
    issuer: string;
    audience: string;
  };
}

function getRequiredEnv(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Required environment variable ${key} is not set`);
  }
  return value;
}

export const config: Config = {
  port: parseInt(process.env['PORT'] || '3000', 10),
  nodeEnv: process.env['NODE_ENV'] || 'development',
  azure: {
    clientId: getRequiredEnv('AZURE_CLIENT_ID'),
    tenantId: getRequiredEnv('AZURE_TENANT_ID'),
    openai: {
      endpoint: getRequiredEnv('AZURE_OPENAI_ENDPOINT'),
      deploymentName: getRequiredEnv('AZURE_OPENAI_DEPLOYMENT_NAME'),
    },
    search: {
      endpoint: getRequiredEnv('AZURE_SEARCH_ENDPOINT'),
    },
    storage: {
      accountName: getRequiredEnv('AZURE_STORAGE_ACCOUNT_NAME'),
      containerName: getRequiredEnv('AZURE_BLOB_CONTAINER_NAME'),
    },
    keyVault: {
      name: getRequiredEnv('AZURE_KEYVAULT_NAME'),
    },
  },
  jwt: {
    issuer: getRequiredEnv('JWT_ISSUER'),
    audience: getRequiredEnv('JWT_AUDIENCE'),
  },
};
