import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitCodeSnippet extends StatelessWidget {
  final String code;
  final String mode;

  const OurbitCodeSnippet({
    super.key,
    required this.code,
    this.mode = 'text',
  });

  @override
  Widget build(BuildContext context) {
    return CodeSnippet(
      code: code,
      mode: mode,
    );
  }
}

// Helper class untuk membuat code snippet dengan mudah
class OurbitCodeSnippetBuilder {
  static OurbitCodeSnippet shell({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'shell',
    );
  }

  static OurbitCodeSnippet dart({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'dart',
    );
  }

  static OurbitCodeSnippet json({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'json',
    );
  }

  static OurbitCodeSnippet sql({
    required String code,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: 'sql',
    );
  }

  static OurbitCodeSnippet custom({
    required String code,
    required String mode,
  }) {
    return OurbitCodeSnippet(
      code: code,
      mode: mode,
    );
  }
}
