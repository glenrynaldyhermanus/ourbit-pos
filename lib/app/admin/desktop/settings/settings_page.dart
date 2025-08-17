import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/navigation/sidebar.dart';
import 'package:ourbit_pos/src/widgets/navigation/appbar.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
// import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';

import 'printer/printer_content.dart';
import 'profile/profile_content.dart';
import 'store/store_content.dart';
import 'notifications/notifications_content.dart';
import 'system/system_content.dart';

class SettingsPage extends StatefulWidget {
  final String? selectedMenu;

  const SettingsPage({super.key, this.selectedMenu});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedMenu = 'profile';

  final List<_SettingsMenuItem> _menuItems = const [
    _SettingsMenuItem(
      id: 'profile',
      title: 'Profil',
      description: 'Pengaturan akun dan informasi pengguna',
      icon: Icons.person,
    ),
    _SettingsMenuItem(
      id: 'store',
      title: 'Toko',
      description: 'Informasi dan pengaturan toko',
      icon: Icons.store,
    ),
    _SettingsMenuItem(
      id: 'notifications',
      title: 'Notifikasi',
      description: 'Preferensi notifikasi sistem',
      icon: Icons.notifications,
    ),
    _SettingsMenuItem(
      id: 'system',
      title: 'Sistem',
      description: 'Tema, bahasa, dan pengaturan sistem',
      icon: Icons.settings,
    ),
    _SettingsMenuItem(
      id: 'printer',
      title: 'Printer',
      description: 'Koneksi dan pengaturan printer',
      icon: Icons.print,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedMenu != null) {
      _selectedMenu = widget.selectedMenu!;
    }
  }

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
                  child: Row(
                    children: [
                      Consumer<ThemeService>(
                        builder: (context, themeService, _) {
                          final bool isDark = themeService.isDarkMode;
                          return Container(
                            width: MediaQuery.of(context).size.width < 1200
                                ? 250
                                : 300,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    'Pengaturan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFE7E5E4)
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _menuItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _menuItems[index];
                                      final bool isSelected =
                                          _selectedMenu == item.id;
                                      final Color iconColor = isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText);
                                      final Color titleColor = isSelected
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.darkPrimaryText
                                              : AppColors.primaryText);
                                      final Color descColor = isDark
                                          ? AppColors.darkSecondaryText
                                          : AppColors.secondaryText;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: material.InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () {
                                            setState(() {
                                              _selectedMenu = item.id;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                      .withValues(alpha: 0.1)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: isSelected
                                                  ? Border.all(
                                                      color: AppColors.primary
                                                          .withValues(
                                                              alpha: 0.3),
                                                      width: 1,
                                                    )
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(item.icon,
                                                    size: 20, color: iconColor),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.title,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: titleColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        item.description,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: descColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: _buildContent(_selectedMenu),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'store':
        return const StoreContent();
      case 'notifications':
        return const NotificationsContent();
      case 'system':
        return const SystemContent();
      case 'printer':
        return const PrinterContent();
      case 'profile':
      default:
        return const ProfileContent();
    }
  }
}

class _SettingsMenuItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const _SettingsMenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
