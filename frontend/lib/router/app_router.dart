import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/landing_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/home_screen.dart';
import '../features/auth/presentation/screens/admin_shell_layout.dart';
import '../features/auth/presentation/screens/admin_movies_screen.dart';
import '../features/auth/presentation/screens/admin_theaters_screen.dart';
import '../features/auth/presentation/screens/admin_screens_screen.dart';
import '../features/auth/presentation/screens/admin_shows_screen.dart';
import '../features/auth/presentation/screens/movie_details_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movies/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MovieDetailsScreen(movieId: id);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellLayout(child: child),
        routes: [
          GoRoute(
            path: '/admin/movies',
            builder: (context, state) => const AdminMoviesScreen(),
          ),
          GoRoute(
            path: '/admin/theaters',
            builder: (context, state) => const AdminTheatersScreen(),
          ),
          GoRoute(
            path: '/admin/theaters/:theaterId/screens',
            builder: (context, state) {
              final theaterIdStr = state.pathParameters['theaterId'] ?? '0';
              final theaterId = int.tryParse(theaterIdStr) ?? 0;
              return AdminScreensScreen(theaterId: theaterId);
            },
          ),
          GoRoute(
            path: '/admin/shows',
            builder: (context, state) => const AdminShowsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final status = authState.status;
      final matchedLocation = state.matchedLocation;

      // Allow loading states to complete
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }

      final isAuthenticated = status == AuthStatus.authenticated;
      final isAdmin = isAuthenticated && authState.user?.role == 'admin';

      // Public route check
      final isPublicRoute = matchedLocation == '/' || 
                            matchedLocation == '/login' || 
                            matchedLocation == '/register';

      final isAdminRoute = matchedLocation.startsWith('/admin');

      if (!isAuthenticated) {
        if (!isPublicRoute) {
          return '/';
        }
        return null;
      }

      // If authenticated
      if (isAdmin) {
        // Admins should always stay on admin pages
        if (!isAdminRoute) {
          return '/admin/movies';
        }
        return null;
      } else {
        // Customers should never access admin pages
        if (isAdminRoute) {
          return '/home';
        }
        if (isPublicRoute) {
          return '/home';
        }
        return null;
      }
    },
  );
});
