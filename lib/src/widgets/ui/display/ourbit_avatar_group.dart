import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitAvatarGroup extends StatelessWidget {
  final List<Avatar> children;
  final double spacing;
  final int? maxAvatars;
  final Alignment alignment;

  const OurbitAvatarGroup({
    super.key,
    required this.children,
    this.spacing = 16,
    this.maxAvatars,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final avatars = maxAvatars != null && children.length > maxAvatars!
            ? children.take(maxAvatars!).toList()
            : children;

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
          padding: const EdgeInsets.all(12),
          child: AvatarGroup(
            alignment: alignment,
            children: avatars,
          ),
        );
      },
    );
  }
}

// Helper class untuk membuat avatar group dengan mudah
class OurbitAvatarGroupBuilder {
  static OurbitAvatarGroup toLeft({
    required List<Avatar> children,
    double spacing = 16,
    int? maxAvatars,
  }) {
    return OurbitAvatarGroup(
      spacing: spacing,
      maxAvatars: maxAvatars,
      alignment: Alignment.centerLeft,
      children: children,
    );
  }

  static OurbitAvatarGroup toRight({
    required List<Avatar> children,
    double spacing = 16,
    int? maxAvatars,
  }) {
    return OurbitAvatarGroup(
      spacing: spacing,
      maxAvatars: maxAvatars,
      alignment: Alignment.centerRight,
      children: children,
    );
  }

  static OurbitAvatarGroup toTop({
    required List<Avatar> children,
    double spacing = 16,
    int? maxAvatars,
  }) {
    return OurbitAvatarGroup(
      spacing: spacing,
      maxAvatars: maxAvatars,
      alignment: Alignment.topCenter,
      children: children,
    );
  }

  static OurbitAvatarGroup toBottom({
    required List<Avatar> children,
    double spacing = 16,
    int? maxAvatars,
  }) {
    return OurbitAvatarGroup(
      spacing: spacing,
      maxAvatars: maxAvatars,
      alignment: Alignment.bottomCenter,
      children: children,
    );
  }
}
