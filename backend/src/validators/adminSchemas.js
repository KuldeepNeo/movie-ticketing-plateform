const { z } = require('zod');

/**
 * Zod validation schema for POST /api/v1/admin/movies
 */
const movieCreateSchema = z.object({
  title: z
    .string({ required_error: 'Title is required.' })
    .min(1, 'Title must be at least 1 character.')
    .max(255, 'Title must not exceed 255 characters.'),
  synopsis: z
    .string({ required_error: 'Synopsis is required.' })
    .min(10, 'Synopsis must be at least 10 characters.')
    .max(5000, 'Synopsis must not exceed 5000 characters.'),
  runtime_minutes: z
    .number({ required_error: 'Runtime is required.' })
    .int('Runtime must be an integer.')
    .positive('Runtime must be greater than 0.'),
  language: z
    .string({ required_error: 'Language is required.' })
    .max(50, 'Language must not exceed 50 characters.'),
  genre: z
    .string({ required_error: 'Genre is required.' })
    .max(50, 'Genre must not exceed 50 characters.'),
  age_rating: z
    .enum(['U', 'U/A', 'A', 'PG-13', 'R'], {
      required_error: 'Age rating is required.',
      invalid_enum_value: 'Invalid age rating. Allowed: U, U/A, A, PG-13, R.'
    }),
  poster_url: z
    .string({ required_error: 'Poster URL is required.' })
    .url('Poster URL must be a valid URL.'),
  banner_url: z
    .string({ required_error: 'Banner URL is required.' })
    .url('Banner URL must be a valid URL.'),
  status: z
    .enum(['draft', 'published', 'archived'])
    .optional()
    .default('draft')
});

/**
 * Zod validation schema for PUT /api/v1/admin/movies/:id
 */
const movieUpdateSchema = movieCreateSchema.partial();

/**
 * Zod validation schema for POST /api/v1/admin/theaters
 */
const theaterCreateSchema = z.object({
  name: z
    .string({ required_error: 'Theater name is required.' })
    .min(2, 'Theater name must be at least 2 characters.')
    .max(255, 'Theater name must not exceed 255 characters.'),
  address: z
    .string({ required_error: 'Address is required.' })
    .min(5, 'Address must be at least 5 characters.')
    .max(500, 'Address must not exceed 500 characters.'),
  city_id: z
    .number({ required_error: 'City ID is required.' })
    .int('City ID must be an integer.'),
  area: z
    .string({ required_error: 'Area is required.' })
    .min(2, 'Area must be at least 2 characters.')
    .max(100, 'Area must not exceed 100 characters.'),
  status: z
    .enum(['active', 'inactive'])
    .optional()
    .default('active')
});

/**
 * Zod validation schema for PUT /api/v1/admin/theaters/:id
 */
const theaterUpdateSchema = theaterCreateSchema.partial();

/**
 * Zod validation schema for POST /api/v1/admin/theaters/:theaterId/screens
 */
const screenCreateSchema = z.object({
  name: z
    .string({ required_error: 'Screen name is required.' })
    .min(1, 'Screen name must be at least 1 character.')
    .max(100, 'Screen name must not exceed 100 characters.'),
  rows_count: z
    .number({ required_error: 'Rows count is required.' })
    .int('Rows count must be an integer.')
    .min(1, 'Rows count must be at least 1.')
    .max(26, 'Rows count must not exceed 26.'),
  columns_count: z
    .number({ required_error: 'Columns count is required.' })
    .int('Columns count must be an integer.')
    .min(1, 'Columns count must be at least 1.')
    .max(50, 'Columns count must not exceed 50.'),
  seat_categories: z
    .record(
      z.string(),
      z.enum(['classic', 'premium', 'recliner'], {
        invalid_enum_value: 'Invalid seat category. Allowed: classic, premium, recliner.'
      })
    )
    .optional()
});

/**
 * Zod validation schema for PUT /api/v1/admin/screens/:id
 */
const screenUpdateSchema = z.object({
  name: z
    .string()
    .min(1, 'Screen name must be at least 1 character.')
    .max(100, 'Screen name must not exceed 100 characters.')
    .optional(),
  status: z
    .enum(['active', 'inactive'])
    .optional()
});

module.exports = {
  movieCreateSchema,
  movieUpdateSchema,
  theaterCreateSchema,
  theaterUpdateSchema,
  screenCreateSchema,
  screenUpdateSchema
};
