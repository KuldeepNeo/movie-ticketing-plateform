const db = require('../config/db');

/**
 * Repository layer for movies table data access.
 */
class MovieRepository {
  /**
   * Create a new movie record in the database.
   * @param {object} movieData 
   * @returns {Promise<object>}
   */
  async create(movieData) {
    const now = new Date().toISOString();
    const [id] = await db('movies').insert({
      title: movieData.title,
      synopsis: movieData.synopsis,
      runtime_minutes: movieData.runtime_minutes,
      language: movieData.language,
      genre: movieData.genre,
      age_rating: movieData.age_rating,
      poster_url: movieData.poster_url,
      banner_url: movieData.banner_url,
      status: movieData.status || 'draft',
      created_at: now,
      updated_at: now
    });

    return this.findById(id);
  }

  /**
   * Find movies with filters and pagination.
   * @param {object} filters 
   * @returns {Promise<{data: object[], total: number}>}
   */
  async findAll(filters = {}) {
    const page = parseInt(filters.page, 10) || 1;
    const limit = Math.min(parseInt(filters.limit, 10) || 20, 50);
    const offset = (page - 1) * limit;

    const countQuery = db('movies').whereNull('deleted_at');
    const dataQuery = db('movies').whereNull('deleted_at');

    if (filters.status) {
      countQuery.where('status', filters.status);
      dataQuery.where('status', filters.status);
    }

    if (filters.search) {
      countQuery.where('title', 'like', `%${filters.search}%`);
      dataQuery.where('title', 'like', `%${filters.search}%`);
    }

    const [{ count }] = await countQuery.count({ count: '*' });
    const data = await dataQuery
      .select('id', 'title', 'language', 'genre', 'age_rating', 'runtime_minutes', 'poster_url', 'status', 'created_at')
      .limit(limit)
      .offset(offset)
      .orderBy('id', 'desc');

    return {
      data,
      total: parseInt(count, 10)
    };
  }

  /**
   * Find a movie by ID, filtering out soft-deleted movies.
   * @param {number} id 
   * @returns {Promise<object|undefined>}
   */
  async findById(id) {
    return db('movies')
      .where('id', id)
      .whereNull('deleted_at')
      .first();
  }

  /**
   * Update movie record.
   * @param {number} id 
   * @param {object} movieData 
   * @returns {Promise<object|undefined>}
   */
  async update(id, movieData) {
    const now = new Date().toISOString();
    const updatePayload = {
      ...movieData,
      updated_at: now
    };

    await db('movies')
      .where('id', id)
      .whereNull('deleted_at')
      .update(updatePayload);

    return this.findById(id);
  }

  /**
   * Soft delete a movie record.
   * @param {number} id 
   * @returns {Promise<boolean>}
   */
  async delete(id) {
    const now = new Date().toISOString();
    const affectedRows = await db('movies')
      .where('id', id)
      .whereNull('deleted_at')
      .update({
        deleted_at: now,
        updated_at: now
      });

    return affectedRows > 0;
  }
}

module.exports = new MovieRepository();
