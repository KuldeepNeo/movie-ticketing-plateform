import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/landing_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
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
    ],
    redirect: (context, state) {
      final status = authState.status;
      final matchedLocation = state.matchedLocation;

      // Allow loading states to complete
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }

      final isAuthenticated = status == AuthStatus.authenticated;
      
      // Public route check
      final isPublicRoute = matchedLocation == '/' || 
                            matchedLocation == '/login' || 
                            matchedLocation == '/register';

      if (!isAuthenticated && !isPublicRoute) {
        // Redirect to landing if trying to access protected route without login
        return '/';
      }

      if (isAuthenticated && isPublicRoute) {
        // Redirect to home if logged-in user hits landing or sign in pages
        return '/home';
      }

      return null;
    },
  );
});
