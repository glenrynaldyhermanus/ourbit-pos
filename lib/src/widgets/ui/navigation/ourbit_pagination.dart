import 'package:shadcn_flutter/shadcn_flutter.dart';

class OurbitPagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const OurbitPagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Pagination(
      page: page,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
    );
  }
}

// Helper class untuk membuat pagination dengan mudah
class OurbitPaginationBuilder {
  static OurbitPagination basic({
    required int page,
    required int totalPages,
    required ValueChanged<int> onPageChanged,
  }) {
    return OurbitPagination(
      page: page,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
    );
  }
}
