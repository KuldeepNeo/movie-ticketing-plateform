# Implementation Roadmap
## Movie Ticketing Platform (BookMyShow Clone)

| Document | Implementation Roadmap |
|---|---|
| **Version** | 1.0 |
| **Status** | Approved |
| **Author** | Senior Technical Lead |
| **Audience** | Backend Engineers, Frontend Engineers, QA Engineers, DevOps |

---

# 1. Global Planning Principles

All development activities must strictly adhere to the following dependency execution sequence to minimize blockers and integration friction.

**Implementation Sequence:**
1. `Foundation` (Project setups, dependencies)
2. `Database` (Migrations, Seeds)
3. `Backend` (Repositories, Services, Controllers, API Validation)
4. `Frontend` (Widgets, Screens, API Clients, State Management)
5. `Testing` (Unit, Widget)
6. `Integration` (End-to-End flows)

> **WARNING**
> Do not begin frontend API integration before the backend API endpoints are deployed and verifiable. Do not build API controllers before the Database schemas are migrated.

---

# 2. Detailed Technical Sprint Plan

---

## Sprint 1: Foundation & Identity

### Sprint Goal
Establish project scaffolding, configure the database, and implement the core authentication and session management flow.

### Implementation Order
1. Project Initialization (Node.js & Flutter)
2. Database Configuration & initial Migrations
3. User Repository & Auth Services
4. Auth API Controllers & Validation
5. Frontend Auth Screens & API Client setup
6. Auth State Management (Riverpod)
7. Unit Testing (Bcrypt, JWT)
8. Integration Testing (Login Flow)

### Backend Tasks
* Initialize Express.js, Knex.js, and SQLite environment.
* Create migration for `users` table.
* Implement JWT utility and Bcrypt password hashing.
* Build `authMiddleware`.
* Implement `POST /api/v1/auth/register`, `login`, `refresh`, `logout`, and `me`.

### Frontend Tasks
* Initialize Flutter project with Riverpod and GoRouter.
* Set up Dio client with interceptors for JWT injection and refresh logic.
* Build UI components: TextFields, Primary Buttons.
* Build Screens: Landing Page, Register Screen, Login Screen.
* Implement `authProvider` to manage user session state.

### QA Tasks
* Validate database table creation.
* Test JWT expiry and refresh token mechanism via Postman.
* Execute KPI-AUTH-001 through KPI-AUTH-006 test cases.

### Deliverables
* Knex configuration and initial migration scripts.
* Express API base structure and Auth endpoints.
* Flutter base structure and Auth screens.
* Auth API Postman collection.

### Dependencies
* **Internal**: Node.js/Flutter environment setup.
* **External**: None.
* **Blocking**: None.

### Definition of Done
✔ Project repos initialized.
✔ Auth APIs completed and returning standard responses.
✔ JWT tokens persist in Flutter Secure Storage.
✔ Users can register, login, and access protected routes.
✔ Unit tests passed for Auth flows.

### Risk Assessment
* **Technical Risk**: Mishandling refresh tokens could lead to infinite refresh loops on the frontend. *Mitigation*: Ensure Dio interceptor has a strict single-retry policy.
* **Security Risk**: Storing sensitive data insecurely. *Mitigation*: Use `flutter_secure_storage` for tokens, never plain shared preferences.

---

## Sprint 2: Admin Foundation (Inventory)

### Sprint Goal
Build the administrative foundation by enabling CRUD operations for static inventory entities (Cities, Movies, Theaters, Screens).

### Implementation Order
1. Database Migrations (Cities, Movies, Theaters, Screens, Seats)
2. Backend Repositories & Services for Inventory
3. API Controllers (Admin Routes)
4. RBAC Middleware integration
5. Web Admin Portal Layout & Routing
6. Frontend CRUD Views & State Management
7. Testing & Integration

