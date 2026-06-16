const db = require('../config/db');
const showRepository = require('../repositories/showRepository');
const movieRepository = require('../repositories/movieRepository');
const screenRepository = require('../repositories/screenRepository');
const { NotFoundError, ConflictError, UnprocessableEntityError } = require('../utils/errors');

/**
 * Service layer orchestrating show management business flows.
 */
class ShowService {
  /**
   * Schedule a new show.
   * On creation, auto-populates show_seats transactional inventory.
   * @param {object} showData 
   * @returns {Promise<object>}
   */
  async createShow(showData) {
    // 1. Verify movie exists and is published
    const movie = await movieRepository.findById(showData.movie_id);
    if (!movie) {
      throw new NotFoundError('Movie with this ID does not exist.');
    }
    if (movie.status !== 'published') {
      throw new UnprocessableEntityError('Cannot schedule shows for a non-published movie.');
    }

    // 2. Verify screen exists and is active
    const screen = await screenRepository.findById(showData.screen_id);
    if (!screen) {
      throw new NotFoundError('Screen with this ID does not exist.');
    }
    if (screen.status !== 'active') {
      throw new UnprocessableEntityError('Cannot schedule shows on an inactive screen.');
    }

    // 3. Verify no scheduling overlap
    const isOverlapping = await showRepository.checkOverlap(
      showData.screen_id,
      showData.show_date,
      showData.start_time,
      showData.end_time,
      null
    );
    if (isOverlapping) {
      throw new UnprocessableEntityError('Overlapping show on the same screen and date.');
    }

    return db.transaction(async (trx) => {
      // 4. Create the show record
      const show = await showRepository.create(showData, trx);

      // 5. Generate show_seats inventory for all active physical seats
      const physicalSeats = await trx('seats')
        .where('screen_id', showData.screen_id)
        .where('status', 'active')
        .whereNull('deleted_at');

      const now = new Date().toISOString();
      const showSeatsPayload = physicalSeats.map(seat => ({
        show_id: show.id,
        seat_id: seat.id,
        status: 'available',
        created_at: now,
        updated_at: now
      }));

      if (showSeatsPayload.length > 0) {
        await trx('show_seats').insert(showSeatsPayload);
      }

      return {
        ...show,
        total_seats_created: showSeatsPayload.length
      };
    });
  }

  /**
   * Get all shows with paginated filtering.
   * @param {object} filters 
   * @returns {Promise<object>}
   */
  async getShows(filters) {
    return showRepository.findAll(filters);
  }

  /**
   * Update show details (timing, ticket price).
   * Allowed only if no bookings exist for the show.
   * @param {number} id 
   * @param {object} showData 
   * @returns {Promise<object>}
   */
  async updateShow(id, showData) {
    const show = await showRepository.findById(id);
    if (!show) {
      throw new NotFoundError('Show with this ID does not exist.');
    }

    // Check if bookings exist or show_seats have been locked/booked
    const bookedSeats = await db('show_seats')
      .where('show_id', id)
      .whereIn('status', ['locked', 'booked'])
      .count({ count: '*' })
      .first();

    const hasBookingsTable = await db.schema.hasTable('bookings');
    let hasBookings = parseInt(bookedSeats.count, 10) > 0;

    if (hasBookingsTable && !hasBookings) {
      const [{ count }] = await db('bookings')
        .where('show_id', id)
        .whereNot('status', 'failed')
        .count({ count: '*' });
      hasBookings = parseInt(count, 10) > 0;
    }

    if (hasBookings) {
      throw new ConflictError('Show has existing bookings. Cannot modify.');
    }

    // Validate overlap if timing or screen updates
    const finalScreenId = showData.screen_id !== undefined ? showData.screen_id : show.screen_id;
    const finalShowDate = showData.show_date !== undefined ? showData.show_date : show.show_date;
    const finalStartTime = showData.start_time !== undefined ? showData.start_time : show.start_time;
    const finalEndTime = showData.end_time !== undefined ? showData.end_time : show.end_time;

    if (showData.start_time || showData.end_time || showData.screen_id || showData.show_date) {
      const isOverlapping = await showRepository.checkOverlap(
        finalScreenId,
        finalShowDate,
        finalStartTime,
        finalEndTime,
        id
      );
      if (isOverlapping) {
        throw new UnprocessableEntityError('Updated time range overlaps with another show.');
      }
    }

    return showRepository.update(id, showData);
  }

  /**
   * Cancel/soft-delete a show.
   * Confirmed/pending bookings are set to cancelled.
   * @param {number} id 
   * @returns {Promise<object>}
   */
  async cancelShow(id) {
    const show = await showRepository.findById(id);
    if (!show) {
      throw new NotFoundError('Show with this ID does not exist.');
    }

    return db.transaction(async (trx) => {
      // 1. Cancel related bookings if table exists
      let affectedBookings = 0;
      const hasBookingsTable = await trx.schema.hasTable('bookings');
      if (hasBookingsTable) {
        affectedBookings = await trx('bookings')
          .where('show_id', id)
          .whereIn('status', ['initiated', 'seats_locked', 'payment_pending', 'confirmed'])
          .update({
            status: 'cancelled',
            updated_at: new Date().toISOString()
          });
      }

      // 2. Soft-delete the show
      await showRepository.delete(id, trx);

      // Note: show_seats cascade deletion is handled via foreign key cascade on database layer,
      // or we can explicitly delete show_seats in database if wanted. Since sqlite FK CASCADE is enabled,
      // deleting the show would cascade delete show_seats, but wait, shows are SOFT-DELETED (deleted_at set),
      // not physically deleted.
      // So we should manually set show_seats status or keep them. If a show is cancelled, the seats are not bookable.
      // To prevent orphans or stale locks, we can free all locked seats for this show:
      await trx('show_seats')
        .where('show_id', id)
        .update({
          status: 'available',
          booking_id: null,
          locked_until: null
        });

      return {
        message: 'Show cancelled successfully.',
        affected_bookings: affectedBookings
      };
    });
  }
}

module.exports = new ShowService();
