# Implementation Plan - Sprint 2: Admin Foundation (Inventory) Frontend

Act as the Frontend Flutter Developer. This plan covers the components, screens, routing, state management, and integrations required for Sprint 2 Frontend features.

## Goal Description

Build the user interface and state management for:
1. **Admin Portal**: Responsive web-friendly layout providing full CRUD operations for Movies, Theaters, and Screens.
2. **Customer App - City Selector**: A modal dialog prompting users to choose an active city on home page load, with persistent selection.

## User Review Required

- **Routing Redirects**: If an admin logs in, they will be redirected to `/admin/movies`. If they try to access customer pages or if a customer tries to access `/admin/**`, they will be redirected appropriately.
- **Seat Category Mapping UI**: In the screen creation view, the admin can select categories (Classic, Premium, Recliner) for each row dynamically based on the input rows count. The frontend will serialize this row-by-row mapping to the backend.

## Open Questions

- **None**: All UI flows and states are aligned with the approved system design and API contracts.

---

## Proposed Changes

### [Models & API Clients]

#### [NEW] [city_model.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/city_model.dart)
Define the `CityModel` mapping `id` and `name`.

#### [NEW] [movie_model.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/movie_model.dart)
Define the `MovieModel` for admin listing and CRUD.

#### [NEW] [theater_model.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/theater_model.dart)
Define `TheaterModel` and `ScreenModel` entities.

---

### [State Management (Riverpod)]

#### [NEW] [city_provider.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/city_provider.dart)
Manage public cities list and selected city state. Stores selected city ID in shared preferences (or secure storage) for persistent sessions.

#### [NEW] [admin_movie_provider.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/admin_movie_provider.dart)
AsyncNotifier managing Admin Movie list, pagination, and triggers for Create, Update, and Delete.

#### [NEW] [admin_theater_provider.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/admin_theater_provider.dart)
AsyncNotifier managing Admin Theater list, and CRUD actions.

#### [NEW] [admin_screen_provider.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/admin_screen_provider.dart)
AsyncNotifier managing screens list and Screen/Seat Layout generation.

---

### [User Interface & Views]

#### [NEW] [admin_shell_layout.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/admin_shell_layout.dart)
Responsive shell layout containing a sidebar on desktop/web and drawer on mobile, providing routing switches for Movies and Theaters.

#### [NEW] [admin_movies_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/admin_movies_screen.dart)
Admin movie list grid view showing posters, status, and containing action buttons to trigger add/edit dialog forms.

#### [NEW] [movie_form_dialog.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/widgets/movie_form_dialog.dart)
Custom dialog form for adding/editing a movie with complete validation (synopsis lengths, URL structures, ratings dropdown).

#### [NEW] [admin_theaters_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/admin_theaters_screen.dart)
List view for theaters with options to edit, delete, or manage screens. Contains forms for theater CRUD.

#### [NEW] [admin_screens_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/admin_screens_screen.dart)
Screen management view for a specific theater. Includes screen details, rows count, columns count, and row-by-row seat category selector configuration.

#### [NEW] [city_selector_dialog.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/widgets/city_selector_dialog.dart)
A beautiful dialog listing active cities. Automatically pops up on `HomeScreen` if no city is currently selected.

#### [MODIFY] [home_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/home_screen.dart)
Connect home screen to city selector. Displays the selected city in the AppBar with a button to switch cities.

---

### [Routing & Setup]

#### [MODIFY] [app_router.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/router/app_router.dart)
Add routes:
- `/admin/movies`
- `/admin/theaters`
- `/admin/theaters/:theaterId/screens`
In GoRouter's `redirect` logic, automatically route admins to `/admin/movies` and protect all `/admin/**` routes from non-admin accounts.

---

## Verification Plan

### Manual Verification
- Log in with Admin credentials (`admin@example.com` / `SecureP@ss1`): verify immediate redirect to the Admin Portal.
- Create, read, update, and delete movies, theaters, and screens. Verify that seats are generated correctly in the DB.
- Log in with Customer credentials (`john@example.com` / `SecureP@ss1`): verify popup city selector prompt.
- Select a city, verify persistence on hot restarts, and verify that the selected city is visible in the AppBar.