### Backend Tasks
* Create migrations for `cities`, `movies`, `theaters`, `screens`, `seats`.
* Implement RBAC `roleMiddleware` requiring 'admin' role.
* Build REST CRUD APIs under `/api/v1/admin/movies`, `/theaters`, `/screens`.
* Implement logic to auto-generate `seats` rows when a `screen` is created.
* Create `GET /api/v1/cities` public endpoint.

### Frontend Tasks
* Set up Admin Portal web-only responsive layout.
* Build Movie list, add, edit forms (with validation).
* Build Theater and Screen management views.
* Implement City Selector modal for the Customer App.

### QA Tasks
* Validate RBAC strictly denies customer tokens from accessing Admin APIs.
* Verify correct number of seats are generated in DB upon screen creation.
* Execute KPI-ADM-001 through KPI-ADM-005.

### Deliverables
* 5 new database tables.
* 13 new API endpoints (12 Admin, 1 Public).
* Admin Portal Dashboard and CRUD UI.
* Customer City selection UI.

### Dependencies
* **Blocking**: Sprint 1 Auth completion (Admin users need to log in).

### Definition of Done
✔ Database schema extended with all inventory tables.
✔ Admin APIs secured by RBAC.
✔ Admin Web UI allows complete management of movies and theaters.
✔ Integration tests passed for API CRUD cycles.

### Risk Assessment
* **Technical Risk**: Managing complex form states (e.g., Seat Layout generation) in Flutter. *Mitigation*: Use `flutter_hooks` and robust Riverpod providers to manage local form state independently from global state.

---

## Sprint 3: Scheduling & Discovery

### Sprint Goal
Connect inventory to users by building Admin Show scheduling APIs and Customer Movie discovery/filtering UI.

### Implementation Order
1. Database Migrations (`shows`, `show_seats`)
2. Show Scheduling Backend Logic (Overlap prevention)
3. Movie Listing Backend Logic (Search/Filter Queries)
4. Admin UI for Show Scheduling
5. Customer UI for Movie Listing & Details
6. Unit Testing (Query Builders, Overlap logic)
7. Integration

### Backend Tasks
* Create migrations for `shows` and `show_seats`.
* Implement overlap detection logic in `showService.js`.
* Build `POST /api/v1/admin/shows` (auto-generates `show_seats` records).
* Implement `GET /api/v1/movies` with dynamic query building (search, genre, city_id).
* Implement `GET /api/v1/movies/:id`.

### Frontend Tasks
* Admin UI: Show scheduling form with Date/Time pickers.
* Customer App: Homepage "Now Showing" horizontal lists.
* Customer App: Search overlay and Filter chips.
* Customer App: Movie Details Screen with posters and metadata.

### QA Tasks
* Thoroughly test the Knex query builder for movie search/filtering correctness.
* Attempt scheduling overlapping shows to verify rejection (KPI-ADM-007).
* Validate `show_seats` generation for large screens.
* Execute KPI-MOV-001 to KPI-MOV-005.

### Deliverables
* Shows/ShowSeats tables.
* Show scheduling API and UI.
* Customer Movie Discovery API and UI.

### Dependencies
* **Blocking**: Sprint 2 completion (Requires movies and screens to schedule a show).

### Definition of Done
✔ Admins can schedule shows without overlaps.
✔ Shows automatically generate seat inventory instances.
✔ Customers can browse, search, and view movie details by city.
✔ Unit tests passed for show overlap logic.

### Risk Assessment
* **Performance Risk**: Heavy queries on `movies` table. *Mitigation*: Add composite indexes defined in database-design.md (`idx_movies_status_title`).

---

## Sprint 4: Booking Core (Seat Selection)

### Sprint Goal
Implement the core booking transaction path, rendering the interactive seat map and enforcing strict concurrency locking in the backend.

### Implementation Order
1. Database Migrations (`bookings` table)
2. Knex Transaction Logic (Seat Locking)
3. APIs for Showtimes and Seat Layout
4. Frontend Theater/Date Selection UI
5. Frontend Interactive Seat Grid UI
6. Concurrency Testing
7. Integration

