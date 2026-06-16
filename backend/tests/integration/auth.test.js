const request = require('supertest');
const app = require('../../src/app');
const db = require('../../src/config/db');

describe('Authentication Endpoints Integration Tests', () => {
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

  describe('POST /api/v1/auth/register', () => {
    it('should register a new user account with correct response', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: 'SecureP@ss1',
          confirm_password: 'SecureP@ss1'
        });

      expect(response.status).toBe(201);
      expect(response.body.status).toBe('success');
      expect(response.body.data.name).toBe('Jane Doe');
      expect(response.body.data.email).toBe('jane@example.com');
      expect(response.body.data.role).toBe('customer');
      expect(response.body.data).toHaveProperty('created_at');
    });

    it('should fail registration with 400 validation error if passwords do not match', async () => {
      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: 'SecureP@ss1',
          confirm_password: 'differentPassword'
        });

      expect(response.status).toBe(400);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('VALIDATION_ERROR');
      expect(response.body.errors).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            field: 'confirm_password',
            message: 'Confirm password must match password.'
          })
        ])
      );
    });

    it('should fail with 409 conflict if email already exists', async () => {
      await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: 'SecureP@ss1',
          confirm_password: 'SecureP@ss1'
        });

      const response = await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'Another Doe',
          email: 'jane@example.com',
          password: 'SecureP@ss1',
          confirm_password: 'SecureP@ss1'
        });

      expect(response.status).toBe(409);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('CONFLICT');
      expect(response.body.message).toBe('Email address already registered.');
    });
  });

  describe('POST /api/v1/auth/login', () => {
    beforeEach(async () => {
      await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecureP@ss1',
          confirm_password: 'SecureP@ss1'
        });
    });

    it('should log in successfully and return token credentials', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'john@example.com',
          password: 'SecureP@ss1'
        });

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data.user.email).toBe('john@example.com');
      expect(response.body.data).toHaveProperty('access_token');
      expect(response.body.data).toHaveProperty('refresh_token');
      expect(response.body.data.expires_in).toBe(900);
    });

    it('should fail log in with 401 for incorrect credentials', async () => {
      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'john@example.com',
          password: 'wrongPassword'
        });

      expect(response.status).toBe(401);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('UNAUTHORIZED');
    });
  });

  describe('Protected Routes', () => {
    let accessToken;
    let refreshToken;

    beforeEach(async () => {
      await request(app)
        .post('/api/v1/auth/register')
        .send({
          name: 'John Doe',
          email: 'john@example.com',
          password: 'SecureP@ss1',
          confirm_password: 'SecureP@ss1'
        });

      const response = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'john@example.com',
          password: 'SecureP@ss1'
        });

      accessToken = response.body.data.access_token;
      refreshToken = response.body.data.refresh_token;
    });

    it('GET /api/v1/auth/me should fetch profile successfully with valid token', async () => {
      const response = await request(app)
        .get('/api/v1/auth/me')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data.email).toBe('john@example.com');
    });

    it('GET /api/v1/auth/me should return 401 without auth header', async () => {
      const response = await request(app).get('/api/v1/auth/me');

      expect(response.status).toBe(401);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('UNAUTHORIZED');
    });

    it('POST /api/v1/auth/refresh should refresh access token', async () => {
      const response = await request(app)
        .post('/api/v1/auth/refresh')
        .send({ refresh_token: refreshToken });

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data).toHaveProperty('access_token');
      expect(response.body.data.expires_in).toBe(900);
    });

    it('POST /api/v1/auth/logout should logout successfully', async () => {
      const response = await request(app)
        .post('/api/v1/auth/logout')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data.message).toBe('Logged out successfully.');
    });
  });
});
