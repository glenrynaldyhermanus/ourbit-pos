import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/blocs/appbar_bloc.dart';
import 'package:ourbit_pos/blocs/appbar_event.dart';
import 'package:ourbit_pos/blocs/appbar_state.dart';
import 'package:ourbit_pos/src/core/services/token_service.dart';
import 'package:ourbit_pos/src/core/routes/app_router.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_theme_toggle.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

/// Global custom appbar widget for Ourbit POS application
///
/// This widget provides a consistent header across the application with:
/// - Business name and store name display
/// - User information with avatar
/// - Custom actions support
/// - Automatic data loading from local storage
/// - Real role data from database (e.g., "Owner", "Admin", "Cashier", "Vet", "Groomer")
/// - Automatic token validation and logout on invalid token
///
/// Usage:
/// ```dart
/// // Basic usage - will show business name and store name from database
/// const OurbitAppBar()
///
/// // With custom actions
/// const OurbitAppBar(
///   actions: [
///     IconButton(
///       onPressed: () {},
///       icon: Icon(Icons.settings),
///     ),
///   ],
/// )
///
/// // Without user info
/// const OurbitAppBar(
///   showUserInfo: false,
/// )
/// ```
///
/// **Data Sources:**
/// - Business Name: `business_data.name` → Default "Allnimall Pet Shop"
/// - Store Name: `store_data.name` → Default "Toko"
/// - User Name: `user_data.name` → `user_data.email` prefix → Default "User"
/// - User Role: `role_assignment_data.role.name` → Default "User"
class OurbitAppBar extends StatefulWidget {
  final List<Widget>? actions;
  final bool showUserInfo;

  const OurbitAppBar({
    super.key,
    this.actions,
    this.showUserInfo = true,
  });

  @override
  State<OurbitAppBar> createState() => _OurbitAppBarState();
}

class _OurbitAppBarState extends State<OurbitAppBar> {
  Timer? _tokenValidationTimer;

  @override
  void initState() {
    super.initState();
    // Start periodic token validation
    _startTokenValidation();
  }

  @override
  void dispose() {
    _tokenValidationTimer?.cancel();
    super.dispose();
  }

