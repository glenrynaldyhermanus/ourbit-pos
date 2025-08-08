import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

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
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        if (isVertical) {
          return VerticalDivider(child: child);
        }
        return Divider(child: child);
      },
    );
  }
}

// Helper class untuk membuat divider dengan mudah
class OurbitDividerBuilder {
  static OurbitDivider horizontal({
    Widget? child,
  }) {
    return OurbitDivider(
      isVertical: false,
      child: child,
    );
  }

  static OurbitDivider vertical({
    Widget? child,
  }) {
    return OurbitDivider(
      isVertical: true,
      child: child,
    );
  }

  static OurbitDivider withText({
    required String text,
    bool isVertical = false,
  }) {
    return OurbitDivider(
      isVertical: isVertical,
      child: Text(text),
    );
  }

  static OurbitDivider simple({
    bool isVertical = false,
  }) {
    return OurbitDivider(isVertical: isVertical);
  }
}
