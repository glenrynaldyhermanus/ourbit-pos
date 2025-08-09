import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool intrinsic;

  const OurbitCard({
    super.key,
    required this.child,
    this.padding,
    this.intrinsic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        Widget card = Card(
          padding: padding,
          child: child,
        );

        if (intrinsic) {
          card = card.intrinsic();
        }

        return card;
      },
    );
  }
}

// Helper class untuk membuat card dengan mudah
class OurbitCardBuilder {
  static OurbitCard basic({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return OurbitCard(
      padding: padding,
      child: child,
    );
  }

  static OurbitCard withPadding({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    return OurbitCard(
      padding: padding,
      child: child,
    );
  }

  static OurbitCard intrinsic({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return OurbitCard(
      padding: padding,
      intrinsic: true,
      child: child,
    );
  }

  static OurbitCard form({
    required String title,
    required String subtitle,
    required List<Widget> formFields,
    required List<Widget> actions,
  }) {
    return OurbitCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title).semiBold(),
          const SizedBox(height: 4),
          Text(subtitle).muted().small(),
          const SizedBox(height: 24),
          ...formFields,
          const SizedBox(height: 24),
          Row(
            children: [
              ...actions.take(actions.length - 1),
              const Spacer(),
              actions.last,
            ],
          ),
        ],
      ),
    );
  }
}
