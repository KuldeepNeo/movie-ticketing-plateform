const screenService = require('../services/screenService');
const responseHelper = require('../utils/responseHelper');

/**
 * Controller class managing HTTP endpoints for Admin Screen management.
 */
class AdminScreenController {
  /**
   * GET /api/v1/admin/theaters/:theaterId/screens
   */
  async getScreens(req, res, next) {
    try {
      const { theaterId } = req.params;
      const screens = await screenService.getScreensByTheaterId(parseInt(theaterId, 10));
      return responseHelper.success(res, screens, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * POST /api/v1/admin/theaters/:theaterId/screens
   */
  async createScreen(req, res, next) {
    try {
      const { theaterId } = req.params;
      const screen = await screenService.createScreen(parseInt(theaterId, 10), req.body);
      return responseHelper.success(res, screen, 201);
    } catch (err) {
      next(err);
    }
  }

  /**
   * PUT /api/v1/admin/screens/:id
   */
  async updateScreen(req, res, next) {
    try {
      const { id } = req.params;
      const screen = await screenService.updateScreen(parseInt(id, 10), req.body);
      return responseHelper.success(res, screen, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * DELETE /api/v1/admin/screens/:id
   */
  async deleteScreen(req, res, next) {
    try {
      const { id } = req.params;
      await screenService.deleteScreen(parseInt(id, 10));
      return responseHelper.success(res, { message: 'Screen deleted successfully.' }, 200);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AdminScreenController();
