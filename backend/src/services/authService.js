const userRepository = require('../repositories/userRepository');
const { hashPassword, comparePassword } = require('../utils/hashHelper');
const { generateAccessToken, generateRefreshToken, verifyRefreshToken } = require('../utils/jwtHelper');
const { ConflictError, UnauthorizedError } = require('../utils/errors');

/**
 * Service layer orchestrating user authentication business flows.
 */
class AuthService {
  /**
   * Register a new customer user.
   * @param {object} userData - User registration inputs (name, email, password)
   * @returns {Promise<object>} - Registered user info
   */
  async register(userData) {
    // Check if email is already taken
    const existingUser = await userRepository.findByEmail(userData.email);
    if (existingUser) {
      throw new ConflictError('Email address already registered.');
    }

    // Hash the password
    const passwordHash = await hashPassword(userData.password);

    // Save user record
    const user = await userRepository.create({
      name: userData.name,
      email: userData.email,
      password_hash: passwordHash,
      role: 'customer'
    });

    // Format output to match the REST success contract response
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at
    };
  }

  /**
   * Authenticate a user and issue JWT Access & Refresh tokens.
   * @param {string} email 
   * @param {string} password 
   * @returns {Promise<object>} - Session credentials payload
   */
  async login(email, password) {
    const user = await userRepository.findByEmail(email);
    if (!user) {
      throw new UnauthorizedError('Invalid email or password.');
    }

    const isMatch = await comparePassword(password, user.password_hash);
    if (!isMatch) {
      throw new UnauthorizedError('Invalid email or password.');
    }

    // Generate stateless tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      },
      access_token: accessToken,
      refresh_token: refreshToken,
      expires_in: 900 // 15 minutes in seconds
    };
  }

  /**
   * Validate a refresh token and issue a new access token.
   * @param {string} token - Refresh token
   * @returns {Promise<object>} - New access token payload
   */
  async refreshToken(token) {
    try {
      const decoded = verifyRefreshToken(token);
      
      const user = await userRepository.findById(decoded.sub);
      if (!user) {
        throw new UnauthorizedError('Refresh token is invalid, expired, or revoked.');
      }

      const newAccessToken = generateAccessToken(user);
      return {
        access_token: newAccessToken,
        expires_in: 900
      };
    } catch (err) {
      throw new UnauthorizedError('Refresh token is invalid, expired, or revoked.');
    }
  }

  /**
   * Retrieve profile details for the authenticated user.
   * @param {number} userId 
   * @returns {Promise<object>} - User profile
   */
  async getProfile(userId) {
    const user = await userRepository.findById(userId);
    if (!user) {
      throw new UnauthorizedError('User not found.');
    }

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      created_at: user.created_at
    };
  }
}

module.exports = new AuthService();