### Backend Tasks
* Create migration for `bookings`.
* Implement `GET /api/v1/movies/:movieId/shows` grouped by Theater.
* Implement `GET /api/v1/shows/:showId/seats` fetching real-time status.
* Implement `POST /api/v1/bookings`: The critical transaction block wrapping `SELECT FOR UPDATE` (or SQLite equivalent concurrency handling) to lock `show_seats` and create a pending `booking`.

### Frontend Tasks
* Build Date and Theater selector screens.
* Build the `SeatGrid` widget handling 3 states (Available, Locked, Selected) with pan/zoom capabilities for mobile.
* Build Booking Summary sticky footer.
* Implement polling or refresh mechanisms for seat map updates.

### QA Tasks
* Load testing (JMeter) hitting the `/bookings` endpoint simultaneously to ensure 0 double-bookings.
* Execute KPI-THEATER-001, KPI-SEAT-001 through KPI-SEAT-006, KPI-EDGE-001.

### Deliverables
* Seat locking transaction APIs.
* Interactive Seat Selection UI.
* Concurrency Load Test Report.

### Dependencies
* **Blocking**: Sprint 3 completion (Requires scheduled shows).

### Definition of Done
✔ Seat map accurately renders DB state.
✔ Users can select up to 10 seats.
✔ Submitting booking locks seats exclusively for the user.
✔ Concurrency testing confirms race conditions are mitigated.

### Risk Assessment
* **Technical Risk**: SQLite concurrency limitations in high-load writes. *Mitigation*: Enable WAL (Write-Ahead Logging) mode and use strict transaction isolation. If SQLite locks too frequently, limit concurrent workers in Node.js.

---

## Sprint 5: Checkout & Ticketing

### Sprint Goal
Finalize the transaction by simulating payments, generating digital tickets, and providing access to booking history.

### Implementation Order
1. Database Migrations (`payments`, `tickets`)
2. Backend Payment Simulation & Ticket Generation
3. Booking History APIs
4. Frontend Checkout & Payment UI
5. Frontend Digital Ticket QR View
6. Frontend My Bookings List
7. End-to-End Integration

### Backend Tasks
* Create migrations for `payments` and `tickets`.
* Implement `POST /api/v1/bookings/:id/payment` (verifies lock expiration, updates booking to 'confirmed', inserts payment, generates random QR token, inserts ticket).
* Implement `GET /api/v1/bookings` (user history).

### Frontend Tasks
* Build Checkout screen showing Subtotal, Convenience Fee, Total.
* Build Simulated Payment Gateway modal.
* Build Digital Ticket UI with QR Code renderer (`qr_flutter` package).
* Build "My Bookings" list view and history logic.

### QA Tasks
* Validate mathematical correctness of fees and totals.
* Test payment timeouts (verifying seat locks expire and return to available).
* Execute KPI-CHK-001 to KPI-CHK-003, KPI-PAY-001 to KPI-PAY-004, KPI-TICKET-001 to KPI-TICKET-004.

### Deliverables
* Payment and Ticket tables/APIs.
* End-to-end booking flow completion.
* User history UI.

### Dependencies
* **Blocking**: Sprint 4 completion (Requires locked bookings).

### Definition of Done
✔ Payment endpoint properly updates booking state to confirmed.
✔ Digital tickets generated with unique tokens.
✔ Users can view past tickets in their profile.
✔ E2E tests pass for the entire booking journey.

### Risk Assessment
* **Business Risk**: Payment processing state mismatches. *Mitigation*: Ensure the payment API endpoint uses a strict state machine pattern (cannot pay if status != 'seats_locked').

---

## Sprint 6: Polish & Launch Prep

### Sprint Goal
Stabilize the platform, finalize admin reporting, and ensure performance meets SLAs.

### Implementation Order
1. Admin Report APIs (Aggregations)
2. Admin Dashboard UI Data Binding
3. Edge Case Error Handling
4. UI Polish & Responsiveness Audits
5. UAT & Load Testing

