const db = require('../config/db');

/**
 * Repository layer for shows table data access.
 */
class ShowRepository {
  /**
   * Create a new show record.
   * Note: This can accept an optional transaction context (trx).
   * @param {object} showData 
   * @param {object} [trx]
   * @returns {Promise<object>}
   */
  async create(showData, trx = db) {
    const now = new Date().toISOString();
    const [id] = await trx('shows').insert({
      movie_id: showData.movie_id,
      screen_id: showData.screen_id,
      show_date: showData.show_date,
      start_time: showData.start_time,
      end_time: showData.end_time,
      ticket_price: showData.ticket_price,
      status: showData.status || 'scheduled',
      created_at: now,
      updated_at: now
    });

    return this.findById(id, trx);
  }

  /**
   * Find a show by ID.
   * @param {number} id 
   * @param {object} [trx]
   * @returns {Promise<object|undefined>}
   */
  async findById(id, trx = db) {
    return trx('shows')
      .where('id', id)
      .whereNull('deleted_at')
      .first();
  }

  /**
   * Find all shows matching the given filters (paginated).
   * @param {object} filters 
   * @returns {Promise<{data: object[], total: number}>}
   */
  async findAll(filters = {}) {
    const page = parseInt(filters.page, 10) || 1;
    const limit = Math.min(parseInt(filters.limit, 10) || 20, 50);
    const offset = (page - 1) * limit;

    const countQuery = db('shows').whereNull('deleted_at');
    const dataQuery = db('shows').whereNull('deleted_at');

    if (filters.movie_id) {
      countQuery.where('movie_id', filters.movie_id);
      dataQuery.where('movie_id', filters.movie_id);
    }

    if (filters.screen_id) {
      countQuery.where('screen_id', filters.screen_id);
      dataQuery.where('screen_id', filters.screen_id);
    }

    if (filters.status) {
      countQuery.where('status', filters.status);
      dataQuery.where('status', filters.status);
    }

    if (filters.show_date) {
      countQuery.where('show_date', filters.show_date);
      dataQuery.where('show_date', filters.show_date);
    }

    const [{ count }] = await countQuery.count({ count: '*' });
    const data = await dataQuery
      .select('*')
      .limit(limit)
      .offset(offset)
      .orderBy('start_time', 'asc');

    return {
      data,
      total: parseInt(count, 10)
    };
  }

  /**
   * Update a show record.
   * @param {number} id 
   * @param {object} showData 
   * @param {object} [trx]
   * @returns {Promise<object|undefined>}
   */
  async update(id, showData, trx = db) {
    const now = new Date().toISOString();
    const updatePayload = {
      ...showData,
      updated_at: now
    };

    await trx('shows')
      .where('id', id)
      .whereNull('deleted_at')
      .update(updatePayload);

    return this.findById(id, trx);
  }

  /**
   * Soft-delete a show record by ID.
   * @param {number} id 
   * @param {object} [trx]
   * @returns {Promise<boolean>}
   */
  async delete(id, trx = db) {
    const now = new Date().toISOString();
    const affected = await trx('shows')
      .where('id', id)
      .whereNull('deleted_at')
      .update({
        deleted_at: now,
        updated_at: now
      });

    return affected > 0;
  }

  /**
   * Check if there are any overlapping shows on the same screen and date.
   * Overlap definition: existing.start_time < new.end_time AND new.start_time < existing.end_time
   * @param {number} screenId 
   * @param {string} showDate 
   * @param {string} startTime 
   * @param {string} endTime 
   * @param {number} [excludeShowId] 
   * @returns {Promise<boolean>}
   */
  async checkOverlap(screenId, showDate, startTime, endTime, excludeShowId) {
    const query = db('shows')
      .where('screen_id', screenId)
      .where('show_date', showDate)
      .whereNull('deleted_at')
      .where('start_time', '<', endTime)
      .where('end_time', '>', startTime);

    if (excludeShowId) {
      query.whereNot('id', excludeShowId);
    }

    const existing = await query.first();
    return !!existing;
  }
}

module.exports = new ShowRepository();
