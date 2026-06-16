const logger = require('../config/logger');
const responseHelper = require('../utils/responseHelper');
const { AppError } = require('../utils/errors');

/**
 * Express global centralized error handling middleware.
 */
function errorHandler(err, req, res, next) {
  // Log the error stack trace
  logger.error(err.message || 'Error occurred', { stack: err.stack });

  // 1. Handle Zod validation errors
  if (err.name === 'ZodError') {
    const validationErrors = err.errors.map(e => ({
      field: e.path.join('.'),
      message: e.message
    }));
    return responseHelper.error(
      res,
      'VALIDATION_ERROR',
      'One or more fields failed validation.',
      400,
      validationErrors
    );
  }

  // 2. Handle SQLite UNIQUE constraint violations (e.g. email conflicts)
  if (err.message && (err.message.includes('UNIQUE constraint failed') || err.code === 'SQLITE_CONSTRAINT')) {
    let message = 'Resource state conflict.';
    if (err.message.includes('users.email')) {
      message = 'Email address already registered.';
    }
    return responseHelper.error(res, 'CONFLICT', message, 409);
  }

  // 3. Handle custom Application Errors (AppError)
  if (err instanceof AppError) {
    return responseHelper.error(
      res,
      err.code,
      err.message,
      err.statusCode,
      err.errors
    );
  }

  // 4. Default fallback to 500 Internal Server Error
  const isProduction = process.env.NODE_ENV === 'production';
  const responseMessage = isProduction ? 'An unexpected error occurred.' : err.message;
  return responseHelper.error(
    res,
    'INTERNAL_SERVER_ERROR',
    responseMessage,
    500
  );
}

module.exports = errorHandler;
