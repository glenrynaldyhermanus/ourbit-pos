import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? trailing;

  const OurbitSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      trailing: trailing,
    );
  }
}

// Helper class untuk membuat switch dengan mudah
class OurbitSwitchBuilder {
  static OurbitSwitch basic({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return OurbitSwitch(
      value: value,
      onChanged: onChanged,
    );
  }

  static OurbitSwitch withLabel({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
  }) {
    return OurbitSwitch(
      value: value,
      onChanged: onChanged,
      trailing: Text(label),
    );
  }

  static OurbitSwitch withCustomTrailing({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget trailing,
  }) {
    return OurbitSwitch(
      value: value,
      onChanged: onChanged,
      trailing: trailing,
    );
  }
}
