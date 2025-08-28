declare module 'jwks-client' {
  interface JwksClient {
    getSigningKey(_kid: string, _callback: (_err: Error | null, _key?: any) => void): void;
  }
  
  interface JwksClientOptions {
    jwksUri: string;
    requestHeaders?: Record<string, string>;
    timeout?: number;
  }
  
  function jwksClient(_options: JwksClientOptions): JwksClient;
  export = jwksClient;
}
