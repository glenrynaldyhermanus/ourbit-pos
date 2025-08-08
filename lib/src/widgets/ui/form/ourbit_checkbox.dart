import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitCheckbox extends StatelessWidget {
  final CheckboxState state;
  final ValueChanged<CheckboxState>? onChanged;
  final Widget? trailing;
  final bool tristate;

  const OurbitCheckbox({
    super.key,
    required this.state,
    this.onChanged,
    this.trailing,
    this.tristate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Checkbox(
          state: state,
          onChanged: onChanged,
          trailing: trailing,
          tristate: tristate,
        );
      },
    );
  }
}

// Helper class untuk membuat checkbox dengan mudah
class OurbitCheckboxBuilder {
  static OurbitCheckbox basic({
    required CheckboxState state,
    required ValueChanged<CheckboxState> onChanged,
    Widget? trailing,
  }) {
    return OurbitCheckbox(
      state: state,
      onChanged: onChanged,
      trailing: trailing,
    );
  }

  static OurbitCheckbox tristate({
    required CheckboxState state,
    required ValueChanged<CheckboxState> onChanged,
    Widget? trailing,
  }) {
    return OurbitCheckbox(
      state: state,
      onChanged: onChanged,
      trailing: trailing,
      tristate: true,
    );
  }

  static OurbitCheckbox withLabel({
    required CheckboxState state,
    required ValueChanged<CheckboxState> onChanged,
    required String label,
    bool tristate = false,
  }) {
    return OurbitCheckbox(
      state: state,
      onChanged: onChanged,
      trailing: Text(label),
      tristate: tristate,
    );
  }
}
