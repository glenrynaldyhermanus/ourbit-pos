import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final List<Widget> actions;
  final bool barrierDismissible;
  final Color? barrierColor;

  const OurbitAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.barrierDismissible = true,
    this.barrierColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return AlertDialog(
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
          actions: actions,
        );
      },
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => OurbitAlertDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      ),
    );
  }
}

// Helper class untuk membuat alert dialog dengan mudah
class OurbitAlertDialogBuilder {
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'OK',
    String cancelText = 'Batal',
    bool barrierDismissible = true,
  }) {
    return OurbitAlertDialog.show<bool>(
      context: context,
      title: Text(title),
      content: Text(content),
      actions: [
        OutlineButton(
          child: Text(cancelText),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        PrimaryButton(
          child: Text(confirmText),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<void> info({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    bool barrierDismissible = true,
  }) {
    return OurbitAlertDialog.show(
      context: context,
      title: Text(title),
      content: Text(content),
      actions: [
        PrimaryButton(
          child: Text(buttonText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<T?> custom<T>({
    required BuildContext context,
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    bool barrierDismissible = true,
  }) {
    return OurbitAlertDialog.show<T>(
      context: context,
      title: title,
      content: content,
      actions: actions,
      barrierDismissible: barrierDismissible,
    );
  }
}
