# Implementation Plan - Sprint 1: Foundation & Identity - Frontend Implementation

Act as the Frontend Flutter Developer. This plan covers setting up the Flutter project structure, configuring state management with Riverpod, implementing secure JWT persistence, coding the Dio network client with automatic 401 token refresh, setting up GoRouter routing, and building the auth screens.

## Proposed Changes

We will build the frontend files inside the `frontend/` directory.

### Core Utilities & Storage

#### [NEW] [lib/core/constants/api_constants.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/constants/api_constants.dart)
Defines API endpoints (register, login, refresh, me, logout) and reads base URL using compile-time environment definitions: `const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api/v1')`.

#### [NEW] [lib/core/constants/app_colors.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/constants/app_colors.dart)
Defines colors for dark/light premium aesthetic (sleek slate, vibrant primary gold/amber, deep dark backgrounds).

#### [NEW] [lib/core/local_storage/secure_storage_service.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/local_storage/secure_storage_service.dart)
Wraps `FlutterSecureStorage` to read, write, and delete:
- Access Token (`access_token`)
- Refresh Token (`refresh_token`)

#### [NEW] [lib/core/network/dio_client.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/network/dio_client.dart)
Configures a Dio HTTP client provider:
- Injects Authorization Header Interceptor: Automatically attaches the access token if stored.
- Auto-Refresh Interceptor: Intercepts `401 Unauthorized` responses. If a 401 occurs, it halts requests, requests a new access token via `POST /auth/refresh`, stores the new token, and retries the original request. If refresh fails, it clears tokens and invalidates the session.

---

### Authentication Domain & Data Layer

#### [NEW] [lib/features/auth/domain/entities/user_entity.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/entities/user_entity.dart)
Defines the User model containing: `id`, `name`, `email`, and `role`. Includes manual `fromJson()` mapper.

#### [NEW] [lib/features/auth/domain/repositories/i_auth_repository.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/domain/repositories/i_auth_repository.dart)
Declares auth interface methods: `register`, `login`, `logout`, `fetchProfile`, `refreshToken`.

#### [NEW] [lib/features/auth/data/data_sources/auth_api_client.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/data/data_sources/auth_api_client.dart)
Makes network calls to auth endpoints using the custom `Dio` client.

#### [NEW] [lib/features/auth/data/repositories/auth_repository_impl.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/data/repositories/auth_repository_impl.dart)
Implements `IAuthRepository` using `AuthApiClient` and `SecureStorageService`.

---

### Presentation Layer & Routing

#### [NEW] [lib/features/auth/presentation/controllers/auth_controller.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/controllers/auth_controller.dart)
A Riverpod `StateNotifier` managing state: `AuthStatus` (initial, loading, authenticated, unauthenticated, error), error message, and `UserEntity`.
Handles:
- `register(name, email, password, confirmPassword)`
- `login(email, password)`
- `logout()`
- `initializeSession()` (checks secure storage on startup and fetches `/auth/me` profile).

#### [NEW] [lib/core/widgets/primary_button.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/widgets/primary_button.dart)
Reusable elevated button with custom styling, gradient, and loading state spinner.

#### [NEW] [lib/core/widgets/custom_text_field.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/core/widgets/custom_text_field.dart)
Reusable input field supporting validation messages, obscure text toggles for passwords, and customized borders.

#### [NEW] [lib/features/auth/presentation/screens/landing_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/landing_screen.dart)
Landing page introducing the platform, routing users to either Login or Register.

#### [NEW] [lib/features/auth/presentation/screens/login_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/login_screen.dart)
Provides user login forms with real-time field validation, error alerts, and password visibility toggle.

#### [NEW] [lib/features/auth/presentation/screens/register_screen.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/features/auth/presentation/screens/register_screen.dart)
Form for registration enforcing password constraints before network submission.

#### [NEW] [lib/router/app_router.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/router/app_router.dart)
Configures `GoRouter` declaring routes: `/`, `/login`, `/register`, `/home` (placeholder protected homepage). Integrates auth guard redirects.

#### [MODIFY] [lib/main.dart](file:///Users/neo/Desktop/Vibe%20Coding%20Training/vibe_projects/movie-ticketing-platform%20/frontend/lib/main.dart)
Entry point bootstrap wrapping the widget tree in `ProviderScope` and registering `MaterialApp.router`.

---

## Verification Plan

### Automated Tests
- Create widget and unit test suites:
  - `test/unit/auth_controller_test.dart`: Mocks the AuthRepository and verifies the state modifications in `authController`.
  - `test/widget/login_screen_test.dart`: Validates input form UI validations and button triggers.

Run tests:
```bash
flutter test
```

### Manual Verification
- Launch the application:
  ```bash
  flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
  ```
- Register a user and assert correct transitions.
- Log in and assert access to protected home screen.
- Stop and start the application again to verify the JWT session is parsed from Secure Storage and auto-restored.
