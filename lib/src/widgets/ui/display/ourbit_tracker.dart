import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitTracker extends StatelessWidget {
  final List<TrackerData> data;

  const OurbitTracker({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeService.isDarkMode 
                ? AppColors.darkSecondaryBackground 
                : AppColors.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: themeService.isDarkMode 
                  ? AppColors.darkBorder 
                  : AppColors.border,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Tracker(data: data),
        );
      },
    );
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
