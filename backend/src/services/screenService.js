const screenRepository = require('../repositories/screenRepository');
const theaterRepository = require('../repositories/theaterRepository');
const seatRepository = require('../repositories/seatRepository');
const { NotFoundError, ConflictError } = require('../utils/errors');
const db = require('../config/db');

/**
 * Helper to determine category for a row label using the seat_categories map.
 * @param {string} rowLabel 
 * @param {object} seatCategories 
 * @returns {string}
 */
function getCategoryForRange(rowLabel, seatCategories = {}) {
  for (const range of Object.keys(seatCategories)) {
    const parts = range.split('-');
    if (parts.length === 2) {
      const start = parts[0].trim().toUpperCase();
      const end = parts[1].trim().toUpperCase();
      if (rowLabel >= start && rowLabel <= end) {
        return seatCategories[range].toLowerCase();
      }
    } else if (parts.length === 1) {
      const row = parts[0].trim().toUpperCase();
      if (rowLabel === row) {
        return seatCategories[range].toLowerCase();
      }
    }
  }
  return 'classic';
}

/**
 * Service layer orchestrating screen management and seat generation.
 */
class ScreenService {
  /**
   * Create a new screen and automatically generate seat records in a transaction.
   * @param {number} theaterId 
   * @param {object} screenData 
   * @returns {Promise<object>}
   */
  async createScreen(theaterId, screenData) {
    const theater = await theaterRepository.findById(theaterId);
    if (!theater) {
      throw new NotFoundError('Theater with this ID does not exist.');
    }

    // Start database transaction
    return db.transaction(async (trx) => {
      // 1. Create the screen record
      const screen = await screenRepository.create({
        theater_id: theaterId,
        name: screenData.name,
        rows_count: screenData.rows_count,
        columns_count: screenData.columns_count,
        status: screenData.status || 'active'
      }, trx);

      // 2. Generate seats array
      const seats = [];
      const now = new Date().toISOString();
      const { rows_count, columns_count, seat_categories } = screenData;

      for (let r = 0; r < rows_count; r++) {
        const rowLabel = String.fromCharCode(65 + r); // A to Z
        const category = getCategoryForRange(rowLabel, seat_categories);
        
        for (let c = 1; c <= columns_count; c++) {
          seats.push({
            screen_id: screen.id,
            row_label: rowLabel,
            column_number: c,
            seat_category: category,
            status: 'active',
            created_at: now,
            updated_at: now
          });
        }
      }

      // 3. Bulk create seats
      await seatRepository.bulkCreate(seats, trx);

      // 4. Return screen along with total seats count
      const totalSeats = await seatRepository.countByScreenId(screen.id, trx);
      return {
        id: screen.id,
        theater_id: screen.theater_id,
        name: screen.name,
        rows_count: screen.rows_count,
        columns_count: screen.columns_count,
        total_seats: totalSeats,
        status: screen.status,
        created_at: screen.created_at
      };
    });
  }

  /**
   * List all active screens for a theater.
   * @param {number} theaterId 
   * @returns {Promise<object[]>}
   */
  async getScreensByTheaterId(theaterId) {
    const theater = await theaterRepository.findById(theaterId);
    if (!theater) {
      throw new NotFoundError('Theater with this ID does not exist.');
    }

    return screenRepository.findByTheaterId(theaterId);
  }

  /**
   * Update screen details.
   * @param {number} id 
   * @param {object} screenData 
   * @returns {Promise<object>}
   */
  async updateScreen(id, screenData) {
    const screen = await screenRepository.findById(id);
    if (!screen) {
      throw new NotFoundError('Screen with this ID does not exist.');
    }

    return screenRepository.update(id, screenData);
  }

  /**
   * Soft-delete a screen, checking for shows dependencies.
   * @param {number} id 
   * @returns {Promise<void>}
   */
  async deleteScreen(id) {
    const screen = await screenRepository.findById(id);
    if (!screen) {
      throw new NotFoundError('Screen with this ID does not exist.');
    }

    // Check if screen has future scheduled shows
    const hasShowsTable = await db.schema.hasTable('shows');
    if (hasShowsTable) {
      const today = new Date().toISOString().split('T')[0];
      const [{ count }] = await db('shows')
        .where('screen_id', id)
        .where('show_date', '>=', today)
        .whereNull('deleted_at')
        .count({ count: '*' });

      if (parseInt(count, 10) > 0) {
        throw new ConflictError('Screen has future scheduled shows.');
      }
    }

    await screenRepository.delete(id);
  }
}

module.exports = new ScreenService();
