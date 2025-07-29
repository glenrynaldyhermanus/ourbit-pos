import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocation = GoRouterState.of(context).uri.path;

    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkPrimaryBackground
            : AppColors.primaryBackground,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  // POS
                  _buildMenuItem(
                    context,
                    icon: Icons.dashboard,
                    route: '/pos',
                    isActive: currentLocation == '/pos',
                    tooltip: 'Point of Sale',
                  ),
                  const SizedBox(height: 4),

                  // Management Data
                  _buildMenuItem(
                    context,
                    icon: Icons.inventory_2,
                    route: '/management',
                    isActive: currentLocation.startsWith('/management'),
                    tooltip: 'Management Data',
                  ),
                  const SizedBox(height: 4),

                  // Organisasi
                  _buildMenuItem(
                    context,
                    icon: Icons.business,
                    route: '/organization',
                    isActive: currentLocation.startsWith('/organization'),
                    tooltip: 'Organisasi',
                  ),
                  const SizedBox(height: 4),

                  // Laporan
                  _buildMenuItem(
                    context,
                    icon: Icons.analytics,
                    route: '/reports',
                    isActive: currentLocation.startsWith('/reports'),
                    tooltip: 'Laporan',
                  ),
                  const SizedBox(height: 4),

                  // Pengaturan
                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    route: '/settings',
                    isActive: currentLocation.startsWith('/settings'),
                    tooltip: 'Pengaturan',
                  ),
                  const SizedBox(height: 4),

                  // Bantuan
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    route: '/help',
                    isActive: currentLocation.startsWith('/help'),
                    tooltip: 'Bantuan',
                  ),
                ],
              ),
            ),
          ),

          // Logout
          Container(
            padding: const EdgeInsets.all(8),
            child: _buildMenuItem(
              context,
              icon: Icons.logout,
              route: '/login',
              isActive: false,
              tooltip: 'Logout',
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String route,
    required bool isActive,
    required String tooltip,
    bool isLogout = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: () => context.go(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : isLogout
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: 24,
            color: isActive
                ? AppColors.primary
                : isLogout
                    ? Colors.red
                    : isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
