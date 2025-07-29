import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(24);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(12);
    }
  }

  static double getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) {
      return 5;
    } else if (isTablet(context)) {
      return 4;
    } else {
      return 3;
    }
  }

  static double getCartWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 500;
    } else if (isTablet(context)) {
      return 450;
    } else {
      return 400;
    }
  }

  static double getIconSize(BuildContext context) {
    if (isDesktop(context)) {
      return 40;
    } else if (isTablet(context)) {
      return 35;
    } else {
      return 30;
    }
  }

  static double getFontSize(BuildContext context, {double baseSize = 14}) {
    if (isDesktop(context)) {
      return baseSize + 2;
    } else if (isTablet(context)) {
      return baseSize + 1;
    } else {
      return baseSize;
    }
  }

  // Platform detection
  static bool isWeb() => kIsWeb;

  static bool isMobilePlatform() => !kIsWeb;
}
