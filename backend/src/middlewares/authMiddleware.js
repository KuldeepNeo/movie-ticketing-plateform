const { verifyAccessToken } = require('../utils/jwtHelper');
const { UnauthorizedError } = require('../utils/errors');

/**
 * Middleware to verify JWT Access Token and authenticate request.
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError());
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return next(new UnauthorizedError());
  }

  try {
    const decoded = verifyAccessToken(token);
    // Attach credentials payload to request context
    req.user = {
      id: decoded.sub,
      email: decoded.email,
      role: decoded.role
    };
    next();
  } catch (err) {
    // If jwt verification fails (expired, invalid sign, etc.), trigger 401
    return next(new UnauthorizedError());
  }
}

module.exports = authMiddleware;
