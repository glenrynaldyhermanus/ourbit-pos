import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/app/cashier/cashier_page.dart';
import 'package:ourbit_pos/app/login/login_page.dart';
import 'package:ourbit_pos/app/management/management_page.dart';

import 'package:ourbit_pos/app/organization/organization_page.dart';
import 'package:ourbit_pos/app/cashier/payment/payment_page.dart';
import 'package:ourbit_pos/app/cashier/payment/success_page.dart';
import 'package:ourbit_pos/app/reports/reports_page.dart';
import 'package:ourbit_pos/app/settings/settings_page.dart';
import 'package:flutter/foundation.dart';
import 'package:ourbit_pos/src/core/services/token_service.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class AppRouter {
  static const String loginRoute = '/login';
  static const String posRoute = '/pos';
  static const String managementRoute = '/management';
  static const String organizationRoute = '/organization';
  static const String reportsRoute = '/reports';
  static const String settingsRoute = '/settings';
  static const String paymentRoute = '/payment';
  static const String successRoute = '/success';

  // Helper method untuk fade transition
  static Page<void> _buildPageWithFadeTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      Logger.debug('AppRouter - Redirect called for: ${state.matchedLocation}');

      // Check if user is authenticated
      try {
        // First, try to handle token from URL if on web
        if (kIsWeb) {
          final hasToken = await TokenService.handleTokenFromUrl();
          if (hasToken) {
            Logger.debug('AppRouter - Token found, redirecting to POS');
            return posRoute;
          }
        }

        // Check if user is authenticated via Supabase
        final isAuthenticated = await SupabaseService.isUserAuthenticated();
        Logger.debug('AppRouter - isAuthenticated: $isAuthenticated');

        if (isAuthenticated) {
          // If authenticated and on root path, redirect to POS
          if (state.matchedLocation == '/') {
            Logger.debug(
                'AppRouter - Authenticated on root, redirecting to POS');
            return posRoute;
          }

          Logger.debug(
              'AppRouter - Authenticated, allowing access to: ${state.matchedLocation}');
          return null; // Allow access to requested route
        }
      } catch (e) {
        Logger.debug('AppRouter - Error in redirect: $e');
        // ignore: empty_catches
      }

      Logger.debug('AppRouter - Not authenticated, redirecting to login');
      // If not authenticated, redirect to login
      return loginRoute;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) {
          // Check if there are token parameters
          final token = state.uri.queryParameters['token'];
          final expiry = state.uri.queryParameters['expiry'];

          if (token != null && expiry != null) {
            // Token will be handled by the global redirect above
            return null;
          }

          // No token, redirect to login
          return loginRoute;
        },
      ),
      GoRoute(
        path: loginRoute,
        name: 'login',
        pageBuilder: (context, state) {
          try {
            return _buildPageWithFadeTransition(
              context,
              state,
              const LoginPage(),
            );
          } catch (e) {
            Logger.error('Failed to build login page: $e');
            return MaterialPage(
              child: Scaffold(
                body: Center(
                  child: Text('Error loading login page: $e'),
                ),
              ),
            );
          }
        },
      ),
      GoRoute(
        path: posRoute,
        name: 'pos',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const CashierPage(),
        ),
      ),
      GoRoute(
        path: managementRoute,
        name: 'management',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const ManagementPage(),
        ),
      ),
      GoRoute(
        path: organizationRoute,
        name: 'organization',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const OrganizationPage(),
        ),
      ),
      GoRoute(
        path: reportsRoute,
        name: 'reports',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const ReportsPage(),
        ),
      ),
      GoRoute(
        path: settingsRoute,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const SettingsPage(),
        ),
      ),
      GoRoute(
        path: paymentRoute,
        name: 'payment',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const PaymentPage(),
        ),
      ),
      GoRoute(
        path: successRoute,
        name: 'success',
        pageBuilder: (context, state) => _buildPageWithFadeTransition(
          context,
          state,
          const SuccessPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(loginRoute),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
}
