const dotenv = require('dotenv');
const path = require('path');
const zod = require('zod');

// Load environment variables from the root .env file
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const envSchema = zod.object({
  PORT: zod.coerce.number().default(3000),
  NODE_ENV: zod.enum(['development', 'production', 'test']).default('development'),
  DB_CLIENT: zod.string().default('sqlite3'),
  DB_FILENAME: zod.string().default('./database/dev.sqlite3'),
  JWT_ACCESS_SECRET: zod.string().default('default_access_secret_key_change_me_in_prod'),
  JWT_REFRESH_SECRET: zod.string().default('default_refresh_secret_key_change_me_in_prod'),
  JWT_ACCESS_EXPIRES_IN: zod.string().default('15m'),
  JWT_REFRESH_EXPIRES_IN: zod.string().default('7d'),
  CORS_ORIGIN: zod.string().default('http://localhost:8080')
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('❌ Invalid environment configuration:', parsed.error.format());
  process.exit(1);
}

module.exports = parsed.data;
