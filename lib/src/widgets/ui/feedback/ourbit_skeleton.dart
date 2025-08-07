import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitSkeleton extends StatelessWidget {
  final Widget child;

  const OurbitSkeleton({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child.asSkeleton();
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
