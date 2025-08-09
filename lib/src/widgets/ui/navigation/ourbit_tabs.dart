import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitTabs extends StatelessWidget {
  final int index;
  final List<TabChild> children;
  final ValueChanged<int> onChanged;

  const OurbitTabs({
    super.key,
    required this.index,
    required this.children,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Tabs(
          index: index,
          onChanged: onChanged,
          children: children,
        );
      },
    );
  }
}

class OurbitTabItem extends StatelessWidget {
  final Widget child;

  const OurbitTabItem({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return TabItem(child: child);
      },
    );
  }
}

// Helper class untuk membuat tabs dengan mudah
class OurbitTabsBuilder {
  static OurbitTabs basic({
    required int index,
    required List<String> labels,
    required ValueChanged<int> onChanged,
  }) {
    return OurbitTabs(
      index: index,
      onChanged: onChanged,
      children: labels.map((label) => TabItem(child: Text(label))).toList(),
    );
  }

  static OurbitTabs withCustomItems({
    required int index,
    required List<TabItem> items,
    required ValueChanged<int> onChanged,
  }) {
    return OurbitTabs(
      index: index,
      onChanged: onChanged,
      children: items,
    );
  }

  static TabItem item({
    required String label,
  }) {
    return TabItem(child: Text(label));
  }

  static TabItem custom({
    required Widget child,
  }) {
    return TabItem(child: child);
  }
}
