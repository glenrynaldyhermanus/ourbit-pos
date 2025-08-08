import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

class OurbitTable extends StatelessWidget {
  final List<TableRow> rows;
  final List<TableCell> headers;
  final bool showHeader;
  final bool scrollable;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? defaultRowHeight;

  const OurbitTable({
    super.key,
    required this.rows,
    this.headers = const [],
    this.showHeader = true,
    this.scrollable = true,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.defaultRowHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final theme = Theme.of(context);

        return Container(
          constraints: BoxConstraints(
            minWidth: minWidth ?? 600,
            maxWidth: maxWidth ?? double.infinity,
            minHeight: minHeight ?? 200,
            maxHeight: maxHeight ?? double.infinity,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.card,
            borderRadius: borderRadius ?? theme.borderRadiusLg,
            border: Border.all(
              color: borderColor ?? theme.colorScheme.border,
              width: 1,
            ),
          ),
          child: scrollable ? _buildScrollableTable() : _buildBasicTable(),
        );
      },
    );
  }

  Widget _buildScrollableTable() {
    return Builder(
      builder: (context) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
          overscroll: false,
        ),
        child: SizedBox(
          height: minHeight ?? 400,
          child: OutlinedContainer(
            child: ScrollableClient(
              diagonalDragBehavior: DiagonalDragBehavior.free,
              builder: (context, offset, viewportSize, child) {
                return Table(
                  horizontalOffset: offset.dx,
                  verticalOffset: offset.dy,
                  viewportSize: viewportSize,
                  defaultColumnWidth: const FixedTableSize(150),
                  defaultRowHeight: FixedTableSize(defaultRowHeight ?? 60),
                  rows: [
                    if (showHeader && headers.isNotEmpty)
                      TableHeader(cells: headers),
                    ...rows,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicTable() {
    return Table(
      rows: [
        if (showHeader && headers.isNotEmpty) TableRow(cells: headers),
        ...rows,
      ],
    );
  }
}

// Helper class untuk membuat table cell dengan styling yang konsisten
class OurbitTableCell {
  final Widget child;
  final bool isHeader;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final bool expanded;
  final double? width;

  const OurbitTableCell({
    required this.child,
    this.isHeader = false,
    this.alignment,
    this.padding,
    this.backgroundColor,
    this.textStyle,
    this.expanded = true,
    this.width,
  });

  TableCell build(BuildContext context) {
    final theme = Theme.of(context);

    return TableCell(
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return Container(
            padding: padding ?? const EdgeInsets.all(12),
            alignment: alignment ?? Alignment.centerLeft,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.border,
                  width: 0.5,
                ),
              ),
            ),
            child: expanded
                ? (isHeader
                    ? DefaultTextStyle(
                        style: (textStyle ??
                                const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600))
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                        child: child,
                      )
                    : DefaultTextStyle(
                        style: (textStyle ?? const TextStyle(fontSize: 12))
                            .copyWith(
                          color: theme.colorScheme.foreground,
                        ),
                        child: child,
                      ))
                : SizedBox(
                    width: width ??
                        100, // Default width untuk cell yang tidak expanded
                    child: isHeader
                        ? DefaultTextStyle(
                            style: (textStyle ??
                                    const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600))
                                .copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.foreground,
                            ),
                            child: child,
                          )
                        : DefaultTextStyle(
                            style: (textStyle ?? const TextStyle(fontSize: 12))
                                .copyWith(
                              color: theme.colorScheme.foreground,
                            ),
                            child: child,
                          ),
                  ),
          );
        },
      ),
    );
  }
}

// Helper class untuk membuat action buttons dalam table
class OurbitTableActions extends StatelessWidget {
  final List<Widget> actions;
  final EdgeInsets? padding;

  const OurbitTableActions({
    super.key,
    required this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map((action) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: action,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