### Backend Tasks
* Implement `GET /api/v1/admin/reports/bookings` using Knex aggregations (`sum`, `count`).
* Centralize error handling formatting.
* Fine-tune database indexes.

### Frontend Tasks
* Connect Admin Dashboard charts/tables to reports API.
* Audit all forms for consistent error messages.
* Verify responsiveness across Web, iOS simulator, Android simulator, and Tablet layouts.

### QA Tasks
* Execute all Edge Case KPIs (KPI-EDGE-001 to KPI-EDGE-008).
* Full regression test suite run.

### Deliverables
* Admin Reports module.
* Release Candidate Build (Web, APK, IPA).

### Dependencies
* **Blocking**: Sprint 5 completion.

### Definition of Done
✔ Admin reports populate accurately.
✔ All documented Edge Cases are handled gracefully.
✔ No P1/P2 bugs remain in the backlog.
✔ Build is ready for MVP deployment.

### Risk Assessment
* **Release Risk**: Last-minute environment configuration bugs. *Mitigation*: Ensure `env.js` strict validation is heavily tested in staging before production cutover.

---

# 3. Module Implementation Details

| Module Name | Feature IDs | BDD Scenarios | Database Tables | API Endpoints | Frontend Pages | Backend Components | Testing Activities | Acceptance Criteria | Est. Complexity | Dependencies |
|---|---|---|---|---|---|---|---|---|---|---|
| **Authentication** | F-001, F-002 | Registration, Login, Session | `users` | `/auth/register`, `/auth/login`, `/auth/logout`, `/auth/refresh` | Login, Register | `authService`, `authController`, `jwtHelper` | JWT Unit Tests, Auth API Integration | Tokens generated, passwords hashed | Medium | None |
| **City Mgmt** | F-003 | Change City | `cities` | `/cities` | City Selector Modal | `cityController`, `cityRepository` | API Retrieval | City list populates dynamically | Low | None |
| **Admin Inventory** | F-014, F-015 | Admin CRUD (Movie, Theater, Screen) | `movies`, `theaters`, `screens`, `seats` | `/admin/movies`, `/admin/theaters`, `/admin/screens` | Admin Dashboard, CRUD Forms | `adminService`, RBAC Middleware | RBAC validation, Seat Generation Unit Tests | Only admins access, CRUD functional | High | Auth |
| **Discovery** | F-004, F-005, F-006, F-007 | Browse, Search, Filter, Details | `movies` | `/movies`, `/movies/:id` | Homepage, Search View, Movie Details | Query builders in `movieRepository` | Index testing, Filter edge cases | Search returns accurate results < 300ms | Medium | Admin Inventory |
| **Show Mgmt** | F-016 | Admin Show Schedule | `shows`, `show_seats` | `/admin/shows` | Admin Scheduling Form | Overlap logic in `showService` | Overlap prevention Unit Tests | Cannot schedule overlapping shows | High | Admin Inventory |
| **Booking Core** | F-008, F-009 | Theater/Show browse, Seat Selection | `bookings`, `show_seats` | `/movies/:id/shows`, `/shows/:id/seats`, `/bookings` (POST) | Theater View, Interactive Seat Grid | DB Transaction locking, `bookingService` | Concurrency Load Testing | Seat map renders, Locks prevent race conditions | High | Show Mgmt |
| **Checkout & Tickets** | F-010, F-011, F-012, F-013 | Checkout, Payment, Digital Ticket, History | `payments`, `tickets`, `bookings` | `/bookings/:id/payment`, `/bookings` (GET), `/bookings/:id` | Checkout Summary, Payment Modal, Ticket View, My Bookings | Payment Simulator logic, Token generation | State machine validation, Timeout testing | Payment confirms booking, QR generated | Medium | Booking Core |
| **Admin Reports** | N/A | Admin Reports | *Aggregated Data* | `/admin/reports/bookings` | Admin Analytics Page | Knex Aggregation Queries | Data accuracy validation | Reports match DB actuals | Low | Checkout |
