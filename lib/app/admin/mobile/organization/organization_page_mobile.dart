import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/app/admin/mobile/organization/stores/stores_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/organization/staffs/staffs_content_mobile.dart';

class OrganizationPageMobile extends material.StatelessWidget {
  const OrganizationPageMobile({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    final theme = material.Theme.of(context);
    final colorScheme = theme.colorScheme;
    const List<material.Tab> tabs = [
      material.Tab(text: 'Toko'),
      material.Tab(text: 'Staff'),
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
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: material.Colors.transparent,
              shadowColor: material.Colors.transparent,
              title: const material.Text('Organisasi'),
              leading: material.Builder(
                builder: (context) => material.IconButton(
                  icon: const material.Icon(material.Icons.menu),
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
                labelStyle: material.Theme.of(context).textTheme.titleMedium,
                unselectedLabelStyle:
                    material.Theme.of(context).textTheme.titleMedium,
                tabs: tabs,
              ),
            ),
            drawer: const SidebarDrawer(),
            body: material.Container(
              color: isDark
                  ? AppColors.darkPrimaryBackground
                  : AppColors.primaryBackground,
              child: const material.TabBarView(
                children: [
                  StoresContentMobile(),
                  StaffsContentMobile(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
