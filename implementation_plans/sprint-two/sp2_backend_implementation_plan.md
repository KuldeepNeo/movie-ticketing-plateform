# Implementation Plan - Sprint 2: Admin Foundation (Inventory) Backend

Act as the Backend Developer. This plan covers the database migrations, schemas, repositories, services, controllers, validations, and routes required for Sprint 2: Admin Foundation (Inventory).

## Goal Description

Implement the database structure and REST APIs for static inventory management, allowing Administrators to perform CRUD operations on cities, movies, theaters, and screens (which automatically generate physical seats).

## User Review Required

- **Automatic Seat Generation**: The seat generation logic creates rows labeled alphabetically ('A' through 'Z') and columns numbered 1 to `columns_count`. Seat categories default to `'classic'` unless mapped otherwise via the `seat_categories` object in the request (e.g., `"A-C": "premium"`).
- **Soft Delete Behavior**: In accordance with the DB Design, entities will be soft-deleted by setting `deleted_at = current_timestamp`. Foreign key checks will be enforced at the application layer to prevent deleting theaters or screens if active references/screens exist.

## Open Questions

- **None**: The database design and API contracts specify all column definitions, validation rules, and status codes.

---

## Proposed Changes

### [Database Layer]

#### [NEW] [20260616101642_create_inventory_tables.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/migrations/20260616101642_create_inventory_tables.js)
Define Knex migrations for:
1. `cities`: columns `id`, `name` (unique), `status` (default 'active'), `created_at`, `updated_at`, `deleted_at` + check constraint on `status`.
2. `movies`: columns `id`, `title`, `synopsis`, `runtime_minutes`, `language`, `genre`, `age_rating`, `poster_url`, `banner_url`, `status` (default 'published'), `created_at`, `updated_at`, `deleted_at` + check constraints on `runtime_minutes`, `age_rating`, and `status`.
3. `theaters`: columns `id`, `name`, `address`, `city_id` (foreign key referencing `cities(id)` on update CASCADE on delete RESTRICT), `area`, `status` (default 'active'), `created_at`, `updated_at`, `deleted_at` + check constraint on `status`.
4. `screens`: columns `id`, `theater_id` (foreign key referencing `theaters(id)` on update CASCADE on delete RESTRICT), `name`, `rows_count`, `columns_count`, `status` (default 'active'), `created_at`, `updated_at`, `deleted_at` + check constraints on `status`, `rows_count` (<= 26), and `columns_count` (<= 50).
5. `seats`: columns `id`, `screen_id` (foreign key referencing `screens(id)` on update CASCADE on delete CASCADE), `row_label`, `column_number`, `seat_category` (default 'classic'), `status` (default 'active'), `created_at`, `updated_at`, `deleted_at` + check constraints on `status`, `column_number`, and `seat_category`.
6. Indices:
   - Unique: `seats(screen_id, row_label, column_number)`
   - Single/Composite: `idx_movies_status_title` on `movies(status, title)`, `idx_theaters_city_status` on `theaters(city_id, status)`

#### [NEW] [02_inventory.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/database/seeds/02_inventory.js)
Provide initial seed data for:
- 3 cities (Bengaluru, Mumbai, Delhi)
- 2 movies (Galactic Storm, Inception)
- 2 theaters in Bengaluru (PVR Multiplex, INOX Forum)
- 1 screen per theater, pre-generating the seats layout.

---

### [Repository Layer]

#### [NEW] [cityRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/cityRepository.js)
Retrieve all active, non-deleted cities.

#### [NEW] [movieRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/movieRepository.js)
Encapsulate CRUD operations for `movies` using Knex query builder, supporting search by title, status filtering, and soft deletes.

#### [NEW] [theaterRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/theaterRepository.js)
Encapsulate CRUD operations for `theaters`, resolving city names if needed.

#### [NEW] [screenRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/screenRepository.js)
Encapsulate CRUD operations for `screens`.

#### [NEW] [seatRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/seatRepository.js)
Handle bulk insertions of seats inside a screen creation transaction.

---

### [Service Layer]

#### [NEW] [cityService.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/services/cityService.js)
Expose active city listings.

#### [NEW] [movieService.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/services/movieService.js)
Provide movie CRUD coordination and soft-delete logic.

#### [NEW] [theaterService.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/services/theaterService.js)
Provide theater CRUD, validating that the referenced `city_id` is an active city. Prevent deleting a theater that has active screens.

#### [NEW] [screenService.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/services/screenService.js)
Orchestrate transaction-based screen creation. Automatically parse the `seat_categories` row ranges (e.g. `"A-C"`) and write seat records for all row-column coordinates in a database transaction block.

---

### [Controller Layer]

#### [NEW] [cityController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/cityController.js)
Handle `GET /api/v1/cities`.

#### [NEW] [adminMovieController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/adminMovieController.js)
Expose admin movie endpoints (listing with pagination/filters, creating, updating, deleting).

#### [NEW] [adminTheaterController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/adminTheaterController.js)
Expose admin theater endpoints.

#### [NEW] [adminScreenController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/adminScreenController.js)
Expose admin screen endpoints (listing by theater, creating, updating, deleting).

---

### [Validation Layer]

#### [NEW] [adminSchemas.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/validators/adminSchemas.js)
Define Zod schemas matching the API contract rules:
- `movieCreateSchema` / `movieUpdateSchema`: check `title`, `synopsis` (min 10), `runtime_minutes` (>0), `language`, `genre`, `age_rating` (U, U/A, A, PG-13, R), `poster_url`, `banner_url`, `status`.
- `theaterCreateSchema` / `theaterUpdateSchema`: check `name`, `address` (min 5), `city_id`, `area`.
- `screenCreateSchema` / `screenUpdateSchema`: check `name`, `rows_count` (1-26), `columns_count` (1-50), and optional `seat_categories` format.

---

### [Routing Layer]

#### [NEW] [city.routes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/city.routes.js)
Route `GET /` to `cityController.getCities`.

#### [NEW] [admin.routes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/admin.routes.js)
Secure routes via `authMiddleware` and `roleMiddleware('admin')` for:
- Movies CRUD
- Theaters CRUD
- Screens CRUD

#### [MODIFY] [index.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/index.js)
Mount the `/cities` and `/admin` routes.

---

## Verification Plan

### Automated Tests
- Run all Jest test suites including a new integration suite `backend/tests/integration/admin.test.js` validating RBAC access rules and inventory creation logic:
  ```bash
  npm test
  ```

### Manual Verification
- Execute Knex migration and seed commands:
  ```bash
  npx knex migrate:latest
  npx knex seed:run
  ```
- Run integration queries or Postman endpoints to ensure successful inventory creations, checking that seats count maps precisely.
