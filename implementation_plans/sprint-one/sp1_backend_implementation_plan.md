# Implementation Plan - Sprint 1: Foundation & Identity - Backend Implementation

Act as the Backend Developer. This plan covers setting up the backend project structure, database configuration with Knex and SQLite (WAL mode), migrations for the `users` table, utility layers, and implementing authentication REST APIs.

## Proposed Changes

We will build the complete Node.js/Express application inside the `backend/` directory.

### Project Scaffolding & Config

#### [NEW] [package.json](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/package.json)
Contains project metadata, npm scripts, and dependencies:
- Dependencies: `express`, `knex`, `sqlite3`, `bcrypt`, `jsonwebtoken`, `dotenv`, `cors`, `zod`, `winston`, `express-rate-limit`, `helmet`
- Dev Dependencies: `jest`, `supertest`, `nodemon`

#### [NEW] [knexfile.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/knexfile.js)
Knex configuration for SQLite in development and testing. Enables WAL mode via pool connection hooks: `PRAGMA journal_mode = WAL;` and foreign keys `PRAGMA foreign_keys = ON;`.

#### [NEW] [.env.example](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/.env.example) and [.env](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/.env)
Configuration parameters for environment, server ports, JWT secrets, and token lifespans (15m for Access, 7d for Refresh).

---

### Database Layer

#### [NEW] [Migration: users](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/migrations/20260616120000_create_users_table.js)
Knex migration setting up the `users` table:
- Columns: `id` (autoincrement PK), `name` (string, NOT NULL), `email` (string, NOT NULL, UNIQUE, case-insensitive NOCASE), `password_hash` (string, NOT NULL), `role` (string, NOT NULL, default 'customer'), `created_at` (timestamp, NOT NULL), `updated_at` (timestamp, NOT NULL), `deleted_at` (timestamp, NULL).

#### [NEW] [Seed: users](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/seeds/01_users.js)
Seed script to insert at least one Admin and one Customer with hashed passwords for initial manual and automated verification.

---

### Layered Architecture Core

#### [NEW] [src/config/env.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/config/env.js)
Validates and exports environment variables.

#### [NEW] [src/config/db.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/config/db.js)
Initializes and exports Knex connection instance.

#### [NEW] [src/config/logger.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/config/logger.js)
Winston logger configuration.

#### [NEW] [src/constants/errorCodes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/constants/errorCodes.js)
Enums mapping logical error codes (e.g. `VALIDATION_ERROR`, `UNAUTHORIZED`, `CONFLICT`) to standard HTTP statuses.

#### [NEW] [src/constants/roles.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/constants/roles.js)
Defines user roles: `'customer'` and `'admin'`.

#### [NEW] [src/utils/hashHelper.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/utils/hashHelper.js)
Bcrypt helper for password hashing and verification.

#### [NEW] [src/utils/jwtHelper.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/utils/jwtHelper.js)
Helper to sign/verify JWT Access & Refresh Tokens.

#### [NEW] [src/utils/responseHelper.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/utils/responseHelper.js)
Helper to build standardized JSON API response formats.

---

### Route, Controller, Repository & Middleware Layers

#### [NEW] [src/middlewares/errorHandler.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/errorHandler.js)
Centralized global middleware formatting all application errors (including validation, DB conflict) to the standard JSON error schema.

#### [NEW] [src/middlewares/authMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/authMiddleware.js)
Middleware validating the JWT Bearer token in the `Authorization` header and appending the user payload to the request object.

#### [NEW] [src/middlewares/roleMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/roleMiddleware.js)
RBAC middleware to check user roles.

#### [NEW] [src/middlewares/validationMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/validationMiddleware.js)
Express middleware running Zod schema validation on input bodies.

#### [NEW] [src/validators/authSchemas.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/validators/authSchemas.js)
Zod schemas for `/auth/register` (confirm_password must match password, password must contain capital, lowercase, number, symbol) and `/auth/login`.

#### [NEW] [src/repositories/userRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/userRepository.js)
Encapsulates database operations for users: `create`, `findByEmail`, `findById`.

#### [NEW] [src/services/authService.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/services/authService.js)
Contains core authentication business logic: registration checks, password matching, signing tokens, refresh token validation.

#### [NEW] [src/controllers/authController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/authController.js)
Handles mapping of HTTP requests to AuthService methods and calling ResponseHelper.

#### [NEW] [src/routes/auth.routes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/auth.routes.js)
Auth sub-routing under `/auth`.

#### [NEW] [src/routes/index.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/index.js)
Root routing mounting sub-routers under `/api/v1`.

#### [NEW] [src/app.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/app.js)
Express app configuration, security headers (helmet), CORS origin mapping, JSON parser, and request rate limiters.

#### [NEW] [server.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/server.js)
Entry point that boots the Express server on the designated PORT.

#### [NEW] [README.md](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/README.md)
Detailed setup, environment variable configuration, DB migration execution, and test commands.

---

### Verification and Testing

#### [NEW] [tests/unit/authService.test.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/tests/unit/authService.test.js)
Unit tests for `authService.js`, `jwtHelper.js`, and `hashHelper.js`.

#### [NEW] [tests/integration/auth.test.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/tests/integration/auth.test.js)
Integration tests for registration, login, profile retrieval `/auth/me`, and refresh token flows using Jest and Supertest on an in-memory or temporary SQLite test database.

---

## Verification Plan

### Automated Tests
- Run `npm install` and database migrations in testing mode.
- Run `npm run test` to verify unit and integration tests pass successfully.
  ```bash
  npm test
  ```

### Manual Verification
- Execute migrations and run seed script:
  ```bash
  npx knex migrate:latest
  npx knex seed:run
  ```
- Send manual HTTP requests to `http://localhost:3000/api/v1/auth/register` and `http://localhost:3000/api/v1/auth/login` to confirm correct response schemas and SQLite write operations.
