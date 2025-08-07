import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitDivider extends StatelessWidget {
  final Widget? child;
  final bool isVertical;

  const OurbitDivider({
    super.key,
    this.child,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return VerticalDivider(child: child);
    }
    return Divider(child: child);
  }
}

// Helper class untuk membuat divider dengan mudah
class OurbitDividerBuilder {
  static OurbitDivider horizontal({
    Widget? child,
  }) {
    return OurbitDivider(
      child: child,
      isVertical: false,
    );
  }

  static OurbitDivider vertical({
    Widget? child,
  }) {
    return OurbitDivider(
      child: child,
      isVertical: true,
    );
  }

  static OurbitDivider withText({
    required String text,
    bool isVertical = false,
  }) {
    return OurbitDivider(
      child: Text(text),
      isVertical: isVertical,
    );
  }

  static OurbitDivider simple({
    bool isVertical = false,
  }) {
    return OurbitDivider(isVertical: isVertical);
  }
}
