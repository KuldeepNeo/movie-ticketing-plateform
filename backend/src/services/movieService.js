const movieRepository = require('../repositories/movieRepository');
const { NotFoundError, ConflictError } = require('../utils/errors');
const db = require('../config/db');

/**
 * Service layer orchestrating movie management business flows.
 */
class MovieService {
  /**
   * Create a new movie.
   * @param {object} movieData 
   * @returns {Promise<object>}
   */
  async createMovie(movieData) {
    return movieRepository.create(movieData);
  }

  /**
   * List all movies with page/limit/status/search filters.
   * @param {object} filters 
   * @returns {Promise<object>}
   */
  async getAdminMovies(filters) {
    return movieRepository.findAll(filters);
  }

  /**
   * Update an existing movie.
   * @param {number} id 
   * @param {object} movieData 
   * @returns {Promise<object>}
   */
  async updateMovie(id, movieData) {
    const movie = await movieRepository.findById(id);
    if (!movie) {
      throw new NotFoundError('Movie with this ID does not exist.');
    }

    return movieRepository.update(id, movieData);
  }

  /**
   * Soft-delete a movie record, validating shows dependencies.
   * @param {number} id 
   * @returns {Promise<void>}
   */
  async deleteMovie(id) {
    const movie = await movieRepository.findById(id);
    if (!movie) {
      throw new NotFoundError('Movie with this ID does not exist.');
    }

    // Check if shows table exists and contains future scheduled shows for this movie
    const hasShowsTable = await db.schema.hasTable('shows');
    if (hasShowsTable) {
      const today = new Date().toISOString().split('T')[0];
      const [{ count }] = await db('shows')
        .where('movie_id', id)
        .where('show_date', '>=', today)
        .whereNull('deleted_at')
        .count({ count: '*' });

      if (parseInt(count, 10) > 0) {
        throw new ConflictError('Movie has future scheduled shows. Archive or cancel shows first.');
      }
    }

    await movieRepository.delete(id);
  }

  /**
   * Get all published movies in a city with filters and pagination.
   * @param {number} cityId 
   * @param {object} filters 
   * @returns {Promise<object>}
   */
  async getPublishedMoviesByCity(cityId, filters) {
    return movieRepository.findPublishedMoviesByCity(cityId, filters);
  }

  /**
   * Get movie details by ID for public consumption (only if published).
   * @param {number} id 
   * @returns {Promise<object>}
   */
  async getMovieById(id) {
    const movie = await movieRepository.findById(id);
    if (!movie || movie.status !== 'published') {
      throw new NotFoundError('Movie with this ID does not exist.');
    }
    return movie;
  }
}

module.exports = new MovieService();
