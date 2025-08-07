import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitProgress extends StatelessWidget {
  final double progress;
  final double min;
  final double max;
  final double? width;

  const OurbitProgress({
    super.key,
    required this.progress,
    this.min = 0,
    this.max = 100,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Progress(
        progress: progress.clamp(min, max),
        min: min,
        max: max,
      ),
    );
  }
}

// Helper class untuk membuat progress dengan mudah
class OurbitProgressBuilder {
  static OurbitProgress percentage({
    required double percentage,
    double? width,
  }) {
    return OurbitProgress(
      progress: percentage,
      width: width,
    );
  }

  static OurbitProgress custom({
    required double progress,
    required double min,
    required double max,
    double? width,
  }) {
    return OurbitProgress(
      progress: progress,
      min: min,
      max: max,
      width: width,
    );
  }

  static OurbitProgress thin({
    required double progress,
    double? width,
  }) {
    return OurbitProgress(
      progress: progress,
      width: width,
    );
  }

  static OurbitProgress wide({
    required double progress,
  }) {
    return OurbitProgress(
      progress: progress,
      width: 400,
    );
  }
}
