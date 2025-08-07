import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitLinearProgress extends StatelessWidget {
  final double? value;
  final double? width;
  final double height;

  const OurbitLinearProgress({
    super.key,
    this.value,
    this.width,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LinearProgressIndicator(
        value: value,
      ),
    );
  }
}

// Helper class untuk membuat linear progress dengan mudah
class OurbitLinearProgressBuilder {
  static OurbitLinearProgress indeterminate({
    double? width,
    double height = 4,
  }) {
    return OurbitLinearProgress(
      width: width,
      height: height,
    );
  }

  static OurbitLinearProgress determinate({
    required double value,
    double? width,
    double height = 4,
  }) {
    return OurbitLinearProgress(
      value: value.clamp(0.0, 1.0),
      width: width,
      height: height,
    );
  }

  static OurbitLinearProgress percentage({
    required double percentage,
    double? width,
    double height = 4,
  }) {
    return OurbitLinearProgress(
      value: (percentage / 100).clamp(0.0, 1.0),
      width: width,
      height: height,
    );
  }

  static OurbitLinearProgress thin({
    double? value,
    double? width,
  }) {
    return OurbitLinearProgress(
      value: value,
      width: width,
      height: 2,
    );
  }

  static OurbitLinearProgress thick({
    double? value,
    double? width,
  }) {
    return OurbitLinearProgress(
      value: value,
      width: width,
      height: 8,
    );
  }
}
