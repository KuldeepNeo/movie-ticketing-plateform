# Backend Project Structure & Setup
## Movie Ticketing Platform (BookMyShow Clone)

| Document | Backend Project Structure Specification |
|---|---|
| **Version** | 1.0 |
| **Status** | Approved |
| **Author** | Senior Solution Architect |
| **Audience** | Backend Team, DevOps Team |

---

## 1. Architectural Overview

The backend will be built using **Node.js** with the **Express.js** framework. It interfaces with an **SQLite** database using **Knex.js** as the query builder and migration tool.

### Architectural Pattern: Layered Architecture
To ensure separation of concerns, testability, and scalability, the application strictly follows a **Layered Architecture** inspired by Domain-Driven Design (DDD).

*   **Routes Layer (`src/routes/`)**: Maps HTTP endpoints to specific controller methods. Applies route-level middleware (auth, rate limiting).
*   **Controller Layer (`src/controllers/`)**: Handles incoming HTTP requests, extracts parameters/body, orchestrates services, and formats the HTTP response (success or error). Contains no business logic.
*   **Service Layer (`src/services/`)**: Contains the core business logic, validations, and orchestrates data access. This is the heart of the application.
*   **Repository Layer (`src/repositories/`)**: Abstract data access layer. Isolates the Service layer from the underlying Knex.js queries and database schema.

---

## 2. High-Level Folder Structure

```text
movie-ticketing-backend/
├── .env.example              # Example environment variables
├── package.json              # Project metadata and dependencies
├── knexfile.js               # Knex.js database configuration
├── server.js                 # Entry point for the application
├── src/                      # Source code root
│   ├── app.js                # Express app initialization and global middleware
│   ├── config/               # Environment and third-party configuration
│   ├── constants/            # Enums, standard error codes
│   ├── controllers/          # HTTP Request/Response handlers
│   ├── middlewares/          # Custom Express middlewares
│   ├── repositories/         # Database access layer
│   ├── routes/               # API endpoint definitions
│   ├── services/             # Core business logic
│   ├── utils/                # Helper functions (e.g., token generation, hashing)
│   └── validators/           # Zod/Joi validation schemas
├── database/                 # Database related files
│   ├── migrations/           # Knex migration scripts
│   ├── seeds/                # Knex seed scripts for initial data
│   └── dev.sqlite3           # SQLite database file (ignored in git)
└── tests/                    # Test suites
    ├── integration/          # API integration tests
    └── unit/                 # Unit tests for services/utils
```

---

## 3. Detailed Directory Breakdown

### 3.1 `src/config/`
Centralized configuration management. Loads environment variables and initializes third-party clients.
*   `env.js`: Validates and exports `process.env` variables.
*   `db.js`: Initializes and exports the Knex.js instance using `knexfile.js`.
*   `logger.js`: Configures the logging utility (e.g., Winston or Pino).

### 3.2 `src/constants/`
Defines application-wide constants to avoid magic strings and numbers.
*   `errorCodes.js`: Maps constants like `VALIDATION_ERROR`, `RESOURCE_NOT_FOUND` to HTTP status codes and standard messages.
*   `roles.js`: Defines user roles (`customer`, `admin`).
*   `status.js`: Enums for booking status, show status, etc.

### 3.3 `src/middlewares/`
Express middlewares for cross-cutting concerns.
*   `authMiddleware.js`: Verifies JWT access tokens.
*   `roleMiddleware.js`: Checks user roles for RBAC.
*   `validationMiddleware.js`: Intercepts requests and validates them against schemas.
*   `errorHandler.js`: Global centralized error handling middleware.
*   `rateLimiter.js`: Implements rate limiting configurations.

### 3.4 `src/routes/`
Groups endpoints logically by feature module.
*   `index.js`: Main router that mounts all sub-routers under `/api/v1`.
*   `auth.routes.js`: Routes for `/auth/register`, `/auth/login`, etc.
*   `movie.routes.js`: Routes for movie discovery.
*   `booking.routes.js`: Routes for seat locking and payment.
*   `admin.routes.js`: Routes grouped under `/admin`.

### 3.5 `src/controllers/`
Thin layer handling HTTP transport.
*   `authController.js`
*   `movieController.js`
*   `bookingController.js`
*   `adminController.js` (or split into `adminMovieController`, `adminTheaterController`)

### 3.6 `src/services/`
The domain logic. Services should not know about the HTTP layer (Request/Response objects).
*   `authService.js`: Password hashing, token generation, user verification.
*   `bookingService.js`: Seat locking concurrency handling, price calculation, simulating payment, ticket generation.
*   `movieService.js`: Listing movies with filters, getting details.
*   `adminShowService.js`: Validating show overlap, generating `show_seats` inventory.

### 3.7 `src/repositories/`
Data access logic using Knex.js. Returns raw data objects or arrays.
*   `userRepository.js`
*   `movieRepository.js`
*   `showRepository.js`
*   `seatRepository.js`
*   `bookingRepository.js`

### 3.8 `src/validators/`
Validation schemas using libraries like Zod or Joi.
*   `authSchemas.js`: Validates login/register payloads.
*   `bookingSchemas.js`: Validates seat selection arrays.
*   `adminSchemas.js`: Validates complex show/theater creation payloads.

### 3.9 `src/utils/`
Stateless utility functions.
*   `jwtHelper.js`: Sign and verify JWTs.
*   `hashHelper.js`: Bcrypt wrappers.
*   `responseHelper.js`: Formats success responses consistently.

---

## 4. Initialization & Scripts

### Expected `package.json` Scripts
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "migrate:make": "knex migrate:make",
    "migrate:latest": "knex migrate:latest",
    "migrate:rollback": "knex migrate:rollback",
    "seed:make": "knex seed:make",
    "seed:run": "knex seed:run",
    "test": "jest",
    "lint": "eslint src/"
  }
}
```

### Environment Variables (`.env.example`)
```env
PORT=3000
NODE_ENV=development

# Database
DB_CLIENT=sqlite3
DB_FILENAME=./database/dev.sqlite3

# Security
JWT_ACCESS_SECRET=your_super_secret_access_key
JWT_REFRESH_SECRET=your_super_secret_refresh_key
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# App
CORS_ORIGIN=http://localhost:8080
```

---

## 5. Execution Flow Example (Booking a Ticket)

1.  **Route**: Client POSTs to `/api/v1/bookings`.
2.  **Middleware**: `authMiddleware` verifies the JWT. `validationMiddleware` checks the body (schema from `validators/bookingSchemas.js`).
3.  **Controller**: `bookingController.createBooking(req, res)` extracts `show_id` and `seat_ids` from `req.body` and calls `bookingService.createLock()`.
4.  **Service**: `bookingService` validates if seats are available. It orchestrates `showRepository` to check show validity, and `seatRepository` to lock the seats within a Knex transaction.
5.  **Repository**: Executes the Knex SQLite queries (e.g., `UPDATE show_seats SET status = 'locked'`).
6.  **Controller**: Receives the successful booking object from the service and uses `responseHelper` to format the `201 Created` JSON payload back to the client.
7.  **Error Case**: If seats are already locked, the repository throws an error, the service catches it and throws a custom `ConflictError`, which is caught by the `errorHandler` middleware and translated into a `409 Conflict` HTTP response.
