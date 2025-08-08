import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

class OurbitCollapsible extends StatelessWidget {
  final List<Widget> children;

  const OurbitCollapsible({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Collapsible(
          children: children.map((widget) {
            if (widget is OurbitCollapsibleTrigger) {
              return OurbitCollapsibleTrigger(child: widget.child);
            } else if (widget is OurbitCollapsibleContent) {
              return OurbitCollapsibleContent(child: widget.child);
            }
            return widget;
          }).toList(),
        );
      },
    );
  }
}

class OurbitCollapsibleTrigger extends StatelessWidget {
  final Widget child;

  const OurbitCollapsibleTrigger({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return CollapsibleTrigger(
          child: Container(
            decoration: BoxDecoration(
              color: themeService.isDarkMode
                  ? AppColors.darkTertiary
                  : AppColors.muted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeService.isDarkMode
                    ? AppColors.darkBorder
                    : AppColors.border,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: child),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: themeService.isDarkMode
                      ? AppColors.darkSecondaryText
                      : AppColors.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OurbitCollapsibleContent extends StatelessWidget {
  final Widget child;

  const OurbitCollapsibleContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.isDarkMode
                ? AppColors.darkSecondaryBackground
                : AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeService.isDarkMode
                  ? AppColors.darkBorder
                  : AppColors.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        );
      },
    );
  }
}

// Helper class untuk membuat collapsible dengan mudah
class OurbitCollapsibleBuilder {
  static OurbitCollapsible simple({
    required Widget trigger,
    required Widget content,
  }) {
    return OurbitCollapsible(
      children: [
        OurbitCollapsibleTrigger(child: trigger),
        OurbitCollapsibleContent(child: content),
      ],
    );
  }

  static OurbitCollapsible list({
    required Widget trigger,
    required List<Widget> contentItems,
  }) {
    return OurbitCollapsible(
      children: [
        OurbitCollapsibleTrigger(child: trigger),
        ...contentItems.map((item) => OurbitCollapsibleContent(child: item)),
      ],
    );
  }
}
