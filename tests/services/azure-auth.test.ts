import { AzureAuthService } from '../../src/services/azure-auth';

describe('AzureAuthService', () => {
  let authService: AzureAuthService;

  beforeEach(() => {
    authService = new AzureAuthService();
  });

  describe('initialize', () => {
    it('should initialize successfully', async () => {
      await authService.initialize();
      
      const secrets = authService.getSecrets();
      expect(secrets.searchApiKey).toBe('mock-search-api-key');
      expect(secrets.openaiApiKey).toBe('mock-openai-api-key');
    });
  });

  describe('getSecrets', () => {
    it('should return secrets after initialization', async () => {
      await authService.initialize();
      
      const secrets = authService.getSecrets();
      expect(secrets.searchApiKey).toBe('mock-search-api-key');
      expect(secrets.openaiApiKey).toBe('mock-openai-api-key');
    });

    it('should throw error if not initialized', () => {
      expect(() => authService.getSecrets()).toThrow('Secrets not loaded. Call initialize() first.');
    });
  });

  describe('validateJwtToken', () => {
    it('should validate JWT token successfully', async () => {
      await authService.initialize();
      
      const result = await authService.validateJwtToken('mock-token');
      expect(result).toBeDefined();
      expect(result.sub).toBe('mock-user');
    });
  });

  describe('extractBearerToken', () => {
    it('should extract token from Bearer header', () => {
      const token = authService.extractBearerToken('Bearer abc123');
      expect(token).toBe('abc123');
    });

    it('should return null for invalid header', () => {
      const token = authService.extractBearerToken('Invalid abc123');
      expect(token).toBeNull();
    });

    it('should return null for missing header', () => {
      const token = authService.extractBearerToken('');
      expect(token).toBeNull();
    });
  });
});
