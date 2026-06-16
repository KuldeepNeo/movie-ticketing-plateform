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

  /**
   * Find published movies available in a city based on scheduled shows.
   * @param {number} cityId 
   * @param {object} filters 
   * @returns {Promise<{data: object[], total: number}>}
   */
  async findPublishedMoviesByCity(cityId, filters = {}) {
    const page = parseInt(filters.page, 10) || 1;
    const limit = Math.min(parseInt(filters.limit, 10) || 20, 50);
    const offset = (page - 1) * limit;

    const baseQuery = () => db('movies')
      .join('shows', 'shows.movie_id', 'movies.id')
      .join('screens', 'screens.id', 'shows.screen_id')
      .join('theaters', 'theaters.id', 'screens.theater_id')
      .where('theaters.city_id', cityId)
      .where('movies.status', 'published')
      .whereNull('shows.deleted_at')
      .whereNull('screens.deleted_at')
      .whereNull('theaters.deleted_at')
      .whereNull('movies.deleted_at');

    const filterQuery = (builder) => {
      if (filters.search) {
        builder.where('movies.title', 'like', `%${filters.search}%`);
      }
      if (filters.language) {
        builder.where('movies.language', filters.language);
      }
      if (filters.genre) {
        builder.where('movies.genre', filters.genre);
      }
      if (filters.age_rating) {
        builder.where('movies.age_rating', filters.age_rating);
      }
    };

    const countResult = await baseQuery()
      .modify(filterQuery)
      .countDistinct('movies.id as count')
      .first();

    const total = countResult ? parseInt(countResult.count, 10) : 0;

    const dataQuery = baseQuery().modify(filterQuery);

    let sortByField = 'movies.title';
    if (filters.sort_by === 'id' || filters.sort_by === 'release_date') {
      sortByField = 'movies.id';
    }

    const sortOrder = filters.sort_order === 'desc' ? 'desc' : 'asc';

    const data = await dataQuery
      .select('movies.id', 'movies.title', 'movies.language', 'movies.genre', 'movies.age_rating', 'movies.runtime_minutes', 'movies.poster_url', 'movies.status')
      .distinct('movies.id')
      .limit(limit)
      .offset(offset)
      .orderBy(sortByField, sortOrder);

    return {
      data,
      total
    };
  }
}

module.exports = new MovieRepository();
