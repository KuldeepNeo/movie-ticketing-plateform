const db = require('../config/db');

/**
 * Repository layer for theaters table data access.
 */
class TheaterRepository {
  /**
   * Create a new theater record.
   * @param {object} theaterData 
   * @returns {Promise<object>}
   */
  async create(theaterData) {
    const now = new Date().toISOString();
    const [id] = await db('theaters').insert({
      name: theaterData.name,
      address: theaterData.address,
      city_id: theaterData.city_id,
      area: theaterData.area,
      status: theaterData.status || 'active',
      created_at: now,
      updated_at: now
    });

    return this.findById(id);
  }

  /**
   * Find all theaters with optional filtering, filtering out soft-deleted records.
   * @param {object} filters 
   * @returns {Promise<object[]>}
   */
  async findAll(filters = {}) {
    const query = db('theaters').whereNull('deleted_at');

    if (filters.city_id) {
      query.where('city_id', filters.city_id);
    }
    if (filters.status) {
      query.where('status', filters.status);
    }

    return query.select('*').orderBy('id', 'desc');
  }

  /**
   * Find a theater by ID, filtering out soft-deleted records.
   * @param {number} id 
   * @returns {Promise<object|undefined>}
   */
  async findById(id) {
    return db('theaters')
      .where('id', id)
      .whereNull('deleted_at')
      .first();
  }

  /**
   * Update theater record.
   * @param {number} id 
   * @param {object} theaterData 
   * @returns {Promise<object|undefined>}
   */
  async update(id, theaterData) {
    const now = new Date().toISOString();
    const updatePayload = {
      ...theaterData,
      updated_at: now
    };

    await db('theaters')
      .where('id', id)
      .whereNull('deleted_at')
      .update(updatePayload);

    return this.findById(id);
  }

  /**
   * Soft delete a theater record.
   * @param {number} id 
   * @returns {Promise<boolean>}
   */
  async delete(id) {
    const now = new Date().toISOString();
    const affectedRows = await db('theaters')
      .where('id', id)
      .whereNull('deleted_at')
      .update({
        deleted_at: now,
        updated_at: now
      });

    return affectedRows > 0;
  }
}

module.exports = new TheaterRepository();
