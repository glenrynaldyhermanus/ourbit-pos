import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitRadioGroup<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T>? onChanged;
  final Widget child;

  const OurbitRadioGroup({
    super.key,
    this.value,
    this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      value: value,
      onChanged: onChanged,
      child: child,
    );
  }
}

class OurbitRadioItem<T> extends StatelessWidget {
  final T value;
  final Widget trailing;

  const OurbitRadioItem({
    super.key,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return RadioItem<T>(
      value: value,
      trailing: trailing,
    );
  }
}

// Helper class untuk membuat radio group dengan mudah
class OurbitRadioGroupBuilder {
  static OurbitRadioGroup<int> basic({
    int? value,
    ValueChanged<int>? onChanged,
    required List<OurbitRadioItem<int>> items,
  }) {
    return OurbitRadioGroup<int>(
      value: value,
      onChanged: onChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  static OurbitRadioGroup<String> string({
    String? value,
    ValueChanged<String>? onChanged,
    required List<OurbitRadioItem<String>> items,
  }) {
    return OurbitRadioGroup<String>(
      value: value,
      onChanged: onChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items,
      ),
    );
  }

  static OurbitRadioItem<int> item({
    required int value,
    required String label,
  }) {
    return OurbitRadioItem<int>(
      value: value,
      trailing: Text(label),
    );
  }

  static OurbitRadioItem<String> stringItem({
    required String value,
    required String label,
  }) {
    return OurbitRadioItem<String>(
      value: value,
      trailing: Text(label),
    );
  }
}
