# Implementation Plan - Sprint 3: Scheduling & Discovery Frontend

Implement the user interface and state management for scheduling movie shows (for Admins) and discovering movies by city/filters/search (for Customers) in the Flutter application.

## User Review Required

- **Scheduling Interface (Admin)**: Form includes selecting a published movie, selecting an active screen (grouped by theater), selecting a show date, start time, end time, and ticket price.
- **Movie Discovery UI (Customer)**: Refreshed home dashboard featuring a city selector, search bar, filter chips (for genres, languages, age ratings), and a "Now Showing" movie grid.
- **Detailed View (Customer)**: Movie details page showing synopsis, duration, rating, language, and genre details.

## Open Questions

- **None**: Interface designs and routing align directly with the API contracts and master KPIs.

---

## Proposed Changes

### [Core Config & Routing]

#### [MODIFY] [api_constants.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/constants/api_constants.dart)
Add show scheduling and public movies endpoints:
- `static const String adminShows = '/admin/shows';`
- `static String adminShow(int id) => '/admin/shows/$id';`
- `static const String movies = '/movies';`
- `static String movieDetails(int id) => '/movies/$id';`

#### [MODIFY] [app_router.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/router/app_router.dart)
Mount the shows panel and public movie details routes:
- `/admin/shows`: `AdminShowsScreen` (inside `ShellRoute` matching `AdminShellLayout`)
- `/movies/:movieId`: `MovieDetailsScreen`

---

### [Domain Layer]

#### [NEW] [show_model.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/show_model.dart)
Create show representation structure matching backend schema (`id`, `movie_id`, `screen_id`, `show_date`, `start_time`, `end_time`, `ticket_price`, `status`, `total_seats_created`).

---

### [State Management Providers]

#### [NEW] [admin_show_provider.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/admin_show_provider.dart)
Create `AdminShowNotifier` managing paginated shows list:
- `fetchShows()`: Retrieves all scheduled shows.
- `createShow()`: Sends scheduled parameters.
- `updateShow()`: Updates pricing or details.
- `deleteShow()`: Cancels show times.

#### [NEW] [customer_movie_provider.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/customer_movie_provider.dart)
Create `CustomerMovieNotifier` for customer browsing:
- Auto-fetches published movies whenever selected city context changes.
- Supports search inputs, filter selections (language, genre, rating), page offsets, and limit bounds.

---

### [UI Modules]

#### [MODIFY] [admin_shell_layout.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/admin_shell_layout.dart)
Add "Shows" sidebar option directing to `/admin/shows`.

#### [NEW] [admin_shows_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/admin_shows_screen.dart)
Build Admin panel listing all scheduled shows:
- Button to open "Schedule Show" dialog.
- Dropdowns for choosing Movie (filtered by published state) and Screen (grouped by Theater).
- DatePicker and TimePickers for start/end parameters.
- Overlap validation checks integration displaying response messages.

#### [MODIFY] [home_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/home_screen.dart)
Update Homepage UI:
- Search text box with interactive debounce.
- Genre/Language/AgeRating scrollable Filter Chips.
- "Now Showing" movies card grid/list displaying poster thumbnail, title, language, and genre tag. Clicking navigates to details.

#### [NEW] [movie_details_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/movie_details_screen.dart)
Create customer detail screen:
- High-fidelity banner cover image.
- Title header with age rating badge and duration description.
- Detailed synopsis scroll viewport.

---

## Verification Plan

### Automated Tests
- Create unit/widget tests for:
  - `customer_movie_provider_test.dart`: Validates filter chips selections, search input updates, and API parameter translation.
  - `admin_shows_screen_test.dart`: Validates scheduling dialog fields, date validation checks (for end time > start time), and form submission trigger.
- Run tests via `flutter test`.

### Manual Verification
- Deploy backend and run Flutter web locally to check responsive behaviors for both Admin Scheduling lists and Customer movie carousels.
