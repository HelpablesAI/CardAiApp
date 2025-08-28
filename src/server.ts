import { Tool, CallToolRequest } from './mcp/types';
import { SearchDocsClient } from './tools/search-docs';
import { IndexDocsClient } from './tools/index-docs';
import { GetDocClient } from './tools/get-doc';
import { AzureAuthService } from './services/azure-auth';
import { logger } from './utils/logger';

export class McpServer {
  private searchDocsClient: SearchDocsClient;
  private indexDocsClient: IndexDocsClient;
  private getDocClient: GetDocClient;
  private authService: AzureAuthService;

  constructor() {
    this.authService = new AzureAuthService();
    this.searchDocsClient = new SearchDocsClient(this.authService);
    this.indexDocsClient = new IndexDocsClient(this.authService);
    this.getDocClient = new GetDocClient(this.authService);
  }

  async initialize(): Promise<void> {
    logger.info('Initializing MCP Server...');
    
    try {
      await this.authService.initialize();
      await this.searchDocsClient.initialize();
      await this.indexDocsClient.initialize();
      await this.getDocClient.initialize();
      
      logger.info('MCP Server initialized successfully');
    } catch (error) {
      logger.error('Failed to initialize MCP Server:', error);
      throw error;
    }
  }

  async listTools(): Promise<{ tools: Tool[] }> {
    const tools: Tool[] = [
      {
        name: 'search_docs',
        description: 'Search documents using vector similarity and semantic search',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'The search query to find relevant documents',
            },
            top: {
              type: 'number',
              description: 'Number of results to return (default: 5, max: 50)',
              default: 5,
            },
            filter: {
              type: 'string',
              description: 'Optional OData filter expression',
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'index_docs',
        description: 'Index documents from Azure Blob Storage into Azure AI Search',
        inputSchema: {
          type: 'object',
          properties: {
            blobPath: {
              type: 'string',
              description: 'Path to the blob or blob prefix to index',
            },
            forceReindex: {
              type: 'boolean',
              description: 'Force reindexing even if document already exists',
              default: false,
            },
          },
          required: ['blobPath'],
        },
      },
      {
        name: 'get_doc',
        description: 'Retrieve a specific document by its ID',
        inputSchema: {
          type: 'object',
          properties: {
            documentId: {
              type: 'string',
              description: 'The unique identifier of the document to retrieve',
            },
            includeContent: {
              type: 'boolean',
              description: 'Whether to include the full document content',
              default: true,
            },
          },
          required: ['documentId'],
        },
      },
    ];

    return { tools };
  }

  async callTool(params: CallToolRequest['params']): Promise<{ content: Array<{ type: 'text'; text: string }> }> {
    const { name, arguments: args } = params;

    try {
      let result: string;

      switch (name) {
        case 'search_docs':
          result = await this.searchDocsClient.searchDocuments(
            args['query'] as string
          );
          break;

        case 'index_docs':
          result = await this.indexDocsClient.indexDocuments(
            args['blobPath'] as string
          );
          break;

        case 'get_doc':
          result = await this.getDocClient.getDocument(
            args['documentId'] as string
          );
          break;

        default:
          throw new Error(`Unknown tool: ${name}`);
      }

      return {
        content: [
          {
            type: 'text',
            text: result,
          },
        ],
      };
    } catch (error) {
      logger.error(`Error executing tool ${name}:`, error);
      return {
        content: [
          {
            type: 'text',
            text: `Error: ${error instanceof Error ? error.message : 'Unknown error'}`,
          },
        ],
      };
    }
  }
}
