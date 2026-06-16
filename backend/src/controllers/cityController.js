const cityService = require('../services/cityService');
const responseHelper = require('../utils/responseHelper');

/**
 * Controller class managing HTTP endpoints for cities.
 */
class CityController {
  /**
   * GET /api/v1/cities
   */
  async getCities(req, res, next) {
    try {
      const cities = await cityService.getActiveCities();
      return responseHelper.success(res, cities, 200);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new CityController();
