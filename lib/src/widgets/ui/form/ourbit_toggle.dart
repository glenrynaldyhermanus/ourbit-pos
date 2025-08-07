import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget child;

  const OurbitToggle({
    super.key,
    required this.value,
    this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Toggle(
      value: value,
      onChanged: onChanged,
      child: child,
    );
  }
}

// Helper class untuk membuat toggle dengan mudah
class OurbitToggleBuilder {
  static OurbitToggle basic({
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    return OurbitToggle(
      value: value,
      onChanged: onChanged,
      child: child,
    );
  }

  static OurbitToggle withText({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String text,
  }) {
    return OurbitToggle(
      value: value,
      onChanged: onChanged,
      child: Text(text),
    );
  }

  static OurbitToggle icon({
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return OurbitToggle(
      value: value,
      onChanged: onChanged,
      child: Icon(icon),
    );
  }
}
