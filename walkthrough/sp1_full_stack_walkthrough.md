# Walkthrough - Sprint 1: Foundation & Identity (Full-Stack Implementation)

We have successfully completed both the **Backend** and **Frontend** implementations for Sprint 1: Foundation & Identity. All requirements, security protocols, API contracts, and user flows are fully satisfied.

---

## 🖥️ Backend Implementation Summary

### 1. Configuration & Database Scaffold
- [package.json](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/package.json): Added dependency mappings for Express, Knex, SQLite3, Bcrypt, JsonWebToken, Zod, Helmet, CORS, Morgan, Winston, and express-rate-limit.
- [knexfile.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/knexfile.js): Created configurations using SQLite `:memory:` for testing and `./database/dev.sqlite3` for development. Enabled SQLite Write-Ahead Logging (WAL) and foreign keys enforcement on connection pools.
- [Migration: Users](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/migrations/20260616072008_create_users_table.js): Creates the `users` table including a unique case-insensitive `email` column collation (`COLLATE NOCASE`).
- [Seed: Users](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/seeds/01_users.js): Seeds default accounts: Admin (`admin@example.com`) and Customer (`john@example.com`) with dynamically-hashed bcrypt passwords.

### 2. Core Architectural Layers
- **Config & Logs**: Validates process environment variables using Zod (`env.js`), instantiates Winston (`logger.js`), and database connections (`db.js`).
- **Helpers**: Added password encryption helpers using Bcrypt (`hashHelper.js`), JWT signing/verifying utilities (`jwtHelper.js`), and REST API formatter helpers (`responseHelper.js`).
- **Repositories**: Implemented `userRepository.js` encapsulating Knex queries and filtering out soft-deleted records.
- **Services**: Implemented core domain logic in `authService.js` (registration checks, logins, token refreshes, profile lookups).

### 3. Transport, Controllers & Routes
- [src/middlewares/errorHandler.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/errorHandler.js): Catches thrown exceptions globally, translating Zod validation errors and database unique constraints automatically into standardized JSON structures.
- [src/middlewares/authMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/authMiddleware.js) & [roleMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/roleMiddleware.js): Validates token signatures and executes role authorization.
- [src/middlewares/validationMiddleware.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/middlewares/validationMiddleware.js): Intercepts requests and triggers schema checks.
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

### 2. Authentication Feature Domain & State Management
- [lib/features/auth/domain/entities/user_entity.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/user_entity.dart): Defines the user model with manual JSON serialization to avoid code generation complexity in tests.
- [lib/features/auth/domain/repositories/i_auth_repository.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/repositories/i_auth_repository.dart) & [lib/features/auth/data/repositories/auth_repository_impl.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/data/repositories/auth_repository_impl.dart): Coordinates data mappings and local secure token persistence.
- [lib/features/auth/presentation/controllers/auth_controller.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/auth_controller.dart): Implements a Riverpod `Notifier` managing `AuthState` (initial, loading, authenticated, unauthenticated, error). On startup, it checks storage for cached tokens and restores sessions.

### 3. Navigation Guard & UI Screens
- [lib/router/app_router.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/router/app_router.dart): Declares GoRouter paths and reactively checks authentication transitions. Automatically redirects unlogged users to the welcome page and authenticated users to the home dashboard.
- [lib/core/widgets/primary_button.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/widgets/primary_button.dart) & [custom_text_field.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/widgets/custom_text_field.dart): Reusable premium input and button UI components.
- [lib/features/auth/presentation/screens/landing_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/landing_screen.dart): Introduces the branding logo and routes users to credentials screens.
- [lib/features/auth/presentation/screens/login_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/login_screen.dart): Implements form validations and displays errors.
- [lib/features/auth/presentation/screens/register_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/register_screen.dart): Handles registration forms, checking password rules prior to submission.
- [lib/features/auth/presentation/screens/home_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/home_screen.dart): Placeholder dashboard displaying account profile details (Name, Email, Role) and offering a sign-out trigger.
- [lib/main.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/main.dart): Bootstraps the application inside Riverpod's `ProviderScope` and loads the router.

---

## 🧪 Verification & Test Logs

### 1. Backend Verification (`npm test`):
All **15 assertions** across unit and integration test suites pass successfully.
```text
PASS tests/unit/authService.test.js
  Auth Helpers & Service Unit Tests
    Hash Helper
      ✓ should hash a password and verify it successfully (681 ms)
    JWT Helper
      ✓ should generate valid access and refresh tokens (3 ms)
    Auth Service
      ✓ should register a new user successfully (234 ms)
      ✓ should fail registration if email is duplicate (247 ms)
      ✓ should authenticate user and return tokens on login (456 ms)
      ✓ should fail login if password or email is incorrect (456 ms)

PASS tests/integration/auth.test.js
  Authentication Endpoints Integration Tests
    POST /api/v1/auth/register
      ✓ should register a new user account with correct response (291 ms)
      ✓ should fail registration with 400 validation error if passwords do not match (11 ms)
      ✓ should fail with 409 conflict if email already exists (248 ms)
    POST /api/v1/auth/login
      ✓ should log in successfully and return token credentials (794 ms)
      ✓ should fail log in with 401 for incorrect credentials (486 ms)
    Protected Routes
      ✓ GET /api/v1/auth/me should fetch profile successfully with valid token (486 ms)
      ✓ GET /api/v1/auth/me should return 401 without auth header (479 ms)
      ✓ POST /api/v1/auth/refresh should refresh access token (502 ms)
      ✓ POST /api/v1/auth/logout should logout successfully (589 ms)

Test Suites: 2 passed, 2 total
Tests:       15 passed, 15 total
Snapshots:   0 total
Time:        6.745 s
Ran all test suites.
```

### 2. Frontend Verification (`flutter test`):
All **5 assertions** across unit and widget tests pass successfully.
```text
00:01 +0: /Users/neo/Desktop/Vibe .../auth_controller_test.dart: Initial state is loading then unauthenticated when no token exists
00:01 +1: /Users/neo/Desktop/Vibe .../login_screen_test.dart: LoginScreen renders inputs and validation triggers
00:02 +5: All tests passed!
```
- `test/unit/auth_controller_test.dart`: Validates loading, authenticated, unauthenticated, and error states under various mock scenarios.
- `test/widget/login_screen_test.dart`: Pumps the form, verifies field layout structures, and asserts that validation errors are correctly rendered upon empty form submissions.
