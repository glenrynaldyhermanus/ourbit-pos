import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitCollapsible extends StatelessWidget {
  final List<Widget> children;

  const OurbitCollapsible({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Collapsible(
      children: children,
    );
  }
}

class OurbitCollapsibleTrigger extends StatelessWidget {
  final Widget child;

  const OurbitCollapsibleTrigger({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CollapsibleTrigger(
      child: child,
    );
  }
}

class OurbitCollapsibleContent extends StatelessWidget {
  final Widget child;

  const OurbitCollapsibleContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CollapsibleContent(
      child: child,
    );
  }
}

// Helper class untuk membuat collapsible dengan mudah
class OurbitCollapsibleBuilder {
  static OurbitCollapsible simple({
    required Widget trigger,
    required Widget content,
  }) {
    return OurbitCollapsible(
      children: [
        OurbitCollapsibleTrigger(child: trigger),
        OurbitCollapsibleContent(child: content),
      ],
    );
  }

  static OurbitCollapsible list({
    required Widget trigger,
    required List<Widget> contentItems,
  }) {
    return OurbitCollapsible(
      children: [
        OurbitCollapsibleTrigger(child: trigger),
        ...contentItems.map((item) => OurbitCollapsibleContent(child: item)),
      ],
    );
  }
}
