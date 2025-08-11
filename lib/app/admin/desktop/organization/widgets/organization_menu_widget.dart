import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OrganizationMenuWidget extends StatefulWidget {
  final List<OrganizationMenuItem> menuItems;
  final String initialSelectedMenu;
  final Function(String) onMenuSelected;

  const OrganizationMenuWidget({
    super.key,
    required this.menuItems,
    this.initialSelectedMenu = 'stores',
    required this.onMenuSelected,
  });

  @override
  State<OrganizationMenuWidget> createState() => _OrganizationMenuWidgetState();
}

class _OrganizationMenuWidgetState extends State<OrganizationMenuWidget> {
  late String _selectedMenu;

  @override
  void initState() {
    super.initState();
    _selectedMenu = widget.initialSelectedMenu;
  }

  void _onMenuSelected(String menuId) {
    setState(() {
      _selectedMenu = menuId;
    });
    widget.onMenuSelected(menuId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final bool isDark = themeService.isDarkMode;
        return Container(
          width: MediaQuery.of(context).size.width < 1200 ? 250 : 300,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSecondaryBackground
                : AppColors.secondaryBackground,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Pengelolaan Organisasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: widget.menuItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.menuItems[index];
                    final isSelected = _selectedMenu == item.id;

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

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: material.Material(
                        color: Colors.transparent,
                        child: material.InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            _onMenuSelected(item.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: iconColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrganizationMenuItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const OrganizationMenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
