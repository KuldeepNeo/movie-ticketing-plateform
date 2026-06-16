const db = require('../config/db');

/**
 * Repository layer for screens table data access.
 */
class ScreenRepository {
  /**
   * Create a new screen record, optional transaction support.
   * @param {object} screenData 
   * @param {object} [trx] 
   * @returns {Promise<object>}
   */
  async create(screenData, trx) {
    const now = new Date().toISOString();
    const query = trx ? db('screens').transacting(trx) : db('screens');
    
    const [id] = await query.insert({
      theater_id: screenData.theater_id,
      name: screenData.name,
      rows_count: screenData.rows_count,
      columns_count: screenData.columns_count,
      status: screenData.status || 'active',
      created_at: now,
      updated_at: now
    });

    return this.findById(id, trx);
  }

  /**
   * Find screens by theater ID, filtering out soft-deleted records.
   * @param {number} theaterId 
   * @returns {Promise<object[]>}
   */
  async findByTheaterId(theaterId) {
    return db('screens')
      .where('theater_id', theaterId)
      .whereNull('deleted_at')
      .orderBy('id', 'asc');
  }

  /**
   * Find a screen by ID, filtering out soft-deleted records.
   * @param {number} id 
   * @param {object} [trx]
   * @returns {Promise<object|undefined>}
   */
  async findById(id, trx) {
    const query = trx ? db('screens').transacting(trx) : db('screens');
    return query
      .where('id', id)
      .whereNull('deleted_at')
      .first();
  }

  /**
   * Update screen record.
   * @param {number} id 
   * @param {object} screenData 
   * @returns {Promise<object|undefined>}
   */
  async update(id, screenData) {
    const now = new Date().toISOString();
    const updatePayload = {
      ...screenData,
      updated_at: now
    };

    await db('screens')
      .where('id', id)
      .whereNull('deleted_at')
      .update(updatePayload);

    return this.findById(id);
  }

  /**
   * Soft delete a screen record.
   * @param {number} id 
   * @returns {Promise<boolean>}
   */
  async delete(id) {
    const now = new Date().toISOString();
    const affectedRows = await db('screens')
      .where('id', id)
      .whereNull('deleted_at')
      .update({
        deleted_at: now,
        updated_at: now
      });

    return affectedRows > 0;
  }
}

module.exports = new ScreenRepository();
