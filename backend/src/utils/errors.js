/**
 * Base custom error class for application errors.
 */
class AppError extends Error {
  constructor(message, statusCode, code, errors = []) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.errors = errors;
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message = 'One or more fields failed validation.', errors = []) {
    super(message, 400, 'VALIDATION_ERROR', errors);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Authentication required or token expired.') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Authenticated but insufficient permissions.') {
    super(message, 403, 'FORBIDDEN');
  }
}

class ConflictError extends AppError {
  constructor(message = 'Resource state conflict.') {
    super(message, 409, 'CONFLICT');
  }
}

class NotFoundError extends AppError {
  constructor(message = 'The requested resource does not exist.') {
    super(message, 404, 'RESOURCE_NOT_FOUND');
  }
}

class UnprocessableEntityError extends AppError {
  constructor(message = 'The request cannot be processed due to semantic errors.') {
    super(message, 422, 'UNPROCESSABLE_ENTITY');
  }
}

module.exports = {
  AppError,
  ValidationError,
  UnauthorizedError,
  ForbiddenError,
  ConflictError,
  NotFoundError,
  UnprocessableEntityError
};
