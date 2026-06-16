const bcrypt = require('bcrypt');

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('users').del();

  const adminPasswordHash = await bcrypt.hash('SecureP@ss1', 12);
  const customerPasswordHash = await bcrypt.hash('SecureP@ss1', 12);

  const now = new Date().toISOString();

  await knex('users').insert([
    {
      id: 1,
      name: 'System Admin',
      email: 'admin@example.com',
      password_hash: adminPasswordHash,
      role: 'admin',
      created_at: now,
      updated_at: now
    },
    {
      id: 2,
      name: 'John Doe',
      email: 'john@example.com',
      password_hash: customerPasswordHash,
      role: 'customer',
      created_at: now,
      updated_at: now
    }
  ]);
};
