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

    return material.Drawer(
      backgroundColor: Colors.white,
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
            const Divider(),

            // Navigation Items
            _buildNavItem(
              context,
              icon: LucideIcons.layoutDashboard,
              label: 'Kasir',
              route: '/pos',
              isSelected: currentLocation == '/pos',
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.package,
              label: 'Data',
              route: '/management',
              isSelected: currentLocation.startsWith('/management'),
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.building2,
              label: 'Organisasi',
              route: '/organization',
              isSelected: currentLocation.startsWith('/organization'),
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.fileText,
              label: 'Laporan',
              route: '/reports',
              isSelected: currentLocation.startsWith('/reports'),
            ),
            const Divider(),
            _buildNavItem(
              context,
              icon: LucideIcons.settings,
              label: 'Pengaturan',
              route: '/settings',
              isSelected: currentLocation.startsWith('/settings'),
            ),
            _buildNavItem(
              context,
              icon: LucideIcons.messageCircleQuestion,
              label: 'Bantuan',
              route: '/help',
              isSelected: currentLocation.startsWith('/help'),
            ),
            const Divider(),

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
  }) {
    return material.ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
