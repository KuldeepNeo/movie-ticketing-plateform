# Frontend Project Structure & Setup
## Movie Ticketing Platform (BookMyShow Clone)

| Document | Frontend Project Structure Specification |
|---|---|
| **Version** | 1.0 |
| **Status** | Approved |
| **Author** | Senior Solution Architect |
| **Audience** | Frontend Team (Flutter), UI/UX Team |

---

## 1. Architectural Overview

The frontend will be built using **Flutter** and **Dart**, generating responsive applications for Web, iOS, Android, and Tablets from a single codebase.

### Architectural Pattern: Feature-First (Clean Architecture)
To ensure scalability, especially given the dual nature of the application (Customer App vs. Admin Portal), the codebase will follow a **Feature-First** organization combined with Clean Architecture principles.

*   **Presentation Layer**: UI Widgets, Screens, and State Controllers.
*   **Domain Layer**: Entities, Models, and Repository Interfaces (abstracting the data origin).
*   **Data Layer**: Data Sources (API Clients, Local Storage), Data Transfer Objects (DTOs), and Repository Implementations.

### State Management & Dependency Injection
*   **Riverpod (`flutter_riverpod`)**: Chosen for its compile-time safety, testability, and clean dependency injection capabilities. It will bridge the Presentation layer with the Domain/Data layers.

### Routing
*   **GoRouter (`go_router`)**: A declarative routing package that supports deep linking (essential for web) and allows for robust nested navigation and authentication guards.

---

## 2. High-Level Folder Structure

```text
movie_ticketing_app/
├── android/                  # Native Android configuration
├── ios/                      # Native iOS configuration
├── web/                      # Native Web configuration
├── assets/                   # Images, fonts, icons
│   ├── images/
│   └── fonts/
├── lib/                      # Main Dart source code
│   ├── core/                 # Shared foundational code (Theme, Network, Utils)
│   ├── features/             # Feature-specific modules
│   ├── l10n/                 # Localization / Translations (.arb files)
│   ├── router/               # Global routing configuration
│   └── main.dart             # Application entry point
├── pubspec.yaml              # Project dependencies and asset definitions
└── test/                     # Unit and Widget tests
```

---

## 3. Detailed Directory Breakdown

### 3.1 `lib/core/`
Contains code that is shared across the entire application. It is strictly agnostic to specific features.
*   `core/constants/`: App-wide constants (e.g., `api_constants.dart`, `app_colors.dart`).
*   `core/theme/`: Dark/Light theme definitions (`app_theme.dart`), typography, and custom UI components shared globally (e.g., `primary_button.dart`).
*   `core/network/`: HTTP client setup (e.g., `dio_client.dart`), interceptors for adding JWT tokens, and global API error handling.
*   `core/local_storage/`: Wrappers for Secure Storage (for refresh tokens) and Shared Preferences.
*   `core/errors/`: Custom exception classes (`NetworkException`, `AuthException`).
*   `core/utils/`: Formatting helpers (date formatters, currency formatters).

### 3.2 `lib/features/`
The application is split into distinct functional domains. Each feature contains its own isolated Presentation, Domain, and Data layers.

**Feature List:**
*   `auth/`: Registration, Login, Session state.
*   `movies/`: Movie discovery, listings, details.
*   `bookings/`: Seat selection, payment flow, ticket generation, booking history.
*   `admin_dashboard/`: Web-only admin panel for managing inventory.

**Internal Structure of a Feature (e.g., `lib/features/bookings/`)**:

```text
bookings/
├── data/
│   ├── data_sources/         # Remote APIs (e.g., booking_api_client.dart)
│   ├── dtos/                 # JSON serialization models (e.g., booking_dto.dart)
│   └── repositories/         # Concrete implementation of domain interfaces
├── domain/
│   ├── entities/             # Core business objects (e.g., booking_entity.dart)
│   └── repositories/         # Interfaces (e.g., i_booking_repository.dart)
└── presentation/
    ├── controllers/          # Riverpod Notifiers/Providers holding state
    ├── screens/              # Full page views (e.g., seat_selection_screen.dart)
    └── widgets/              # Feature-specific UI components (e.g., seat_grid.dart)
```

### 3.3 `lib/router/`
Centralized navigation management using `go_router`.
*   `app_router.dart`: Defines all route paths (`/movies`, `/booking/:id`).
*   `auth_guard.dart`: Redirect logic (e.g., kicking unauthenticated users to `/login`, or blocking non-admins from `/admin/*`).

---

## 4. Platform-Specific Configurations

### Web & Tablet Responsiveness
Since the Admin portal is Web-only and the User app spans Web/Mobile/Tablet:
*   The UI will heavily utilize **LayoutBuilders** and **Responsive wrappers** to adapt screen real estate.
*   `core/utils/responsive_layout.dart` will dictate breakpoints (Mobile < 600px, Tablet 600px-1024px, Desktop > 1024px).

### Environment Management
*   Using `--dart-define` for compile-time environment variables (e.g., API Base URLs).
*   `core/config/env_config.dart` reads these variables to configure the app for `dev`, `staging`, or `prod`.

---

## 5. Execution Flow Example (Seat Selection)

1.  **Screen (Presentation)**: The user navigates to `SeatSelectionScreen(showId: 10)`.
2.  **Controller (Presentation)**: The screen watches a Riverpod provider: `ref.watch(seatLayoutProvider(showId))`.
3.  **Repository (Domain/Data)**: The provider triggers the `BookingRepository.getSeats(showId)`.
4.  **Data Source (Data)**: The repository calls the `BookingApiClient`, which makes a `GET /api/v1/shows/10/seats` HTTP request via the core `Dio` client.
5.  **Data Parsing**: The raw JSON is converted to DTOs, mapped to Domain Entities, and returned to the Provider.
6.  **State Update**: The Riverpod provider updates its state with the `AsyncData(seats)`.
7.  **UI Rebuild**: The `SeatSelectionScreen` automatically rebuilds, switching from a loading spinner to the interactive `SeatGrid` widget displaying available, locked, and booked seats.

---

## 6. Initialization & Dependencies

### Key `pubspec.yaml` Dependencies
*   `flutter_riverpod`: State Management.
*   `go_router`: Declarative routing.
*   `dio`: HTTP client with interceptors.
*   `freezed` & `json_serializable`: Immutable models and JSON parsing (dev dependencies).
*   `flutter_secure_storage`: Secure local storage for JWT Refresh Tokens.
*   `intl`: Date and currency formatting.

### Required Developer Commands
```bash
# Fetch dependencies
flutter pub get

# Run code generation (for Freezed and JSON Serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app locally on Web (simulating production APIs)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

---

## 7. Testing Strategy

*   `test/unit/`: Testing pure Dart logic (Domain entities, formatting utils, Riverpod state controllers using mock repositories).
*   `test/widget/`: Testing individual UI components (e.g., verifying `SeatGrid` renders correctly based on different seat state inputs).
*   `test/integration/`: End-to-end testing of critical flows (e.g., complete checkout journey) using `integration_test` package running on a simulator/browser.
