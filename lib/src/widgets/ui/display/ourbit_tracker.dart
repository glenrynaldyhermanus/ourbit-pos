import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitTracker extends StatelessWidget {
  final List<TrackerData> data;

  const OurbitTracker({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Tracker(data: data);
  }
}

// Helper class untuk membuat tracker dengan mudah
class OurbitTrackerBuilder {
  static OurbitTracker fromData({
    required List<TrackerData> data,
  }) {
    return OurbitTracker(data: data);
  }
}
