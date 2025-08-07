import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitCarousel extends StatelessWidget {
  final CarouselController controller;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final CarouselTransition transition;
  final Duration? autoplaySpeed;
  final Duration? duration;
  final Axis direction;

  const OurbitCarousel({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.transition = const CarouselTransition.sliding(gap: 24),
    this.autoplaySpeed,
    this.duration,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return Carousel(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      transition: transition,
      autoplaySpeed: autoplaySpeed,
      duration: duration,
      direction: direction,
    );
  }
}

// Helper class untuk membuat carousel dengan mudah
class OurbitCarouselBuilder {
  static OurbitCarousel horizontal({
    required CarouselController controller,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    Duration? autoplaySpeed,
    Duration? duration,
  }) {
    return OurbitCarousel(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      autoplaySpeed: autoplaySpeed,
      duration: duration,
    );
  }

  static OurbitCarousel vertical({
    required CarouselController controller,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return OurbitCarousel(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      direction: Axis.vertical,
    );
  }

  static OurbitCarousel fading({
    required CarouselController controller,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    Duration? autoplaySpeed,
    Duration? duration,
  }) {
    return OurbitCarousel(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      transition: const CarouselTransition.fading(),
      autoplaySpeed: autoplaySpeed,
      duration: duration,
    );
  }

  static OurbitCarousel sliding({
    required CarouselController controller,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double gap = 24,
    Duration? autoplaySpeed,
    Duration? duration,
  }) {
    return OurbitCarousel(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      transition: CarouselTransition.sliding(gap: gap),
      autoplaySpeed: autoplaySpeed,
      duration: duration,
    );
  }
}
