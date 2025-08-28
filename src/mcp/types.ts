// Mock MCP SDK types and classes for the scaffold
export interface Tool {
  name: string;
  description: string;
  inputSchema: {
    type: 'object';
    properties: Record<string, any>;
    required?: string[];
  };
}

export interface CallToolRequest {
  params: {
    name: string;
    arguments: Record<string, any>;
  };
}

export interface ListToolsRequest {
  // Empty for now
}

export interface ServerCapabilities {
  capabilities: {
    tools?: {};
  };
}

export interface ServerInfo {
  name: string;
  version: string;
}

export const ListToolsRequestSchema = 'listTools';
export const CallToolRequestSchema = 'callTool';
