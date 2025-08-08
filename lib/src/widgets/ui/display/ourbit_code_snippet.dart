import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitCodeSnippet extends StatelessWidget {
  final String code;
  final String mode;

  const OurbitCodeSnippet({
    super.key,
    required this.code,
    this.mode = 'text',
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
          child: CodeSnippet(
            code: code,
            mode: mode,
          ),
        );
      },
    );
  }
}

// Helper class untuk membuat code snippet dengan mudah
class OurbitCodeSnippetBuilder {
  static OurbitCodeSnippet shell({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'shell',
    );
  }

  static OurbitCodeSnippet dart({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'dart',
    );
  }

  static OurbitCodeSnippet json({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'json',
    );
  }

  static OurbitCodeSnippet sql({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'sql',
    );
  }

  static OurbitCodeSnippet custom({
    required String code,
    required String mode,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: mode,
    );
  }
}
