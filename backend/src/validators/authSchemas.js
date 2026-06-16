const { z } = require('zod');

/**
 * Zod validation schema for POST /api/v1/auth/register
 */
const registerSchema = z.object({
  name: z
    .string({ required_error: 'Name is required.' })
    .min(2, 'Name must be at least 2 characters.')
    .max(100, 'Name must not exceed 100 characters.'),
  email: z
    .string({ required_error: 'Email is required.' })
    .email('Invalid email address.')
    .max(255, 'Email must not exceed 255 characters.'),
  password: z
    .string({ required_error: 'Password is required.' })
    .min(8, 'Password must be at least 8 characters.')
    .regex(/[A-Z]/, 'Password must contain at least 1 uppercase character.')
    .regex(/[a-z]/, 'Password must contain at least 1 lowercase character.')
    .regex(/[0-9]/, 'Password must contain at least 1 digit.')
    .regex(/[^A-Za-z0-9]/, 'Password must contain at least 1 special character.'),
  confirm_password: z
    .string({ required_error: 'Confirm password is required.' })
}).refine(data => data.password === data.confirm_password, {
  message: 'Confirm password must match password.',
  path: ['confirm_password']
});

/**
 * Zod validation schema for POST /api/v1/auth/login
 */
const loginSchema = z.object({
  email: z
    .string({ required_error: 'Email is required.' })
    .email('Invalid email address.'),
  password: z
    .string({ required_error: 'Password is required.' })
    .min(1, 'Password is required.')
});

/**
 * Zod validation schema for POST /api/v1/auth/refresh
 */
const refreshSchema = z.object({
  refresh_token: z
    .string({ required_error: 'Refresh token is required.' })
    .min(1, 'Refresh token is required.')
});

module.exports = {
  registerSchema,
  loginSchema,
  refreshSchema
};
