import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitCircularProgress extends StatelessWidget {
  final double? value;
  final double size;

  const OurbitCircularProgress({
    super.key,
    this.value,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: value,
          ),
        );
      },
    );
  }
}

// Helper class untuk membuat circular progress dengan mudah
class OurbitCircularProgressBuilder {
  static OurbitCircularProgress indeterminate({
    double size = 40,
  }) {
    return OurbitCircularProgress(
      size: size,
    );
  }

  static OurbitCircularProgress determinate({
    required double value,
    double size = 40,
  }) {
    return OurbitCircularProgress(
      value: value.clamp(0.0, 1.0),
      size: size,
    );
  }

  static OurbitCircularProgress percentage({
    required double percentage,
    double size = 40,
  }) {
    return OurbitCircularProgress(
      value: (percentage / 100).clamp(0.0, 1.0),
      size: size,
    );
  }

  static OurbitCircularProgress small({
    double? value,
  }) {
    return OurbitCircularProgress(
      value: value,
      size: 24,
    );
  }

  static OurbitCircularProgress large({
    double? value,
  }) {
    return OurbitCircularProgress(
      value: value,
      size: 64,
    );
  }
}
