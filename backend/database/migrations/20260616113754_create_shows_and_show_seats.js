/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = async function(knex) {
  // 1. Create shows table
  await knex.schema.createTable('shows', (table) => {
    table.increments('id').primary();
    table.integer('movie_id').notNullable()
      .references('id').inTable('movies')
      .onUpdate('CASCADE').onDelete('RESTRICT');
    table.integer('screen_id').notNullable()
      .references('id').inTable('screens')
      .onUpdate('CASCADE').onDelete('RESTRICT');
    table.string('show_date', 50).notNullable();
    table.string('start_time', 50).notNullable();
    table.string('end_time', 50).notNullable();
    table.integer('ticket_price').notNullable();
    table.string('status', 50).notNullable().defaultTo('scheduled');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();

    table.check('ticket_price >= 0');
    table.check('status IN (\'scheduled\', \'active\', \'completed\', \'cancelled\')');
    table.check('end_time > start_time');

    table.index(['screen_id', 'show_date', 'start_time'], 'idx_shows_screen_time');
    table.index(['movie_id', 'show_date'], 'idx_shows_movie_date');
  });

  // 2. Create show_seats table
  await knex.schema.createTable('show_seats', (table) => {
    table.increments('id').primary();
    table.integer('show_id').notNullable()
      .references('id').inTable('shows')
      .onUpdate('CASCADE').onDelete('CASCADE');
    table.integer('seat_id').notNullable()
      .references('id').inTable('seats')
      .onUpdate('CASCADE').onDelete('RESTRICT');
    table.integer('booking_id').nullable(); // foreign key references bookings(id) will be added when bookings table is created in Sprint 4
    table.string('status', 50).notNullable().defaultTo('available');
    table.string('locked_until', 50).nullable();
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();

    table.check('status IN (\'available\', \'locked\', \'booked\')');

    table.unique(['show_id', 'seat_id'], 'idx_show_seats_uq');
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = async function(knex) {
  await knex.schema.dropTableIfExists('show_seats');
  await knex.schema.dropTableIfExists('shows');
};
