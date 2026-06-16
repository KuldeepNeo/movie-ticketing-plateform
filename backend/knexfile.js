// Knex database configuration
module.exports = {
  development: {
    client: 'sqlite3',
    connection: {
      filename: process.env.DB_FILENAME || './database/dev.sqlite3'
    },
    useNullAsDefault: true,
    pool: {
      afterCreate: (conn, cb) => {
        // Enforce foreign key constraints and enable WAL mode for SQLite
        conn.run('PRAGMA foreign_keys = ON;', (err) => {
          if (err) return cb(err);
          conn.run('PRAGMA journal_mode = WAL;', cb);
        });
      }
    },
    migrations: {
      directory: './database/migrations'
    },
    seeds: {
      directory: './database/seeds'
    }
  },
  test: {
    client: 'sqlite3',
    connection: {
      filename: ':memory:'
    },
    useNullAsDefault: true,
    pool: {
      afterCreate: (conn, cb) => {
        conn.run('PRAGMA foreign_keys = ON;', cb);
      }
    },
    migrations: {
      directory: './database/migrations'
    },
    seeds: {
      directory: './database/seeds'
    }
  }
};
