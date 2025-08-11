import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/auth_event.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

class SidebarDrawer extends material.StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    return material.Drawer(
      child: material.SafeArea(
        child: material.ListView(
          padding: const material.EdgeInsets.symmetric(vertical: 8),
          children: [
            // Header
            material.Container(
              padding: const material.EdgeInsets.all(16),
              child: material.Text(
                'Menu',
                style: material.TextStyle(
                  fontSize: 18,
                  fontWeight: material.FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const material.Divider(),
            
            // Navigation Items
            _buildNavItem(
              context,
              icon: material.Icons.point_of_sale,
              label: 'POS',
              route: '/pos',
              isSelected: currentLocation == '/pos',
            ),
            _buildNavItem(
              context,
              icon: material.Icons.inventory_2_outlined,
              label: 'Data',
              route: '/management',
              isSelected: currentLocation.startsWith('/management'),
            ),
            _buildNavItem(
              context,
              icon: material.Icons.apartment_outlined,
              label: 'Organisasi',
              route: '/organization',
              isSelected: currentLocation.startsWith('/organization'),
            ),
            _buildNavItem(
              context,
              icon: material.Icons.insert_chart_outlined,
              label: 'Laporan',
              route: '/reports',
              isSelected: currentLocation.startsWith('/reports'),
            ),
            const material.Divider(),
            _buildNavItem(
              context,
              icon: material.Icons.settings_outlined,
              label: 'Pengaturan',
              route: '/settings',
              isSelected: currentLocation.startsWith('/settings'),
            ),
            _buildNavItem(
              context,
              icon: material.Icons.help_outline,
              label: 'Bantuan',
              route: '/help',
              isSelected: currentLocation.startsWith('/help'),
            ),
            const material.Divider(),
            
            // Logout
            material.ListTile(
              leading: const material.Icon(
                material.Icons.logout,
                color: material.Colors.redAccent,
              ),
              title: const material.Text(
                'Logout',
                style: material.TextStyle(
                  color: material.Colors.redAccent,
                  fontWeight: material.FontWeight.w500,
                ),
              ),
              onTap: () {
                material.Navigator.of(context).pop();
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  material.Widget _buildNavItem(
    material.BuildContext context, {
    required material.IconData icon,
    required String label,
    required String route,
    required bool isSelected,
  }) {
    return material.ListTile(
      leading: material.Icon(
        icon,
        color: isSelected ? AppColors.primary : null,
      ),
      title: material.Text(
        label,
        style: material.TextStyle(
          fontWeight: isSelected ? material.FontWeight.w600 : material.FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      onTap: () {
        material.Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
