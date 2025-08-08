import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitTabList extends StatelessWidget {
  final int index;
  final List<TabChild> children;
  final ValueChanged<int> onChanged;

  const OurbitTabList({
    super.key,
    required this.index,
    required this.children,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return TabList(
          index: index,
          children: children,
          onChanged: onChanged,
        );
      },
    );
  }
}

// Helper class untuk membuat tab list dengan mudah
class OurbitTabListBuilder {
  static OurbitTabList basic({
    required int index,
    required List<String> labels,
    required ValueChanged<int> onChanged,
  }) {
    return OurbitTabList(
      index: index,
      children: labels.map((label) => TabItem(child: Text(label))).toList(),
      onChanged: onChanged,
    );
  }

  static OurbitTabList withCustomItems({
    required int index,
    required List<TabItem> items,
    required ValueChanged<int> onChanged,
  }) {
    return OurbitTabList(
      index: index,
      children: items,
      onChanged: onChanged,
    );
  }
}
