import { Server } from './mcp/server';
import { StdioServerTransport } from './mcp/transport';
import { CallToolRequestSchema, ListToolsRequestSchema } from './mcp/types';
import { McpServer } from './server';
import { config } from './config';
import { logger } from './utils/logger';

async function main(): Promise<void> {
  try {
    logger.info('Starting MCP Server...');

    const server = new Server(
      {
        name: 'cardai-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    const mcpServer = new McpServer();
    await mcpServer.initialize();

    // Register tool handlers
    server.setRequestHandler(ListToolsRequestSchema, async () => {
      return await mcpServer.listTools();
    });

    server.setRequestHandler(CallToolRequestSchema, async (request: any) => {
      return await mcpServer.callTool(request.params);
    });

    // Setup transport
    const transport = new StdioServerTransport();
    await server.connect(transport);

    logger.info(`MCP Server started successfully on port ${config.port}`);

    // Graceful shutdown
    process.on('SIGINT', async () => {
      logger.info('Received SIGINT, shutting down gracefully...');
      await server.close();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      logger.info('Received SIGTERM, shutting down gracefully...');
      await server.close();
      process.exit(0);
    });

  } catch (error) {
    logger.error('Failed to start MCP Server:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main().catch((error) => {
    logger.error('Unhandled error:', error);
    process.exit(1);
  });
}
