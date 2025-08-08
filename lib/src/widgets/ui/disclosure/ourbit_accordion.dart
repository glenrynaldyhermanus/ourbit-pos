import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

class OurbitAccordion extends StatelessWidget {
  final List<OurbitAccordionItem> items;

  const OurbitAccordion({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Accordion(
          items: items
              .map((item) => item.toAccordionItem(themeService.isDarkMode))
              .toList(),
        );
      },
    );
  }
}

class OurbitAccordionItem {
  final Widget trigger;
  final Widget content;

  const OurbitAccordionItem({
    required this.trigger,
    required this.content,
  });

  AccordionItem toAccordionItem(bool isDark) {
    return AccordionItem(
      trigger: OurbitAccordionTrigger(child: trigger),
      content: OurbitAccordionContent(child: content),
    );
  }
}

class OurbitAccordionTrigger extends StatelessWidget {
  final Widget child;

  const OurbitAccordionTrigger({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return AccordionTrigger(
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

class OurbitAccordionContent extends StatelessWidget {
  final Widget child;

  const OurbitAccordionContent({
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

// Helper class untuk membuat accordion dengan mudah
class OurbitAccordionBuilder {
  static OurbitAccordion fromItems({
    required List<OurbitAccordionItem> items,
  }) {
    return OurbitAccordion(items: items);
  }
}
