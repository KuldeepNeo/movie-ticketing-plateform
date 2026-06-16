const authService = require('../services/authService');
const responseHelper = require('../utils/responseHelper');

/**
 * Controller class managing HTTP endpoints for Authentication.
 */
class AuthController {
  /**
   * POST /api/v1/auth/register
   */
  async register(req, res, next) {
    try {
      const user = await authService.register(req.body);
      return responseHelper.success(res, user, 201);
    } catch (err) {
      next(err);
    }
  }

  /**
   * POST /api/v1/auth/login
   */
  async login(req, res, next) {
    try {
      const { email, password } = req.body;
      const credentials = await authService.login(email, password);
      return responseHelper.success(res, credentials, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * POST /api/v1/auth/refresh
   */
  async refresh(req, res, next) {
    try {
      const { refresh_token } = req.body;
      const newCredentials = await authService.refreshToken(refresh_token);
      return responseHelper.success(res, newCredentials, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * POST /api/v1/auth/logout
   */
  async logout(req, res, next) {
    try {
      // In stateless JWT, the client discards the tokens. We return a standard success response.
      return responseHelper.success(res, { message: 'Logged out successfully.' }, 200);
    } catch (err) {
      next(err);
    }
  }

  /**
   * GET /api/v1/auth/me
   */
  async me(req, res, next) {
    try {
      // req.user is populated by authMiddleware
      const profile = await authService.getProfile(req.user.id);
      return responseHelper.success(res, profile, 200);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AuthController();
