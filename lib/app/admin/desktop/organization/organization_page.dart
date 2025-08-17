import 'package:ourbit_pos/app/admin/desktop/organization/staffs/staffs_content.dart';
import 'package:ourbit_pos/app/admin/desktop/organization/stores/stores_content.dart';
import 'package:ourbit_pos/app/admin/desktop/organization/widgets/organization_menu_widget.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/navigation/appbar.dart';
import 'package:ourbit_pos/src/widgets/navigation/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({super.key});

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  String _selectedMenu = 'stores';

  final List<OrganizationMenuItem> _menuItems = const [
    OrganizationMenuItem(
      id: 'stores',
      title: 'Toko & Cabang',
      description: 'Kelola toko dan cabang',
      icon: Icons.store_outlined,
    ),
    OrganizationMenuItem(
      id: 'staffs',
      title: 'Staff',
      description: 'Kelola data karyawan',
      icon: Icons.badge_outlined,
    ),
    // Online store moved to web-only settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const OurbitAppBar(),
                Expanded(
                  child: Consumer<ThemeService>(
                    builder: (context, themeService, _) {
                      final bool isDark = themeService.isDarkMode;
                      return Row(
                        children: [
                          Container(
                            width: 300,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: isDark
                                      ? const Color(0xff292524)
                                      : const Color(0xFFE5E7EB),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: OrganizationMenuWidget(
                              menuItems: _menuItems,
                              initialSelectedMenu: _selectedMenu,
                              onMenuSelected: (menuId) {
                                setState(() {
                                  _selectedMenu = menuId;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: _buildContent(_selectedMenu),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'stores':
        return const StoresContent();
      case 'staffs':
        return const StaffsContent();
      // onlinestores removed (web-only)
      default:
        return const SizedBox.shrink();
    }
  }
}
