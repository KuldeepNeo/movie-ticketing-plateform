const movieService = require('../services/movieService');
const responseHelper = require('../utils/responseHelper');

/**
 * Controller class managing HTTP endpoints for Admin Movie management.
 */
class AdminMovieController {
  /**
   * GET /api/v1/admin/movies
   */
  async getMovies(req, res, next) {
    try {
      const { status, search, page, limit } = req.query;
      const filters = {
        status,
        search,
        page: parseInt(page, 10) || 1,
        limit: Math.min(parseInt(limit, 10) || 20, 50)
      };

      const result = await movieService.getAdminMovies(filters);
      const totalPages = Math.ceil(result.total / filters.limit);

      return res.status(200).json({
        status: 'success',
        data: result.data,
        meta: {
          page: filters.page,
          limit: filters.limit,
          total: result.total,
          total_pages: totalPages || 1
        }
      });
    } catch (err) {
      next(err);
    }
  }

  /**
   * POST /api/v1/admin/movies
   */
  async createMovie(req, res, next) {
    try {
      const movie = await movieService.createMovie(req.body);
      return responseHelper.success(res, movie, 201);
    } catch (err) {
      next(err);
    }
  }

  /**
   * PUT /api/v1/admin/movies/:id
   */
  async updateMovie(req, res, next) {
    try {
      const { id } = req.params;
      const movie = await movieService.updateMovie(parseInt(id, 10), req.body);
      return responseHelper.success(res, movie, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * DELETE /api/v1/admin/movies/:id
   */
  async deleteMovie(req, res, next) {
    try {
      const { id } = req.params;
      await movieService.deleteMovie(parseInt(id, 10));
      return responseHelper.success(res, { message: 'Movie deleted successfully.' }, 200);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AdminMovieController();
