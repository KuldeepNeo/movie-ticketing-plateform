const db = require('../config/db');

/**
 * Repository layer for users table data access.
 */
class UserRepository {
  /**
   * Create a new user record in the database.
   * @param {object} userData 
   * @returns {Promise<object>}
   */
  async create(userData) {
    const now = new Date().toISOString();
    
    const [id] = await db('users').insert({
      name: userData.name,
      email: userData.email.toLowerCase().trim(), // Normalize email input
      password_hash: userData.password_hash,
      role: userData.role || 'customer',
      created_at: now,
      updated_at: now
    });

    return this.findById(id);
  }

  /**
   * Find a user by email address, filtering out soft-deleted users.
   * @param {string} email 
   * @returns {Promise<object|undefined>}
   */
  async findByEmail(email) {
    return db('users')
      .where('email', email.toLowerCase().trim())
      .whereNull('deleted_at')
      .first();
  }

  /**
   * Find a user by ID, filtering out soft-deleted users.
   * @param {number} id 
   * @returns {Promise<object|undefined>}
   */
  async findById(id) {
    return db('users')
      .where('id', id)
      .whereNull('deleted_at')
      .first();
  }
}

module.exports = new UserRepository();
