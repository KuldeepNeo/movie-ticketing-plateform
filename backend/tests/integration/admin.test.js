const request = require('supertest');
const app = require('../../src/app');
const db = require('../../src/config/db');
const { generateAccessToken } = require('../../src/utils/jwtHelper');

describe('Admin Inventory Endpoints Integration Tests', () => {
  let adminToken;
  let customerToken;
  let testCityId;
  let testTheaterId;

  beforeAll(async () => {
    // Run database migrations on the in-memory test database
    await db.migrate.latest();

    // Create user profiles to generate tokens
    const [adminId] = await db('users').insert({
      name: 'Admin User',
      email: 'admin.test@example.com',
      password_hash: 'hash',
      role: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    const [customerId] = await db('users').insert({
      name: 'Customer User',
      email: 'customer.test@example.com',
      password_hash: 'hash',
      role: 'customer',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    const adminUser = { id: adminId, email: 'admin.test@example.com', role: 'admin' };
    const customerUser = { id: customerId, email: 'customer.test@example.com', role: 'customer' };

    adminToken = generateAccessToken(adminUser);
    customerToken = generateAccessToken(customerUser);
  });

  afterAll(async () => {
    // Destroy connection to free resources
    await db.destroy();
  });

  beforeEach(async () => {
    // Clean tables before each test to ensure isolation
    await db('seats').del();
    await db('screens').del();
    await db('theaters').del();
    await db('movies').del();
    await db('cities').del();

    // Insert a base city for testing
    const [cityId] = await db('cities').insert({
      name: 'Bengaluru',
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
    testCityId = cityId;
  });

  describe('GET /api/v1/cities (Public)', () => {
    it('should list all active cities successfully without auth', async () => {
      const response = await request(app).get('/api/v1/cities');
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].name).toBe('Bengaluru');
    });
  });

  describe('RBAC Verification', () => {
    it('should block requests to admin endpoints without a token', async () => {
      const response = await request(app).get('/api/v1/admin/movies');
      expect(response.status).toBe(401);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('UNAUTHORIZED');
    });

    it('should block requests to admin endpoints from non-admin users', async () => {
      const response = await request(app)
        .get('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${customerToken}`);
      expect(response.status).toBe(403);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('FORBIDDEN');
    });
  });

  describe('Movie Management CRUD', () => {
    it('should create a new movie successfully as admin', async () => {
      const response = await request(app)
        .post('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Galactic Storm',
          synopsis: 'A team of astronauts must save Earth from an interstellar threat...',
          runtime_minutes: 148,
          language: 'English',
          genre: 'Action',
          age_rating: 'U/A',
          poster_url: 'https://cdn.example.com/posters/galactic-storm.jpg',
          banner_url: 'https://cdn.example.com/banners/galactic-storm.jpg',
          status: 'published'
        });

      expect(response.status).toBe(201);
      expect(response.body.status).toBe('success');
      expect(response.body.data.title).toBe('Galactic Storm');
      expect(response.body.data).toHaveProperty('id');
    });

    it('should reject movie creation with bad validation parameters', async () => {
      const response = await request(app)
        .post('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: '', // Empty title
          synopsis: 'Too short', // Min 10
          runtime_minutes: -10, // Must be positive
          language: 'English',
          genre: 'Action',
          age_rating: 'BAD_ENUM', // Invalid enum
          poster_url: 'bad_url', // Invalid URL
          banner_url: 'bad_url'
        });

      expect(response.status).toBe(400);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    it('should list all movies with pagination and filters', async () => {
      // Create a movie
      await request(app)
        .post('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Galactic Storm',
          synopsis: 'A team of astronauts must save Earth from an interstellar threat...',
          runtime_minutes: 148,
          language: 'English',
          genre: 'Action',
          age_rating: 'U/A',
          poster_url: 'https://cdn.example.com/posters/galactic-storm.jpg',
          banner_url: 'https://cdn.example.com/banners/galactic-storm.jpg',
          status: 'published'
        });

      const response = await request(app)
        .get('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`)
        .query({ search: 'Galactic', status: 'published' });

      expect(response.status).toBe(200);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.meta.total).toBe(1);
      expect(response.body.meta.page).toBe(1);
    });

    it('should update movie details successfully', async () => {
      // Create a movie
      const postRes = await request(app)
        .post('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Galactic Storm',
          synopsis: 'A team of astronauts must save Earth from an interstellar threat...',
          runtime_minutes: 148,
          language: 'English',
          genre: 'Action',
          age_rating: 'U/A',
          poster_url: 'https://cdn.example.com/posters/galactic-storm.jpg',
          banner_url: 'https://cdn.example.com/banners/galactic-storm.jpg',
          status: 'draft'
        });

      const movieId = postRes.body.data.id;

      const putRes = await request(app)
        .put(`/api/v1/admin/movies/${movieId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Galactic Storm: Remastered',
          status: 'published'
        });

      expect(putRes.status).toBe(200);
      expect(putRes.body.data.title).toBe('Galactic Storm: Remastered');
      expect(putRes.body.data.status).toBe('published');
    });

    it('should soft delete a movie successfully', async () => {
      // Create a movie
      const postRes = await request(app)
        .post('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          title: 'Galactic Storm',
          synopsis: 'A team of astronauts must save Earth from an interstellar threat...',
          runtime_minutes: 148,
          language: 'English',
          genre: 'Action',
          age_rating: 'U/A',
          poster_url: 'https://cdn.example.com/posters/galactic-storm.jpg',
          banner_url: 'https://cdn.example.com/banners/galactic-storm.jpg',
          status: 'published'
        });

      const movieId = postRes.body.data.id;

      const delRes = await request(app)
        .delete(`/api/v1/admin/movies/${movieId}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(delRes.status).toBe(200);
      expect(delRes.body.data.message).toBe('Movie deleted successfully.');

      // Verify not accessible anymore
      const getRes = await request(app)
        .get('/api/v1/admin/movies')
        .set('Authorization', `Bearer ${adminToken}`);
      expect(getRes.body.data).toHaveLength(0);
    });
  });

  describe('Theater Management CRUD', () => {
    it('should create a new theater successfully', async () => {
      const response = await request(app)
        .post('/api/v1/admin/theaters')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'PVR Indiranagar',
          address: '100 Feet Road, Indiranagar',
          city_id: testCityId,
          area: 'Indiranagar'
        });

      expect(response.status).toBe(201);
      expect(response.body.data.name).toBe('PVR Indiranagar');
      testTheaterId = response.body.data.id;
    });

    it('should fail theater creation if city does not exist', async () => {
      const response = await request(app)
        .post('/api/v1/admin/theaters')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'PVR Indiranagar',
          address: '100 Feet Road, Indiranagar',
          city_id: 9999, // Non-existent city ID
          area: 'Indiranagar'
        });

      expect(response.status).toBe(404);
      expect(response.body.code).toBe('RESOURCE_NOT_FOUND');
    });
  });

  describe('Screen Management & Seat Layout Generation', () => {
    let theaterId;

    beforeEach(async () => {
      const [tId] = await db('theaters').insert({
        name: 'PVR Indiranagar',
        address: '100 Feet Road, Indiranagar',
        city_id: testCityId,
        area: 'Indiranagar',
        status: 'active',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
      theaterId = tId;
    });

    it('should create a screen and automatically generate seats mapping', async () => {
      const response = await request(app)
        .post(`/api/v1/admin/theaters/${theaterId}/screens`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Screen 1',
          rows_count: 3,
          columns_count: 4,
          seat_categories: {
            'A': 'premium',
            'B-C': 'classic'
          }
        });

      expect(response.status).toBe(201);
      expect(response.body.data.name).toBe('Screen 1');
      expect(response.body.data.total_seats).toBe(12);

      const screenId = response.body.data.id;

      // Verify seats are generated in database
      const seats = await db('seats').where('screen_id', screenId);
      expect(seats).toHaveLength(12);

      // Verify categories map correctly
      const premiumSeats = seats.filter(s => s.seat_category === 'premium');
      const classicSeats = seats.filter(s => s.seat_category === 'classic');

      expect(premiumSeats).toHaveLength(4); // Row A (1x4)
      expect(classicSeats).toHaveLength(8); // Rows B and C (2x4)
    });

    it('should fail screen creation with invalid row/column dimensions', async () => {
      const response = await request(app)
        .post(`/api/v1/admin/theaters/${theaterId}/screens`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Screen 1',
          rows_count: 30, // Max 26
          columns_count: 5,
          seat_categories: {}
        });

      expect(response.status).toBe(400);
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    it('should list all screens in a theater', async () => {
      await request(app)
        .post(`/api/v1/admin/theaters/${theaterId}/screens`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'Screen 1',
          rows_count: 3,
          columns_count: 4,
          seat_categories: {}
        });

      const response = await request(app)
        .get(`/api/v1/admin/theaters/${theaterId}/screens`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].name).toBe('Screen 1');
    });
  });
});
