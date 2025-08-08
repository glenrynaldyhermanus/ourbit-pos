import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitAlert extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Widget? leading;
  final Widget? trailing;

  const OurbitAlert({
    super.key,
    required this.title,
    required this.content,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
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
          child: Alert(
            title: DefaultTextStyle(
              style: TextStyle(
                color: themeService.isDarkMode 
                    ? AppColors.darkPrimaryText 
                    : AppColors.primaryText,
              ),
              child: title,
            ),
            content: DefaultTextStyle(
              style: TextStyle(
                color: themeService.isDarkMode 
                    ? AppColors.darkSecondaryText 
                    : AppColors.secondaryText,
              ),
              child: content,
            ),
            leading: leading,
            trailing: trailing,
          ),
        );
      },
    );
  }
}

// Helper class untuk membuat alert dengan mudah
class OurbitAlertBuilder {
  static OurbitAlert info({
    required String title,
    required String content,
    IconData? icon,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: icon != null ? Icon(icon) : const Icon(Icons.info_outline),
      trailing: trailing,
    );
  }

  static OurbitAlert success({
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: const Icon(Icons.check_circle_outline),
      trailing: trailing,
    );
  }

  static OurbitAlert warning({
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: const Icon(Icons.warning_amber_outlined),
      trailing: trailing,
    );
  }

  static OurbitAlert error({
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: const Icon(Icons.error_outline),
      trailing: trailing,
    );
  }

  static OurbitAlert custom({
    required Widget title,
    required Widget content,
    Widget? leading,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: title,
      content: content,
      leading: leading,
      trailing: trailing,
    );
  }
}
