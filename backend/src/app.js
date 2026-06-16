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

// Set HTTP security headers - relax cross-origin resource/opener/embedder policies in development to support Flutter Web connections
if (env.NODE_ENV === 'production') {
  app.use(helmet());
} else {
  app.use(helmet({
    crossOriginResourcePolicy: false,
    crossOriginEmbedderPolicy: false,
    crossOriginOpenerPolicy: false
  }));
}

// Configure CORS - dynamically permit all request origins in development to accommodate random local Flutter Web client ports
app.use(cors({
  origin: (origin, callback) => {
    if (env.NODE_ENV !== 'production' || !origin || origin === env.CORS_ORIGIN) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
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
