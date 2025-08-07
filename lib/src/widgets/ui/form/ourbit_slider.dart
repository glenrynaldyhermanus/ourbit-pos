import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitSlider extends StatelessWidget {
  final SliderValue value;
  final ValueChanged<SliderValue>? onChanged;
  final int? divisions;

  const OurbitSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      onChanged: onChanged,
      divisions: divisions,
    );
  }
}

// Helper class untuk membuat slider dengan mudah
class OurbitSliderBuilder {
  static OurbitSlider single({
    required double value,
    ValueChanged<SliderValue>? onChanged,
    int? divisions,
  }) {
    return OurbitSlider(
      value: SliderValue.single(value),
      onChanged: onChanged,
      divisions: divisions,
    );
  }

  static OurbitSlider ranged({
    required double start,
    required double end,
    ValueChanged<SliderValue>? onChanged,
    int? divisions,
  }) {
    return OurbitSlider(
      value: SliderValue.ranged(start, end),
      onChanged: onChanged,
      divisions: divisions,
    );
  }

  static OurbitSlider withDivisions({
    required double value,
    required int divisions,
    ValueChanged<SliderValue>? onChanged,
  }) {
    return OurbitSlider(
      value: SliderValue.single(value),
      onChanged: onChanged,
      divisions: divisions,
    );
  }

  static OurbitSlider percentage({
    required double percentage,
    ValueChanged<SliderValue>? onChanged,
  }) {
    return OurbitSlider(
      value: SliderValue.single(percentage / 100),
      onChanged: onChanged,
    );
  }
}