  void _startTokenValidation() {
    Logger.appbar('Starting token validation timer (5 minutes)');
    // Check token every 5 minutes for normal operation
    _tokenValidationTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      Logger.appbar('5-minute timer triggered - running token validation');
      _validateToken();
    });
  }

  Future<void> _validateToken() async {
    Logger.appbar('Starting token validation process');
    try {
      // First try to refresh session if needed
      Logger.appbar('Attempting to refresh session if needed');
      final refreshResult = await TokenService.refreshSessionIfNeeded();
      Logger.appbar('Refresh result: $refreshResult');

      // Then check if token is valid (now requires stored token)
      Logger.appbar('Checking if token is valid (stored token required)');
      final isValid = await TokenService.isTokenValid();
      Logger.appbar('Token validation result: $isValid');

      if (!isValid) {
        Logger.appbar('Token is invalid or missing stored token - triggering logout');
        // Token invalid or missing stored token, force logout
        await _handleInvalidToken();
      } else {
        Logger.appbar('Token is valid with stored token - continuing session');
      }
    } catch (e) {
      Logger.error('Error during token validation: $e');
      // Error during validation, assume token is invalid
      await _handleInvalidToken();
    }
  }

  Future<void> _handleInvalidToken() async {
    Logger.appbar('Handling invalid token - starting logout process');
    Logger.appbar('Reason: Missing stored token or invalid session');
    // Cancel timer to prevent multiple calls
    _tokenValidationTimer?.cancel();
    Logger.appbar('Token validation timer cancelled');

    // Force logout
    Logger.appbar('Calling TokenService.forceLogout()');
    await TokenService.forceLogout();

    // Navigate to login
    if (mounted) {
      Logger.appbar('Navigating to login page');
      context.go(AppRouter.loginRoute);
    }
  }

  String _getFirstName(String fullName) {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}';
    } else {
      return name.isNotEmpty ? name[0] : 'U';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBarBloc()..add(LoadAppBarData()),
      child: BlocBuilder<AppBarBloc, AppBarState>(
        builder: (context, state) {
          return Consumer<ThemeService>(
            builder: (context, themeService, _) {
              if (state is AppBarLoading) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeService.isDarkMode
                        ? AppColors.darkSurfaceBackground
                        : AppColors.surfaceBackground,
                    border: Border(
                      bottom: BorderSide(
                          color: themeService.isDarkMode
                              ? const Color(0xff292524)
                              : const Color(0xFFE5E7EB),
                          width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 200,
                              decoration: BoxDecoration(
                                color: themeService.isDarkMode
                                    ? AppColors.darkSecondaryBackground
                                    : AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Gap(4),
                            Container(
                              height: 14,
                              width: 150,
                              decoration: BoxDecoration(
                                color: themeService.isDarkMode
                                    ? AppColors.darkSecondaryBackground
                                    : AppColors.secondaryBackground,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is AppBarLoaded) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeService.isDarkMode
                        ? AppColors.darkSurfaceBackground
                        : AppColors.surfaceBackground,
                    border: Border(
                      bottom: BorderSide(
                          color: themeService.isDarkMode
                              ? const Color(0xff292524)
                              : const Color(0xFFE5E7EB),
                          width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Business Name
                            Text(
                              state.businessName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(4),
                            // Store Name
                            Text(
                              state.storeName,
                              style: TextStyle(
                                fontSize: 14,
                                color: themeService.isDarkMode
                                    ? AppColors.darkSecondaryText
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Custom actions
                      if (widget.actions != null) ...widget.actions!,
                      // Theme Toggle
                      const Gap(16),
                      const OurbitThemeToggle(
                        size: 36,
                        variant: OurbitThemeToggleVariant.ghost,
                      ),
                      // User info section
                      if (widget.showUserInfo) ...[
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: themeService.isDarkMode
                                ? AppColors.darkSecondaryBackground
                                : AppColors.secondaryBackground,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: AppColors.primary, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // User Name
                                  Text(
                                    _getFirstName(state.userName),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Gap(2),
                                  // User Role
                                  Text(
                                    state.userRole,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              // Avatar
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(state.userName),
                                    style: const TextStyle(
                                      color: AppColors.secondaryBackground,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              if (state is AppBarError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeService.isDarkMode
                        ? AppColors.darkSurfaceBackground
                        : AppColors.surfaceBackground,
                    border: Border(
                      bottom: BorderSide(
                          color: themeService.isDarkMode
                              ? const Color(0xff292524)
                              : const Color(0xFFE5E7EB),
                          width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Error loading data',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeService.isDarkMode
                                    ? AppColors.darkPrimaryText
                                    : AppColors.primaryText,
                              ),
                            ),
                            Text(
                              'Please refresh the page',
                              style: TextStyle(
                                color: themeService.isDarkMode
                                    ? AppColors.darkSecondaryText
                                    : AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.primary(
                        onPressed: () {
                          context.read<AppBarBloc>().add(RefreshAppBarData());
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                );
              }

              // Default state
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeService.isDarkMode
                      ? AppColors.darkSurfaceBackground
                      : AppColors.surfaceBackground,
                  border: Border(
                    bottom: BorderSide(
                        color: themeService.isDarkMode
                            ? const Color(0xff292524)
                            : const Color(0xFFE5E7EB),
                        width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeService.isDarkMode
                                  ? AppColors.darkPrimaryText
                                  : AppColors.primaryText,
                            ),
                          ),
                          Text(
                            'Please wait',
                            style: TextStyle(
                              color: themeService.isDarkMode
                                  ? AppColors.darkSecondaryText
                                  : AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
