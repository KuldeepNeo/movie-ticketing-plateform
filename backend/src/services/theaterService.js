const theaterRepository = require('../repositories/theaterRepository');
const cityRepository = require('../repositories/cityRepository');
const { NotFoundError, ConflictError } = require('../utils/errors');
const db = require('../config/db');

/**
 * Service layer orchestrating theater management business flows.
 */
class TheaterService {
  /**
   * Create a new theater, validating its city reference.
   * @param {object} theaterData 
   * @returns {Promise<object>}
   */
  async createTheater(theaterData) {
    const city = await cityRepository.findById(theaterData.city_id);
    if (!city || city.status !== 'active') {
      throw new NotFoundError('Referenced city does not exist.');
    }

    return theaterRepository.create(theaterData);
  }

  /**
   * List all theaters.
   * @param {object} filters 
   * @returns {Promise<object[]>}
   */
  async getAdminTheaters(filters) {
    return theaterRepository.findAll(filters);
  }

  /**
   * Update theater details.
   * @param {number} id 
   * @param {object} theaterData 
   * @returns {Promise<object>}
   */
  async updateTheater(id, theaterData) {
    const theater = await theaterRepository.findById(id);
    if (!theater) {
      throw new NotFoundError('Theater with this ID does not exist.');
    }

    if (theaterData.city_id) {
      const city = await cityRepository.findById(theaterData.city_id);
      if (!city || city.status !== 'active') {
        throw new NotFoundError('Referenced city does not exist.');
      }
    }

    return theaterRepository.update(id, theaterData);
  }

  /**
   * Soft-delete a theater, checking for screens or shows dependencies.
   * @param {number} id 
   * @returns {Promise<void>}
   */
  async deleteTheater(id) {
    const theater = await theaterRepository.findById(id);
    if (!theater) {
      throw new NotFoundError('Theater with this ID does not exist.');
    }

    // Check if there are active screens in this theater
    const activeScreens = await db('screens')
      .where('theater_id', id)
      .whereNull('deleted_at');

    if (activeScreens.length > 0) {
      throw new ConflictError('Theater has active screens or scheduled shows.');
    }

    // Check for shows dependencies if shows table exists
    const hasShowsTable = await db.schema.hasTable('shows');
    if (hasShowsTable) {
      // Find all screen IDs for this theater (including soft deleted ones or not, but let's check screens under this theater)
      const allScreens = await db('screens').where('theater_id', id);
      const screenIds = allScreens.map(s => s.id);
      if (screenIds.length > 0) {
        const today = new Date().toISOString().split('T')[0];
        const [{ count }] = await db('shows')
          .whereIn('screen_id', screenIds)
          .where('show_date', '>=', today)
          .whereNull('deleted_at')
          .count({ count: '*' });

        if (parseInt(count, 10) > 0) {
          throw new ConflictError('Theater has active screens or scheduled shows.');
        }
      }
    }

    await theaterRepository.delete(id);
  }
}

module.exports = new TheaterService();
