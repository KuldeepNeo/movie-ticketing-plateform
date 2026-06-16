const cityRepository = require('../repositories/cityRepository');

/**
 * Service layer managing city business flows.
 */
class CityService {
  /**
   * Retrieve list of all active cities.
   * @returns {Promise<object[]>}
   */
  async getActiveCities() {
    return cityRepository.findAllActive();
  }
}

module.exports = new CityService();
