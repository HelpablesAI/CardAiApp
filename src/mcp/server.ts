// Mock MCP SDK Server implementation
import { ServerInfo, ServerCapabilities } from './types';

export class Server {
  private info: ServerInfo;
  private requestHandlers: Map<string, (_request: any) => Promise<any>> = new Map();

  constructor(info: ServerInfo, _capabilities: ServerCapabilities) {
    this.info = info;
  }

  setRequestHandler(schema: string, handler: (_request: any) => Promise<any>): void {
    this.requestHandlers.set(schema, handler);
  }

  async connect(_transport: any): Promise<void> {
    console.log(`MCP Server ${this.info.name} v${this.info.version} connected`);
    // Mock connection logic
  }

  async close(): Promise<void> {
    console.log('MCP Server disconnected');
    // Mock close logic
  }

  // Mock method to handle requests (for testing)
  async handleRequest(schema: string, request: any): Promise<any> {
    const handler = this.requestHandlers.get(schema);
    if (!handler) {
      throw new Error(`No handler for schema: ${schema}`);
    }
    return await handler(request);
  }
}
