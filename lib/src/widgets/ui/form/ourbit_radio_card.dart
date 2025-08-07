import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitRadioCard<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const OurbitRadioCard({
    super.key,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RadioCard<T>(
      value: value,
      child: child,
    );
  }
}

// Helper class untuk membuat radio card dengan mudah
class OurbitRadioCardBuilder {
  static OurbitRadioCard<int> basic({
    required int value,
    required Widget child,
  }) {
    return OurbitRadioCard<int>(
      value: value,
      child: child,
    );
  }

  static OurbitRadioCard<String> string({
    required String value,
    required Widget child,
  }) {
    return OurbitRadioCard<String>(
      value: value,
      child: child,
    );
  }

  static OurbitRadioCard<int> withContent({
    required int value,
    required String title,
    required String content,
  }) {
    return OurbitRadioCard<int>(
      value: value,
      child: Basic(
        title: Text(title),
        content: Text(content),
      ),
    );
  }

  static OurbitRadioCard<String> withStringContent({
    required String value,
    required String title,
    required String content,
  }) {
    return OurbitRadioCard<String>(
      value: value,
      child: Basic(
        title: Text(title),
        content: Text(content),
      ),
    );
  }
}
