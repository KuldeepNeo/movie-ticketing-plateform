const { ForbiddenError } = require('../utils/errors');

/**
 * Middleware to check user authorization roles (RBAC).
 * @param {string|string[]} allowedRoles - Single role or array of allowed roles
 */
function roleMiddleware(allowedRoles) {
  const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new ForbiddenError());
    }
    next();
  };
}

module.exports = roleMiddleware;
