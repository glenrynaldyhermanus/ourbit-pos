import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitBreadcrumb extends StatelessWidget {
  final List<Widget> children;
  final Widget? separator;

  const OurbitBreadcrumb({
    super.key,
    required this.children,
    this.separator,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Breadcrumb(
          separator: separator ?? Breadcrumb.arrowSeparator,
          children: children,
        );
      },
    );
  }
}

// Helper class untuk membuat breadcrumb dengan mudah
class OurbitBreadcrumbBuilder {
  static OurbitBreadcrumb basic({
    required List<Widget> children,
    Widget? separator,
  }) {
    return OurbitBreadcrumb(
      separator: separator,
      children: children,
    );
  }

  static OurbitBreadcrumb withTextButtons({
    required List<String> items,
    required List<VoidCallback> onPressed,
    Widget? separator,
  }) {
    final children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i < items.length - 1) {
        children.add(
          TextButton(
            onPressed: onPressed[i],
            density: ButtonDensity.compact,
            child: Text(items[i]),
          ),
        );
      } else {
        children.add(Text(items[i]));
      }
    }

    return OurbitBreadcrumb(
      separator: separator,
      children: children,
    );
  }

  static OurbitBreadcrumb withMoreDots({
    required List<Widget> children,
    Widget? separator,
  }) {
    final items = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(const MoreDots());
      }
      items.add(children[i]);
    }

    return OurbitBreadcrumb(
      separator: separator,
      children: items,
    );
  }
}
