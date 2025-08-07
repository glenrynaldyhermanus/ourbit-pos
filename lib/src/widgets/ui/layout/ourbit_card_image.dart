import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitCardImage extends StatelessWidget {
  final Widget image;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onPressed;

  const OurbitCardImage({
    super.key,
    required this.image,
    required this.title,
    this.subtitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CardImage(
      onPressed: onPressed,
      image: image,
      title: title,
      subtitle: subtitle,
    );
  }
}

// Helper class untuk membuat card image dengan mudah
class OurbitCardImageBuilder {
  static OurbitCardImage basic({
    required Widget image,
    required String title,
    String? subtitle,
    VoidCallback? onPressed,
  }) {
    return OurbitCardImage(
      image: image,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onPressed: onPressed,
    );
  }

  static OurbitCardImage network({
    required String imageUrl,
    required String title,
    String? subtitle,
    VoidCallback? onPressed,
  }) {
    return OurbitCardImage(
      image: Image.network(imageUrl),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onPressed: onPressed,
    );
  }

  static OurbitCardImage asset({
    required String imagePath,
    required String title,
    String? subtitle,
    VoidCallback? onPressed,
  }) {
    return OurbitCardImage(
      image: Image.asset(imagePath),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onPressed: onPressed,
    );
  }

  static OurbitCardImage custom({
    required Widget image,
    required Widget title,
    Widget? subtitle,
    VoidCallback? onPressed,
  }) {
    return OurbitCardImage(
      image: image,
      title: title,
      subtitle: subtitle,
      onPressed: onPressed,
    );
  }
}
