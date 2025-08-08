import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitAvatar extends StatelessWidget {
  final String? initials;
  final ImageProvider? provider;
  final Color? backgroundColor;
  final double size;
  final AvatarBadge? badge;

  const OurbitAvatar({
    super.key,
    this.initials,
    this.provider,
    this.backgroundColor,
    this.size = 40,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final defaultBackgroundColor = themeService.isDarkMode 
            ? AppColors.darkTertiary 
            : AppColors.muted;
            
        return Avatar(
          initials: initials != null ? Avatar.getInitials(initials!) : '',
          provider: provider,
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          size: size,
          badge: badge,
        );
      },
    );
  }
}

class OurbitAvatarBadge extends StatelessWidget {
  final double size;
  final Color color;
  final Widget? child;

  const OurbitAvatarBadge({
    super.key,
    this.size = 20,
    required this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final badgeColor = themeService.isDarkMode 
            ? AppColors.darkPrimary 
            : AppColors.primary;
            
        return AvatarBadge(
          size: size,
          color: color != AppColors.primary ? color : badgeColor,
          child: child,
        );
      },
    );
  }
}

// Helper class untuk membuat avatar dengan mudah
class OurbitAvatarBuilder {
  static OurbitAvatar user({
    required String name,
    String? imageUrl,
    double size = 40,
    Color? backgroundColor,
    AvatarBadge? badge,
  }) {
    return OurbitAvatar(
      initials: name,
      provider: imageUrl != null ? NetworkImage(imageUrl) : null,
      backgroundColor: backgroundColor,
      size: size,
      badge: badge,
    );
  }

  static OurbitAvatar withImage({
    required ImageProvider provider,
    double size = 40,
    AvatarBadge? badge,
  }) {
    return OurbitAvatar(
      provider: provider,
      size: size,
      badge: badge,
    );
  }

  static OurbitAvatar withInitials({
    required String initials,
    double size = 40,
    Color? backgroundColor,
    AvatarBadge? badge,
  }) {
    return OurbitAvatar(
      initials: initials,
      backgroundColor: backgroundColor,
      size: size,
      badge: badge,
    );
  }
}
