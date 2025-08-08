import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitSkeleton extends StatelessWidget {
  final Widget child;

  const OurbitSkeleton({
    super.key,
    required this.child,
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
            borderRadius: BorderRadius.circular(8),
          ),
          child: this.child.asSkeleton(),
        );
      },
    );
  }
}

// Helper class untuk membuat skeleton dengan mudah
class OurbitSkeletonBuilder {
  static OurbitSkeleton basic({
    required Widget child,
  }) {
    return OurbitSkeleton(child: child);
  }

  static OurbitSkeleton text({
    required String text,
    TextStyle? style,
  }) {
    return OurbitSkeleton(
      child: Text(text, style: style),
    );
  }

  static OurbitSkeleton card({
    required Widget title,
    required Widget content,
    Widget? leading,
    Widget? trailing,
  }) {
    return OurbitSkeleton(
      child: Basic(
        title: title,
        content: content,
        leading: leading,
        trailing: trailing,
      ),
    );
  }

  static OurbitSkeleton avatar({
    required String initials,
    double size = 40,
  }) {
    return OurbitSkeleton(
      child: Avatar(
        initials: initials,
        size: size,
      ),
    );
  }

  static OurbitSkeleton button({
    required String text,
    ButtonStyle? style,
  }) {
    return OurbitSkeleton(
      child: PrimaryButton(
        child: Text(text),
        onPressed: () {},
      ),
    );
  }
}
