const db = require('../config/db');

/**
 * Repository layer for cities table data access.
 */
class CityRepository {
  /**
   * Find all active cities, filtering out soft-deleted and inactive records.
   * @returns {Promise<object[]>}
   */
  async findAllActive() {
    return db('cities')
      .where('status', 'active')
      .whereNull('deleted_at')
      .select('id', 'name');
  }

  /**
   * Find city by ID, filtering out soft-deleted records.
   * @param {number} id 
   * @returns {Promise<object|undefined>}
   */
  async findById(id) {
    return db('cities')
      .where('id', id)
      .whereNull('deleted_at')
      .first();
  }
}

module.exports = new CityRepository();
