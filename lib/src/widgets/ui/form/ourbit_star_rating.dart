import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitStarRating extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double starSize;

  const OurbitStarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.starSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return StarRating(
      starSize: starSize,
      value: value,
      onChanged: onChanged,
    );
  }
}

// Helper class untuk membuat star rating dengan mudah
class OurbitStarRatingBuilder {
  static OurbitStarRating basic({
    required double value,
    ValueChanged<double>? onChanged,
  }) {
    return OurbitStarRating(
      value: value,
      onChanged: onChanged,
    );
  }

  static OurbitStarRating small({
    required double value,
    ValueChanged<double>? onChanged,
  }) {
    return OurbitStarRating(
      value: value,
      onChanged: onChanged,
      starSize: 24,
    );
  }

  static OurbitStarRating large({
    required double value,
    ValueChanged<double>? onChanged,
  }) {
    return OurbitStarRating(
      value: value,
      onChanged: onChanged,
      starSize: 48,
    );
  }

  static OurbitStarRating custom({
    required double value,
    required ValueChanged<double> onChanged,
    required double starSize,
  }) {
    return OurbitStarRating(
      value: value,
      onChanged: onChanged,
      starSize: starSize,
    );
  }
}
