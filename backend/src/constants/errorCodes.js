module.exports = {
  VALIDATION_ERROR: {
    status: 400,
    code: 'VALIDATION_ERROR'
  },
  UNAUTHORIZED: {
    status: 401,
    code: 'UNAUTHORIZED'
  },
  FORBIDDEN: {
    status: 403,
    code: 'FORBIDDEN'
  },
  RESOURCE_NOT_FOUND: {
    status: 404,
    code: 'RESOURCE_NOT_FOUND'
  },
  CONFLICT: {
    status: 409,
    code: 'CONFLICT'
  },
  GONE: {
    status: 410,
    code: 'GONE'
  },
  UNPROCESSABLE_ENTITY: {
    status: 422,
    code: 'UNPROCESSABLE_ENTITY'
  },
  RATE_LIMIT_EXCEEDED: {
    status: 429,
    code: 'RATE_LIMIT_EXCEEDED'
  },
  INTERNAL_SERVER_ERROR: {
    status: 500,
    code: 'INTERNAL_SERVER_ERROR'
  }
};
