const db = require('../config/db');

/**
 * Repository layer for seats table data access.
 */
class SeatRepository {
  /**
   * Bulk insert seat records, transactional support.
   * @param {object[]} seats 
   * @param {object} trx 
   * @returns {Promise<void>}
   */
  async bulkCreate(seats, trx) {
    const query = db('seats').transacting(trx);
    
    // SQLite supports bulk inserts out-of-the-box via Knex
    await query.insert(seats);
  }

  /**
   * Count active seats in a screen.
   * @param {number} screenId 
   * @param {object} [trx]
   * @returns {Promise<number>}
   */
  async countByScreenId(screenId, trx) {
    const query = trx ? db('seats').transacting(trx) : db('seats');
    const result = await query
      .where('screen_id', screenId)
      .whereNull('deleted_at')
      .count({ count: '*' });
    return parseInt(result[0].count, 10);
  }
}

module.exports = new SeatRepository();
