# Walkthrough - Sprint 1: Foundation & Identity (Full-Stack & QA Validation)

We have successfully completed all development and SQA validation tasks for Sprint 1: Foundation & Identity. All requirements, database schemas, REST API contracts, and user session lifecycles have been verified.

---

## 🖥️ Backend Implementation Summary

### 1. Configuration & Database Scaffold
- [package.json](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/package.json): Mapped and installed Express, Knex, SQLite3, Bcrypt, JsonWebToken, Zod, Helmet, CORS, Morgan, Winston, and express-rate-limit.
- [knexfile.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/knexfile.js): Created development and isolated in-memory testing environments. Enabled **SQLite Write-Ahead Logging (WAL)** and foreign keys checks.
- [Migration: Users](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/migrations/20260616072008_create_users_table.js): Creates the `users` table including a unique case-insensitive `email` column collation (`COLLATE NOCASE`).
- [Seed: Users](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/seeds/01_users.js): Seeds default Admin and Customer accounts with dynamically hashed bcrypt passwords.

### 2. Core Architectural Layers
- **Domain & Data Access**: Validates process environment variables using Zod (`env.js`), instantiates Winston (`logger.js`), and database connections (`db.js`). Wraps Bcrypt password encryption (`hashHelper.js`), JWT signing/verifying utilities (`jwtHelper.js`), and REST response formatters (`responseHelper.js`).
- **Repositories**: Implemented `userRepository.js` encapsulating Knex queries and filtering out soft-deleted records.
- **Services**: Implemented core domain logic in `authService.js` (registration checks, logins, token refreshes, profile lookups).

### 3. Transport, Controllers & Routes
- [src/middlewares/errorHandler.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/errorHandler.js): Centralized error handling, translating Zod schema errors and SQLite constraint violations into standard JSON formats.
- [src/middlewares/authMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/authMiddleware.js) & [roleMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/roleMiddleware.js): Validates token signatures and executes role authorizations.
- [src/validators/authSchemas.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/validators/authSchemas.js): Zod rules ensuring passwords require numbers, uppercase, lowercase, special characters, and matches the verification field.
- [src/controllers/authController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/authController.js): Coordinates services inputs to ResponseHelper.
- [src/routes/auth.routes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/auth.routes.js) & [routes/index.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/index.js): Binds paths to actions.
- [src/app.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/app.js) & [server.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/server.js): Starts application with rate-limiting, Helmet headers, CORS filters, and graceful process signals listeners.

---

## 📱 Frontend Implementation Summary

### 1. Configuration & Network Setup
- [lib/core/constants/api_constants.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/constants/api_constants.dart): Manages API endpoints paths and reads the API Base URL from compile-time settings using `--dart-define`.
- [lib/core/constants/app_colors.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/constants/app_colors.dart) & [lib/core/theme/app_theme.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/theme/app_theme.dart): Defines BookMyShow branding colors and configures Light/Dark styling tokens.
- [lib/core/local_storage/secure_storage_service.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/local_storage/secure_storage_service.dart): Uses `FlutterSecureStorage` for local token persistence.
- [lib/core/network/dio_client.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/network/dio_client.dart): Implements Dio client with interceptors to automatically attach Bearer tokens, catch `401 Unauthorized` responses, and execute silent access token refreshes via `POST /auth/refresh` without user interruption.

### 2. State Management & UI screens
- [lib/features/auth/domain/entities/user_entity.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/user_entity.dart): Defines the user model with manual JSON serialization.
- [lib/features/auth/presentation/controllers/auth_controller.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/auth_controller.dart): Implements a Riverpod `Notifier` managing `AuthState`. On startup, it checks storage for cached tokens and restores sessions.
- [lib/router/app_router.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/router/app_router.dart): Declares GoRouter paths and reactively checks authentication transitions. Automatically redirects unlogged users to the welcome page and authenticated users to the home dashboard.
- [lib/core/widgets/primary_button.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/widgets/primary_button.dart) & [custom_text_field.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/widgets/custom_text_field.dart): Reusable premium input and button UI components.
- Landing, Login, Register and Home screens are implemented.

---

## 🔍 SQA Validation Summary

### 1. Database schema checks
- SQLite schema verified using `sqlite3 "PRAGMA table_info(users);"`. Confirmed correct field sizes, constraints, and defaults.
- Checked indexing with `PRAGMA index_list(users);` to verify that `users_email_unique` constraint exists.
- Knex migrations verified using `npx knex migrate:status` showing **1 Completed Migration** and **0 Pending**.

### 2. Live API Testing
Executed a custom integration test script ([run-api-tests.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/testing/run-api-tests.js)) against the live running Node server (`http://localhost:3000`), validating all security parameters, token expirations, and status codes.
- **KPI-AUTH-001** (User Registration): **PASS** (Successful registration, HTTP 201).
- **KPI-AUTH-002** (Duplicate Email Prevention): **PASS** (Rejects duplicate emails, HTTP 409 Conflict).
- **KPI-AUTH-003** (User Login): **PASS** (Validates logins and issues tokens, HTTP 200 OK).
- **KPI-AUTH-004** (Invalid Login Rejection): **PASS** (Rejects invalid password with HTTP 401).
- **KPI-AUTH-005** (User Logout): **PASS** (Stateless logout session termination, HTTP 200 OK).
- **KPI-AUTH-006** (Session Management): **PASS** (Guards protected endpoints against expired/invalid tokens, HTTP 401).
- **JWT-REFRESH** (Token Refresh): **PASS** (Refreshes access token successfully using refresh tokens).

### 3. SQA Deliverables
- [Auth-test-cases-report.md](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/testing/qa-artifacts/Auth/Auth-test-cases-report.md): Formal KPI validation table.
- [Auth-defect-reports.md](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/testing/qa-artifacts/Auth/Auth-defect-reports.md): Confirms **0 defects detected** and confirms release readiness.
- [postman-collection.json](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/testing/postman-collection.json): The predefined collection matching all auth paths.
