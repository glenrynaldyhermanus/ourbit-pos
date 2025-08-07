import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import '../../../../src/core/theme/app_theme.dart';

class ManagementMenuWidget extends StatefulWidget {
  final List<ManagementMenuItem> menuItems;
  final String initialSelectedMenu;
  final Function(String) onMenuSelected;

  const ManagementMenuWidget({
    super.key,
    required this.menuItems,
    this.initialSelectedMenu = 'products',
    required this.onMenuSelected,
  });

  @override
  State<ManagementMenuWidget> createState() => _ManagementMenuWidgetState();
}

class _ManagementMenuWidgetState extends State<ManagementMenuWidget> {
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
    return Container(
      width: MediaQuery.of(context).size.width < 1200 ? 250 : 300,
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Pengelolaan Data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: widget.menuItems.length,
              itemBuilder: (context, index) {
                final item = widget.menuItems[index];
                final isSelected = _selectedMenu == item.id;

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
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.secondaryText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
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
  }
}

class ManagementMenuItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const ManagementMenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
