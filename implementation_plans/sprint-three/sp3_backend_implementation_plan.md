# Implementation Plan - Sprint 3: Scheduling & Discovery Backend

Implement show scheduling and movie discovery APIs, including time overlap checks, seat inventory auto-population, and paginated dynamic movie search/filtering by city context.

## User Review Required

- **Automatic Seat Generation**: Creating a show automatically copies all active physical seat configurations for the screen into `show_seats` database records. If a show gets cancelled/deleted, the seats inventory will be purged.
- **Strict Show Time Overlap Rules**: Scheduling/updating shows validates that no other show exists on the same `screen_id` with overlapping start and end times on the same date.
- **City-bound Movie Listings**: Customers can only discover movies that have active showtimes scheduled in theaters within their selected city.

## Open Questions

- **None**: All REST routes, database fields, and validation logic match the approved system design and API contracts.

---

## Proposed Changes

### [Database & Validation]

#### [MODIFY] [adminSchemas.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/validators/adminSchemas.js)
Define and export `showCreateSchema` and `showUpdateSchema` using Zod validation. Ensure date patterns match `YYYY-MM-DD` and validation constraints verify that `end_time` is after `start_time` and `show_date` is today or in the future.

---

### [Show Scheduling Module]

#### [NEW] [showRepository.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/repositories/showRepository.js)
Database queries for shows management: CRUD actions, soft deletions, and check functions to verify time overlaps for a screen on a specific date.

#### [NEW] [showService.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/services/showService.js)
Coordinates show scheduling:
1. Validates that the referenced movie and screen exist.
2. Checks for scheduling overlaps.
3. Uses a Knex transaction to save the show record and bulk-insert `show_seats` for all active seats on the screen.
4. Updates show details (if no bookings exist) and soft-deletes/cancels shows.

#### [NEW] [adminShowController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/adminShowController.js)
Handles request mappings for:
- `POST /api/v1/admin/shows`: Creates a show.
- `GET /api/v1/admin/shows`: Lists all shows with filters (`movie_id`, `screen_id`, `status`).
- `PUT /api/v1/admin/shows/:id`: Updates show parameters.
- `DELETE /api/v1/admin/shows/:id`: Cancels a show.

---

### [Movie Discovery Module]

#### [NEW] [movieController.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/controllers/movieController.js)
Customer-facing APIs:
- `GET /api/v1/movies`: Lists movies currently scheduled in the user's active city. Supports search, genre, language, age rating filtering, and paginated sorting.
- `GET /api/v1/movies/:id`: Gets detailed information for a specific movie.

---

### [Routing & Registration]

#### [MODIFY] [admin.routes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/admin.routes.js)
Mount the show management routes under `/shows`.

#### [NEW] [movie.routes.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/movie.routes.js)
Expose public movie discovery endpoints.

#### [MODIFY] [index.js](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/backend/src/routes/index.js)
Mount `movieRoutes` under `/movies`.

---

## Verification Plan

### Automated Tests
- Create `backend/tests/integration/shows.test.js` validating:
  - Overlap prevention (rejection with 422).
  - Seat layout generation matching physical seats count.
  - CRUD for shows under admin authorization rules.
  - City filtering, language/genre filtering, and title search for public movie discovery.
- Run tests via `npm test`.

### Manual Verification
- Verify database state and table constraints on `shows` and `show_seats` using sqlite3 command line.
