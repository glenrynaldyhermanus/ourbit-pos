import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitAlert extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Widget? leading;
  final Widget? trailing;

  const OurbitAlert({
    super.key,
    required this.title,
    required this.content,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      content: content,
      leading: leading,
      trailing: trailing,
    );
  }
}

// Helper class untuk membuat alert dengan mudah
class OurbitAlertBuilder {
  static OurbitAlert info({
    required String title,
    required String content,
    IconData? icon,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: icon != null ? Icon(icon) : const Icon(Icons.info_outline),
      trailing: trailing,
    );
  }

  static OurbitAlert success({
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: const Icon(Icons.check_circle_outline),
      trailing: trailing,
    );
  }

  static OurbitAlert warning({
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: const Icon(Icons.warning_amber_outlined),
      trailing: trailing,
    );
  }

  static OurbitAlert error({
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: Text(title),
      content: Text(content),
      leading: const Icon(Icons.error_outline),
      trailing: trailing,
    );
  }

  static OurbitAlert custom({
    required Widget title,
    required Widget content,
    Widget? leading,
    Widget? trailing,
  }) {
    return OurbitAlert(
      title: title,
      content: content,
      leading: leading,
      trailing: trailing,
    );
  }
}
