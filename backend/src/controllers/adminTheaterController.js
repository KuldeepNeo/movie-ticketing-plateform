const theaterService = require('../services/theaterService');
const responseHelper = require('../utils/responseHelper');

/**
 * Controller class managing HTTP endpoints for Admin Theater management.
 */
class AdminTheaterController {
  /**
   * GET /api/v1/admin/theaters
   */
  async getTheaters(req, res, next) {
    try {
      const { city_id, status } = req.query;
      const filters = {};
      if (city_id) filters.city_id = parseInt(city_id, 10);
      if (status) filters.status = status;

      const theaters = await theaterService.getAdminTheaters(filters);
      return responseHelper.success(res, theaters, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * POST /api/v1/admin/theaters
   */
  async createTheater(req, res, next) {
    try {
      const theater = await theaterService.createTheater(req.body);
      return responseHelper.success(res, theater, 201);
    } catch (err) {
      next(err);
    }
  }

  /**
   * PUT /api/v1/admin/theaters/:id
   */
  async updateTheater(req, res, next) {
    try {
      const { id } = req.params;
      const theater = await theaterService.updateTheater(parseInt(id, 10), req.body);
      return responseHelper.success(res, theater, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * DELETE /api/v1/admin/theaters/:id
   */
  async deleteTheater(req, res, next) {
    try {
      const { id } = req.params;
      await theaterService.deleteTheater(parseInt(id, 10));
      return responseHelper.success(res, { message: 'Theater deleted successfully.' }, 200);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AdminTheaterController();
