/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = async function(knex) {
  // 1. Create cities table
  await knex.schema.createTable('cities', (table) => {
    table.increments('id').primary();
    table.string('name', 100).notNullable().unique();
    table.string('status', 50).notNullable().defaultTo('active');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();

    table.check('status IN (\'active\', \'inactive\')');
  });

  // 2. Create movies table
  await knex.schema.createTable('movies', (table) => {
    table.increments('id').primary();
    table.string('title', 255).notNullable();
    table.text('synopsis').notNullable();
    table.integer('runtime_minutes').notNullable();
    table.string('language', 50).notNullable();
    table.string('genre', 50).notNullable();
    table.string('age_rating', 20).notNullable();
    table.string('poster_url', 500).notNullable();
    table.string('banner_url', 500).notNullable();
    table.string('status', 50).notNullable().defaultTo('published');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();

    table.check('runtime_minutes > 0');
    table.check('age_rating IN (\'U\', \'U/A\', \'A\', \'PG-13\', \'R\')');
    table.check('status IN (\'draft\', \'published\', \'archived\')');

    table.index(['status', 'title'], 'idx_movies_status_title');
  });

  // 3. Create theaters table
  await knex.schema.createTable('theaters', (table) => {
    table.increments('id').primary();
    table.string('name', 255).notNullable();
    table.string('address', 500).notNullable();
    table.integer('city_id').notNullable()
      .references('id').inTable('cities')
      .onUpdate('CASCADE').onDelete('RESTRICT');
    table.string('area', 100).notNullable();
    table.string('status', 50).notNullable().defaultTo('active');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();

    table.check('status IN (\'active\', \'inactive\')');

    table.index(['city_id', 'status'], 'idx_theaters_city_status');
  });

  // 4. Create screens table
  await knex.schema.createTable('screens', (table) => {
    table.increments('id').primary();
    table.integer('theater_id').notNullable()
      .references('id').inTable('theaters')
      .onUpdate('CASCADE').onDelete('RESTRICT');
    table.string('name', 100).notNullable();
    table.integer('rows_count').notNullable();
    table.integer('columns_count').notNullable();
    table.string('status', 50).notNullable().defaultTo('active');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();

    table.check('rows_count > 0 AND rows_count <= 26');
    table.check('columns_count > 0 AND columns_count <= 50');
    table.check('status IN (\'active\', \'inactive\')');
  });

  // 5. Create seats table
  await knex.schema.createTable('seats', (table) => {
    table.increments('id').primary();
    table.integer('screen_id').notNullable()
      .references('id').inTable('screens')
      .onUpdate('CASCADE').onDelete('CASCADE');
    table.string('row_label', 10).notNullable();
    table.integer('column_number').notNullable();
    table.string('seat_category', 50).notNullable().defaultTo('classic');
    table.string('status', 50).notNullable().defaultTo('active');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();

    table.check('column_number > 0');
    table.check('seat_category IN (\'classic\', \'premium\', \'recliner\')');
    table.check('status IN (\'active\', \'inactive\')');

    table.unique(['screen_id', 'row_label', 'column_number'], 'idx_seats_layout_uq');
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = async function(knex) {
  await knex.schema.dropTableIfExists('seats');
  await knex.schema.dropTableIfExists('screens');
  await knex.schema.dropTableIfExists('theaters');
  await knex.schema.dropTableIfExists('movies');
  await knex.schema.dropTableIfExists('cities');
};
