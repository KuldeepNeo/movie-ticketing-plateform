const showService = require('../services/showService');
const responseHelper = require('../utils/responseHelper');

/**
 * Controller class managing administrative show scheduling routes.
 */
class AdminShowController {
  /**
   * Schedule a new show.
   */
  async createShow(req, res, next) {
    try {
      const showData = req.body;
      const result = await showService.createShow(showData);
      return responseHelper.success(res, result, 201);
    } catch (error) {
      next(error);
    }
  }

  /**
   * List all shows with filters and pagination.
   */
  async getShows(req, res, next) {
    try {
      const filters = {
        movie_id: req.query.movie_id ? parseInt(req.query.movie_id, 10) : undefined,
        screen_id: req.query.screen_id ? parseInt(req.query.screen_id, 10) : undefined,
        status: req.query.status,
        show_date: req.query.show_date,
        page: req.query.page,
        limit: req.query.limit
      };

      const result = await showService.getShows(filters);
      return responseHelper.success(res, result.data, 200, {
        page: parseInt(req.query.page, 10) || 1,
        limit: Math.min(parseInt(req.query.limit, 10) || 20, 50),
        total: result.total
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update show details.
   */
  async updateShow(req, res, next) {
    try {
      const id = parseInt(req.params.id, 10);
      const showData = req.body;
      const result = await showService.updateShow(id, showData);
      return responseHelper.success(res, result, 200);
    } catch (error) {
      next(error);
    }
  }

  /**
   * Cancel/soft-delete a show.
   */
  async deleteShow(req, res, next) {
    try {
      const id = parseInt(req.params.id, 10);
      const result = await showService.cancelShow(id);
      return responseHelper.success(res, result, 200);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AdminShowController();
