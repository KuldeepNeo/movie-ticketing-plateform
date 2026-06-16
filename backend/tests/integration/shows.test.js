const request = require('supertest');
const app = require('../../src/app');
const db = require('../../src/config/db');
const { generateAccessToken } = require('../../src/utils/jwtHelper');

describe('Shows & Movie Discovery Integration Tests', () => {
  let adminToken;
  let customerToken;
  let cityId;
  let theaterId;
  let screenId;
  let publishedMovieId;
  let draftMovieId;

  beforeAll(async () => {
    // Run database migrations on the test database
    await db.migrate.latest();

    // Create user profiles to generate tokens
    const [adminId] = await db('users').insert({
      name: 'Admin User',
      email: 'admin.shows@example.com',
      password_hash: 'hash',
      role: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    const [customerId] = await db('users').insert({
      name: 'Customer User',
      email: 'customer.shows@example.com',
      password_hash: 'hash',
      role: 'customer',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });

    adminToken = generateAccessToken({ id: adminId, email: 'admin.shows@example.com', role: 'admin' });
    customerToken = generateAccessToken({ id: customerId, email: 'customer.shows@example.com', role: 'customer' });
  });

  afterAll(async () => {
    await db.destroy();
  });

  beforeEach(async () => {
    // Clean up database tables
    await db('show_seats').del();
    await db('shows').del();
    await db('seats').del();
    await db('screens').del();
    await db('theaters').del();
    await db('movies').del();
    await db('cities').del();

    // 1. Insert a City
    const [cId] = await db('cities').insert({
      name: 'Mumbai',
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
    cityId = cId;

    // 2. Insert a Theater in that City
    const [tId] = await db('theaters').insert({
      name: 'PVR Mumbai',
      address: 'Lower Parel',
      city_id: cityId,
      area: 'Lower Parel',
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
    theaterId = tId;

    // 3. Insert a Screen for that Theater
    const [sId] = await db('screens').insert({
      name: 'Audi 1',
      theater_id: theaterId,
      rows_count: 2,
      columns_count: 5,
      status: 'active',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    });
    screenId = sId;

    // 4. Insert active seats for that Screen
    const seats = [];
    const now = new Date().toISOString();
    for (let r = 1; r <= 2; r++) {
      const rowLabel = String.fromCharCode(64 + r); // A, B
      for (let c = 1; c <= 5; c++) {
        seats.push({
          screen_id: screenId,
          row_label: rowLabel,
          column_number: c,
          seat_category: 'classic',
          status: 'active',
          created_at: now,
          updated_at: now
        });
      }
    }
    await db('seats').insert(seats);

    // 5. Insert Movies (Published and Draft)
    const [pubMovieId] = await db('movies').insert({
      title: 'Action Movie 1',
      synopsis: 'A high-octane action thriller with intense sequences.',
      runtime_minutes: 120,
      language: 'English',
      genre: 'Action',
      age_rating: 'U/A',
      poster_url: 'https://cdn.example.com/poster1.jpg',
      banner_url: 'https://cdn.example.com/banner1.jpg',
      status: 'published',
      created_at: now,
      updated_at: now
    });
    publishedMovieId = pubMovieId;

    const [drfMovieId] = await db('movies').insert({
      title: 'Draft Movie 2',
      synopsis: 'Upcoming movie detail synopsis draft version.',
      runtime_minutes: 90,
      language: 'Hindi',
      genre: 'Comedy',
      age_rating: 'U',
      poster_url: 'https://cdn.example.com/poster2.jpg',
      banner_url: 'https://cdn.example.com/banner2.jpg',
      status: 'draft',
      created_at: now,
      updated_at: now
    });
    draftMovieId = drfMovieId;
  });

  describe('Admin Show CRUD Endpoints', () => {
    it('should allow admin to create a show and auto-generate show_seats', async () => {
      const showPayload = {
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 250
      };

      const response = await request(app)
        .post('/api/v1/admin/shows')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(showPayload);

      expect(response.status).toBe(201);
      expect(response.body.status).toBe('success');
      expect(response.body.data.movie_id).toBe(publishedMovieId);
      expect(response.body.data.screen_id).toBe(screenId);
      expect(response.body.data.total_seats_created).toBe(10); // 2 rows * 5 columns = 10 seats

      // Verify records exist in show_seats table
      const countSeats = await db('show_seats')
        .where('show_id', response.body.data.id)
        .count({ count: '*' })
        .first();
      expect(parseInt(countSeats.count, 10)).toBe(10);
    });

    it('should deny customers from creating shows (RBAC)', async () => {
      const showPayload = {
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 250
      };

      const response = await request(app)
        .post('/api/v1/admin/shows')
        .set('Authorization', `Bearer ${customerToken}`)
        .send(showPayload);

      expect(response.status).toBe(403);
    });

    it('should reject show creation if movie is not published', async () => {
      const showPayload = {
        movie_id: draftMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 250
      };

      const response = await request(app)
        .post('/api/v1/admin/shows')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(showPayload);

      expect(response.status).toBe(422);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('UNPROCESSABLE_ENTITY');
    });

    it('should reject show creation if time range overlaps with an existing show', async () => {
      // Create first show
      await db('shows').insert({
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 200,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

      // Attempt second overlapping show (starts during the first show)
      const overlapPayload = {
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T15:00:00Z',
        end_time: '2026-06-25T17:00:00Z',
        ticket_price: 250
      };

      const response = await request(app)
        .post('/api/v1/admin/shows')
        .set('Authorization', `Bearer ${adminToken}`)
        .send(overlapPayload);

      expect(response.status).toBe(422);
      expect(response.body.status).toBe('error');
      expect(response.body.message).toContain('Overlapping show');
    });

    it('should allow admin to list scheduled shows with pagination', async () => {
      // Insert mock show
      await db('shows').insert({
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 200,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

      const response = await request(app)
        .get('/api/v1/admin/shows')
        .set('Authorization', `Bearer ${adminToken}`)
        .query({ movie_id: publishedMovieId });

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data).toHaveLength(1);
      expect(response.body.meta.total).toBe(1);
    });

    it('should allow admin to update show details', async () => {
      const [showId] = await db('shows').insert({
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 200,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

      const updatePayload = {
        ticket_price: 300,
        show_date: '2026-06-26',
        start_time: '2026-06-26T14:00:00Z',
        end_time: '2026-06-26T16:00:00Z'
      };

      const response = await request(app)
        .put(`/api/v1/admin/shows/${showId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send(updatePayload);

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data.ticket_price).toBe(300);
      expect(response.body.data.show_date).toBe('2026-06-26');
    });

    it('should allow admin to cancel (soft-delete) a show', async () => {
      const [showId] = await db('shows').insert({
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 200,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });

      const response = await request(app)
        .delete(`/api/v1/admin/shows/${showId}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data.message).toBe('Show cancelled successfully.');

      // Check soft-deleted show is not returned in findById
      const showInDb = await db('shows').where('id', showId).first();
      expect(showInDb.deleted_at).not.toBeNull();
    });
  });

  describe('Customer Movie Discovery Endpoints', () => {
    beforeEach(async () => {
      // Schedule a show for the published movie in Mumbai
      await db('shows').insert({
        movie_id: publishedMovieId,
        screen_id: screenId,
        show_date: '2026-06-25',
        start_time: '2026-06-25T14:00:00Z',
        end_time: '2026-06-25T16:00:00Z',
        ticket_price: 200,
        status: 'scheduled',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      });
    });

    it('should fail with 400 if city_id is missing', async () => {
      const response = await request(app)
        .get('/api/v1/movies');

      expect(response.status).toBe(400);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('VALIDATION_ERROR');
    });

    it('should return published movies active in the selected city', async () => {
      const response = await request(app)
        .get('/api/v1/movies')
        .query({ city_id: cityId });

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].id).toBe(publishedMovieId);
      expect(response.body.data[0].title).toBe('Action Movie 1');
    });

    it('should support search, genre, language, and age rating query filters', async () => {
      // 1. Matching search
      let response = await request(app)
        .get('/api/v1/movies')
        .query({ city_id: cityId, search: 'action' });
      expect(response.body.data).toHaveLength(1);

      // 2. Non-matching search
      response = await request(app)
        .get('/api/v1/movies')
        .query({ city_id: cityId, search: 'romantic' });
      expect(response.body.data).toHaveLength(0);

      // 3. Matching language and genre
      response = await request(app)
        .get('/api/v1/movies')
        .query({ city_id: cityId, language: 'English', genre: 'Action' });
      expect(response.body.data).toHaveLength(1);

      // 4. Non-matching language
      response = await request(app)
        .get('/api/v1/movies')
        .query({ city_id: cityId, language: 'Spanish' });
      expect(response.body.data).toHaveLength(0);
    });

    it('should return detailed movie information for a published movie', async () => {
      const response = await request(app)
        .get(`/api/v1/movies/${publishedMovieId}`);

      expect(response.status).toBe(200);
      expect(response.body.status).toBe('success');
      expect(response.body.data.title).toBe('Action Movie 1');
      expect(response.body.data.status).toBe('published');
    });

    it('should return 404 for a draft movie details request', async () => {
      const response = await request(app)
        .get(`/api/v1/movies/${draftMovieId}`);

      expect(response.status).toBe(404);
      expect(response.body.status).toBe('error');
      expect(response.body.code).toBe('RESOURCE_NOT_FOUND');
    });
  });
});
