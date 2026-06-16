/**
 * Format and send a success response.
 * @param {object} res - Express response object
 * @param {any} data - Response payload data
 * @param {number} statusCode - HTTP status code (default 200)
 * @param {object} [meta] - Optional pagination meta metadata
 */
function success(res, data, statusCode = 200, meta = null) {
  const response = {
    status: 'success',
    data
  };
  if (meta) {
    response.meta = meta;
  }
  return res.status(statusCode).json(response);
}

/**
 * Format and send an error response.
 * @param {object} res - Express response object
 * @param {string} code - Error code constant
 * @param {string} message - Human-readable explanation of error
 * @param {number} statusCode - HTTP status code
 * @param {array} [errors] - Specific sub-validation details or empty array
 */
function error(res, code, message, statusCode = 500, errors = []) {
  return res.status(statusCode).json({
    status: 'error',
    code,
    message,
    errors
  });
}

module.exports = {
  success,
  error
};
