import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/auth_event.dart';
import 'package:ourbit_pos/blocs/auth_state.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selected = 0;
  bool expanded = false;

  NavigationItem buildButton(String label, IconData icon, String route) {
    return NavigationItem(
      label: Text(label),
      alignment: Alignment.centerLeft,
      selectedStyle: const ButtonStyle.primaryIcon(),
      child: Icon(icon),
    );
  }

  NavigationLabel buildLabel(String label) {
    return NavigationLabel(
      alignment: Alignment.centerLeft,
      child: Text(label).semiBold().muted(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;

    // Update selected based on current route
    if (currentLocation == '/pos') {
      selected = 0;
    } else if (currentLocation.startsWith('/management')) {
      selected = 1;
    } else if (currentLocation.startsWith('/organization')) {
      selected = 2;
    } else if (currentLocation.startsWith('/reports')) {
      selected = 3;
    } else if (currentLocation.startsWith('/settings')) {
      selected = 4;
    } else if (currentLocation.startsWith('/help')) {
      selected = 5;
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Force refresh router and navigate to login
          // This ensures AppRouter redirect logic runs again
          context.pushReplacement('/login');
        }
      },
      child: OutlinedContainer(
        height: double.infinity,
        child: NavigationRail(
          backgroundColor: Theme.of(context).colorScheme.card,
          labelType: NavigationLabelType.expanded,
          labelPosition: NavigationLabelPosition.end,
          alignment: NavigationRailAlignment.start,
          expanded: expanded,
          index: selected,
          onSelected: (index) {
            setState(() {
              selected = index;
            });

            // Navigate based on selected index
            switch (index) {
              case 0:
                context.go('/pos');
                break;
              case 1:
                context.go('/management');
                break;
              case 2:
                context.go('/organization');
                break;
              case 3:
                context.go('/reports');
                break;
              case 4:
                context.go('/settings');
                break;
              case 5:
                context.go('/help');
                break;
              case 6:
                // Logout functionality
                Logger.debug('Sidebar - Logout button clicked');
                context.read<AuthBloc>().add(SignOutRequested());
                break;
            }
          },
          children: [
            // Toggle button untuk expand/collapse
            NavigationButton(
              alignment: Alignment.centerLeft,
              label: const Text('Menu'),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: const Icon(LucideIcons.menu),
            ),
            const NavigationGap(11),
            const NavigationDivider(),

            // POS - Point of Sale
            buildButton('POS', LucideIcons.layoutDashboard, '/pos'),

            // Management Data
            buildButton('Data', LucideIcons.package, '/management'),

            // Organisasi
            buildButton('Organisasi', LucideIcons.building2, '/organization'),

            // Laporan
            buildButton('Laporan', LucideIcons.fileText, '/reports'),

            const NavigationDivider(),

            // Pengaturan
            buildButton('Pengaturan', LucideIcons.settings, '/settings'),

            // Bantuan
            buildButton('Bantuan', LucideIcons.info, '/help'),

            const NavigationDivider(),

            // Logout
            const NavigationItem(
              label: Text('Logout'),
              alignment: Alignment.centerLeft,
              selectedStyle: ButtonStyle.destructiveIcon(),
              child: Icon(LucideIcons.logOut),
            ),
          ],
        ),
      ),
    );
  }
}
