const db = require('../../src/config/db');
const authService = require('../../src/services/authService');
const { hashPassword, comparePassword } = require('../../src/utils/hashHelper');
const { generateAccessToken, generateRefreshToken, verifyAccessToken } = require('../../src/utils/jwtHelper');
const { ConflictError, UnauthorizedError } = require('../../src/utils/errors');

describe('Auth Helpers & Service Unit Tests', () => {
  beforeAll(async () => {
    // Run database migrations on the in-memory test database
    await db.migrate.latest();
  });

  afterAll(async () => {
    // Destroy connection to free resources
    await db.destroy();
  });

  beforeEach(async () => {
    // Clear user table entries before each test
    await db('users').del();
  });

  describe('Hash Helper', () => {
    it('should hash a password and verify it successfully', async () => {
      const password = 'SecureP@ss1';
      const hash = await hashPassword(password);
      
      expect(hash).toBeDefined();
      expect(hash).not.toBe(password);
      
      const isMatch = await comparePassword(password, hash);
      expect(isMatch).toBe(true);
      
      const isWrongMatch = await comparePassword('wrongPassword', hash);
      expect(isWrongMatch).toBe(false);
    });
  });

  describe('JWT Helper', () => {
    it('should generate valid access and refresh tokens', () => {
      const user = { id: 123, email: 'test@example.com', role: 'customer' };
      
      const accessToken = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);
      
      expect(accessToken).toBeDefined();
      expect(refreshToken).toBeDefined();
      
      const decoded = verifyAccessToken(accessToken);
      expect(decoded.sub).toBe(user.id);
      expect(decoded.email).toBe(user.email);
      expect(decoded.role).toBe(user.role);
    });
  });

  describe('Auth Service', () => {
    it('should register a new user successfully', async () => {
      const payload = {
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'Password1!'
      };

      const result = await authService.register(payload);
      
      expect(result).toHaveProperty('id');
      expect(result.name).toBe(payload.name);
      expect(result.email).toBe(payload.email.toLowerCase());
      expect(result.role).toBe('customer');
      expect(result).not.toHaveProperty('password_hash');
    });

    it('should fail registration if email is duplicate', async () => {
      const payload = {
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'Password1!'
      };

      await authService.register(payload);

      await expect(authService.register(payload)).rejects.toThrow(ConflictError);
    });

    it('should authenticate user and return tokens on login', async () => {
      const registrationPayload = {
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'Password1!'
      };

      await authService.register(registrationPayload);

      const loginResult = await authService.login('jane@example.com', 'Password1!');
      
      expect(loginResult).toHaveProperty('access_token');
      expect(loginResult).toHaveProperty('refresh_token');
      expect(loginResult.user.email).toBe('jane@example.com');
      expect(loginResult.expires_in).toBe(900);
    });

    it('should fail login if password or email is incorrect', async () => {
      const registrationPayload = {
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'Password1!'
      };

      await authService.register(registrationPayload);

      // Wrong password
      await expect(authService.login('jane@example.com', 'wrongPassword')).rejects.toThrow(UnauthorizedError);
      
      // Wrong email
      await expect(authService.login('wrong@example.com', 'Password1!')).rejects.toThrow(UnauthorizedError);
    });
  });
});
