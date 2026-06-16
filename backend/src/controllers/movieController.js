const { z } = require('zod');
const movieService = require('../services/movieService');
const responseHelper = require('../utils/responseHelper');

const movieQuerySchema = z.object({
  city_id: z.preprocess(
    (val) => (val === undefined ? undefined : Number(val)),
    z.number({ required_error: 'City ID is required.' }).int('City ID must be an integer.')
  ),
  search: z.string().optional(),
  language: z.string().optional(),
  genre: z.string().optional(),
  age_rating: z.string().optional(),
  sort_by: z.enum(['title', 'rating', 'release_date']).optional().default('title'),
  sort_order: z.enum(['asc', 'desc']).optional().default('asc'),
  page: z.preprocess(
    (val) => (val === undefined ? undefined : Number(val)),
    z.number().int().positive().optional().default(1)
  ),
  limit: z.preprocess(
    (val) => (val === undefined ? undefined : Number(val)),
    z.number().int().positive().max(50).optional().default(20)
  )
});

class MovieController {
  /**
   * GET /api/v1/movies
   * List movies currently scheduled in the user's active city.
   */
  async getMovies(req, res, next) {
    try {
      const query = movieQuerySchema.parse(req.query);
      const result = await movieService.getPublishedMoviesByCity(query.city_id, query);
      
      const totalPages = Math.ceil(result.total / query.limit);

      return responseHelper.success(res, result.data, 200, {
        page: query.page,
        limit: query.limit,
        total: result.total,
        total_pages: totalPages || 1
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/v1/movies/:id
   * Get detailed information for a specific movie.
   */
  async getMovieById(req, res, next) {
    try {
      const id = parseInt(req.params.id, 10);
      if (isNaN(id)) {
        const { ValidationError } = require('../utils/errors');
        throw new ValidationError('Invalid movie ID format.');
      }
      const movie = await movieService.getMovieById(id);
      return responseHelper.success(res, movie, 200);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new MovieController();
