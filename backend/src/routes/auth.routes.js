const express = require('express');
const authController = require('../controllers/authController');
const validationMiddleware = require('../middlewares/validationMiddleware');
const authMiddleware = require('../middlewares/authMiddleware');
const { registerSchema, loginSchema, refreshSchema } = require('../validators/authSchemas');

const router = express.Router();

// Public Authentication endpoints
router.post('/register', validationMiddleware(registerSchema), authController.register);
router.post('/login', validationMiddleware(loginSchema), authController.login);
router.post('/refresh', validationMiddleware(refreshSchema), authController.refresh);

// Protected Authentication endpoints
router.post('/logout', authMiddleware, authController.logout);
router.get('/me', authMiddleware, authController.me);

module.exports = router;
