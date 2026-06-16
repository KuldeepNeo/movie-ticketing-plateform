/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('users', (table) => {
    table.increments('id').primary();
    table.string('name', 100).notNullable();
    table.string('email', 255).notNullable().unique().collate('NOCASE');
    table.string('password_hash', 255).notNullable();
    table.string('role', 50).notNullable().defaultTo('customer');
    table.string('created_at', 50).notNullable();
    table.string('updated_at', 50).notNullable();
    table.string('deleted_at', 50).nullable();
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTableIfExists('users');
};
