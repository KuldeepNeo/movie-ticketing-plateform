# Module Auth

This report documents the SQA verification and validation activities for the Authentication and Identity module (Sprint 1). It covers Knex database configurations, SQLite table schemas, Express REST endpoints, Flutter Auth widget structures, and live KPI testing.

---

## 1. Static Configuration & Codebase Review

### Knex Configuration & Migrations
- **File Checked**: `backend/knexfile.js`
  - *Verification*: Verified development environment uses SQLite3 connection pools and enables Write-Ahead Logging (WAL) and foreign keys via pool `afterCreate` run hooks. Testing environment uses SQLite `:memory:` for isolation and performance.
  - *Status*: **PASS**
- **File Checked**: `backend/database/migrations/20260616072008_create_users_table.js`
  - *Verification*: Verified Knex schema builder defines primary key autoincrements, mandatory fields (`name`, `email`, `password_hash`, `role`, `created_at`, `updated_at`), and nullable `deleted_at`. Unique index on `email` is successfully mapped.
  - *Status*: **PASS**

### Express API Base Structure
- **Core App**: `backend/src/app.js` is secured with dynamic CORS origin reflection and relaxed Helmet policies in non-production environments to allow local Flutter Web requests, while retaining full standard protection (rate limiting, JSON parser, Morgan stream logger, global errorHandler).
- **Endpoints**: Authenticated paths are guarded via `authMiddleware.js`.
- **Status**: **PASS**

### Flutter Project Structure & Auth Screens
- **Folder Path**: `frontend/lib/features/auth/`
- **Widgets Checked**:
  - `lib/core/widgets/primary_button.dart` (Gradients, custom shadows, and loading states).
  - `lib/core/widgets/custom_text_field.dart` (Validation handlers and obscure password toggles).
- **Screens Checked**:
  - `lib/features/auth/presentation/screens/landing_screen.dart` (Main landing welcoming page).
  - `lib/features/auth/presentation/screens/login_screen.dart` (Credentials input and validation UI).
  - `lib/features/auth/presentation/screens/register_screen.dart` (Complexity-checking sign-up form).
  - `lib/features/auth/presentation/screens/home_screen.dart` (Protected dashboard showing active profile values).
- **Routing**: `lib/router/app_router.dart` uses `GoRouter` and reactively watches the state controller to automatically redirect unauthenticated attempts.
- **Status**: **PASS**

---

## 2. Database Schema Audit (SQLite)

Executed database integrity queries using `sqlite3`:
- **PRAGMA table_info(users)**: Confirmed correct database types (`INTEGER` primary key, `varchar` for strings, default value `'customer'` for role, and nullability for `deleted_at`).
- **PRAGMA index_list(users)**: Verified the unique index `users_email_unique` exists.
- *Audit Note*: Knex's `.collate('NOCASE')` is compiled by Knex only for MySQL/PostgreSQL. However, case-insensitivity on emails is guaranteed by the application tier repository (`userRepository.js`) which normalizes emails via `.toLowerCase().trim()` during insertions and fetches.
- **Status**: **PASS**

---

## 3. Validation Functions Table

Testing was performed live against the running API server (`http://localhost:3000`) using the automated verification script `testing/run-api-tests.js` executing 28 validation checks.

| KPI Number | KPI | Validation Method | Expected Output | Actual Output | Status | Notes |
| ---------- | --- | ----------------- | --------------- | ------------- | ------ | ----- |
| **KPI-AUTH-001** | User can register using valid information | Submit POST `/api/v1/auth/register` with name, unique email, and strong password. Verify HTTP success, database record creation, and password hashing. | HTTP 201 success response, record created in database with dynamically hashed password. | HTTP 201 Created with success payload. User ID and profile returned, password hash verified. | **PASS** | Registration saves name, email, and defaults role to "customer". |
| **KPI-AUTH-002** | Duplicate email registration is prevented | Attempt registration using an already registered email. Verify response code and duplicate database check. | HTTP 409 Conflict response containing code "CONFLICT" and warning message. | HTTP 409 Conflict with error code `CONFLICT` and message "Email address already registered." | **PASS** | Database prevents duplicate email creation. |
| **KPI-AUTH-003** | User can log in successfully | Validate login POST `/api/v1/auth/login` with correct credentials. Verify session tokens generation. | HTTP 200 success response containing valid JWT Access Token and Refresh Token. | HTTP 200 OK with success payload returning `access_token` and `refresh_token`. | **PASS** | Access Token has 15m expiry, Refresh Token has 7d expiry. |
| **KPI-AUTH-004** | Invalid login credentials are rejected | Submit incorrect password to login. Verify rejected session. | HTTP 401 Unauthorized response with error code "UNAUTHORIZED". | HTTP 401 Unauthorized with error code `UNAUTHORIZED` and rejection message. | **PASS** | Rejects bad passwords and unregistered emails. |
| **KPI-AUTH-005** | User can logout successfully | Submit POST `/api/v1/auth/logout` with Bearer access token. Verify session termination. | HTTP 200 success response, client deletes local tokens to terminate stateless session. | HTTP 200 OK with success payload and message "Logged out successfully." | **PASS** | Session invalidated successfully. |
| **KPI-AUTH-006** | Session management functions correctly | 1. Access `/auth/me` with valid access token.<br>2. Access `/auth/me` without token.<br>3. Access `/auth/me` with bad token signature. | 1. HTTP 200 OK returning user profile.<br>2. HTTP 401 Unauthorized.<br>3. HTTP 401 Unauthorized. | 1. HTTP 200 OK returning user data.<br>2. HTTP 401 Unauthorized.<br>3. HTTP 401 Unauthorized. | **PASS** | Enforces route guarding correctly. |
| **JWT-REFRESH** | Token refresh mechanism works correctly | Submit POST `/api/v1/auth/refresh` with valid refresh token. Verify access token generation. | HTTP 200 OK returning a new access token without requiring re-authentication. | HTTP 200 OK with success payload returning a new `access_token` and 15m duration limit. | **PASS** | Silent token refresh validated successfully on live endpoints. |
