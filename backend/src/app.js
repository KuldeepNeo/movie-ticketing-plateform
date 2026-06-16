const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const env = require('./config/env');
const routes = require('./routes');
const errorHandler = require('./middlewares/errorHandler');
const logger = require('./config/logger');

const app = express();

// Set HTTP security headers
app.use(helmet());

// Configure CORS
app.use(cors({
  origin: env.CORS_ORIGIN,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Apply global rate limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per 15 minutes
  message: {
    status: 'error',
    code: 'RATE_LIMIT_EXCEEDED',
    message: 'Too many requests from this client.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Skip rate limiting during testing to prevent test failures
if (env.NODE_ENV !== 'test') {
  app.use(globalLimiter);
}

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Stream morgan logs into winston
app.use(
  morgan('combined', {
    stream: {
      write: (message) => logger.info(message.trim())
    }
  })
);

// Register base router
app.use('/api/v1', routes);

// Fallback 404 handler for invalid routes
app.use((req, res, next) => {
  const { NotFoundError } = require('./utils/errors');
  next(new NotFoundError(`Route not found: ${req.method} ${req.originalUrl}`));
});

// Centralized error handling middleware
app.use(errorHandler);

module.exports = app;
