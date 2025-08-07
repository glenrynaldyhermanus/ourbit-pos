import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitAccordion extends StatelessWidget {
  final List<OurbitAccordionItem> items;

  const OurbitAccordion({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Accordion(
      items: items.map((item) => item.toAccordionItem()).toList(),
    );
  }
}

class OurbitAccordionItem {
  final Widget trigger;
  final Widget content;

  const OurbitAccordionItem({
    required this.trigger,
    required this.content,
  });

  AccordionItem toAccordionItem() {
    return AccordionItem(
      trigger: OurbitAccordionTrigger(child: trigger),
      content: OurbitAccordionContent(child: content),
    );
  }
}

class OurbitAccordionTrigger extends StatelessWidget {
  final Widget child;

  const OurbitAccordionTrigger({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AccordionTrigger(
      child: child,
    );
  }
}

class OurbitAccordionContent extends StatelessWidget {
  final Widget child;

  const OurbitAccordionContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child.withPadding(top: 16);
  }
}

// Helper class untuk membuat accordion dengan mudah
class OurbitAccordionBuilder {
  static OurbitAccordion fromItems({
    required List<OurbitAccordionItem> items,
  }) {
    return OurbitAccordion(items: items);
  }
}
