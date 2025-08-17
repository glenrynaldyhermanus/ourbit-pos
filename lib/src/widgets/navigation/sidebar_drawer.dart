import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/auth_event.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final bool isDark =
        Theme.of(context).brightness == material.Brightness.dark;

    return material.Drawer(
      backgroundColor: isDark ? AppColors.darkPrimaryBackground : Colors.white,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),

            // Navigation Items
            _buildNavItem(
              context,
              icon: LucideIcons.layoutDashboard,
              label: 'Kasir',
              route: '/pos',
              isSelected: currentLocation == '/pos',
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.package,
              label: 'Data',
              route: '/management',
              isSelected: currentLocation.startsWith('/management'),
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.building2,
              label: 'Organisasi',
              route: '/organization',
              isSelected: currentLocation.startsWith('/organization'),
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.fileText,
              label: 'Laporan',
              route: '/reports',
              isSelected: currentLocation.startsWith('/reports'),
              isDark: isDark,
            ),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
            _buildNavItem(
              context,
              icon: LucideIcons.settings,
              label: 'Pengaturan',
              route: '/settings',
              isSelected: currentLocation.startsWith('/settings'),
              isDark: isDark,
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.messageCircleQuestion,
              label: 'Bantuan',
              route: '/help',
              isSelected: currentLocation.startsWith('/help'),
              isDark: isDark,
            ),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),

            // Logout
            material.ListTile(
              leading: const Icon(
                LucideIcons.logOut,
                color: material.Colors.redAccent,
              ),
              title: const Text(
                'Keluar',
                style: TextStyle(
                  color: material.Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(SignOutRequested());
                // Pastikan redirect ke halaman login setelah logout
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isSelected,
    required bool isDark,
  }) {
    return material.ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppColors.primary
            : (isDark ? AppColors.darkPrimaryText : null),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkPrimaryText : null),
        ),
      ),
      tileColor: isSelected
          ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
          : null,
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
