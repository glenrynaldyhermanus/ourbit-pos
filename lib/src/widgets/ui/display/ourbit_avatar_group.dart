import 'package:shadcn_flutter/shadcn_flutter.dart';

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
    final avatars = maxAvatars != null && children.length > maxAvatars!
        ? children.take(maxAvatars!).toList()
        : children;

    return AvatarGroup(
      alignment: alignment,
      children: avatars,
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
