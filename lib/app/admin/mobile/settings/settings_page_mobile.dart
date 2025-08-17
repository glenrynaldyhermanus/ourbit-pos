import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/profile/profile_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/store/store_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/notifications/notifications_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/system/system_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/printer/printer_content_mobile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SettingsPageMobile extends StatelessWidget {
  const SettingsPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const List<material.Tab> tabs = [
      material.Tab(text: 'Profil'),
      material.Tab(text: 'Toko'),
      material.Tab(text: 'Notifikasi'),
      material.Tab(text: 'Sistem'),
      material.Tab(text: 'Printer'),
    ];

    return material.DefaultTabController(
      length: tabs.length,
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          final bool isDark = themeService.isDarkMode;
          return material.Scaffold(
            backgroundColor: isDark
                ? AppColors.darkSurfaceBackground
                : AppColors.surfaceBackground,
            appBar: material.AppBar(
              backgroundColor: isDark
                  ? AppColors.darkSurfaceBackground
                  : AppColors.surfaceBackground,
              foregroundColor:
                  isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
              title: const Text('Pengaturan'),
              leading: material.Builder(
                builder: (context) => material.IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => material.Scaffold.of(context).openDrawer(),
                ),
              ),
              bottom: material.TabBar(
                isScrollable: true,
                indicator: material.UnderlineTabIndicator(
                  borderSide: material.BorderSide(
                    width: 2,
                    color: colorScheme.primary,
                  ),
                ),
                labelColor: colorScheme.primary,
                unselectedLabelColor: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.secondaryText,
                dividerColor: isDark ? AppColors.darkBorder : AppColors.border,
                tabs: tabs,
              ),
            ),
            drawer: const SidebarDrawer(),
            body: Container(
              color: isDark
                  ? AppColors.darkPrimaryBackground
                  : AppColors.primaryBackground,
              child: const material.TabBarView(
                children: [
                  ProfileContentMobile(),
                  StoreContentMobile(),
                  NotificationsContentMobile(),
                  SystemContentMobile(),
                  PrinterContentMobile(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
