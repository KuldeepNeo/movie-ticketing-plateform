const knex = require('knex');
const knexConfig = require('../../knexfile');
const env = require('./env');

const environment = env.NODE_ENV;
const config = knexConfig[environment];

if (!config) {
  throw new Error(`Knex configuration not found for environment: ${environment}`);
}

const db = knex(config);

module.exports = db;
