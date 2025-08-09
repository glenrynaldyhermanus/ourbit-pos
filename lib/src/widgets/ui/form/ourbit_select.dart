import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

/// Custom Select Widget dengan efek bounce animation saat focus
///
/// Widget ini memberikan feedback visual yang subtle saat user focus pada select field.
/// Menggunakan animasi bounce (scale 0.98) dengan duration 100ms dan curve easeInOut.
///
/// ## Fitur:
/// - ✅ Bounce animation saat focus
/// - ✅ Support semua fitur Select shadcn_flutter
/// - ✅ Search functionality
/// - ✅ Customizable styling
/// - ✅ Focus management
///
/// ## Penggunaan:
///
/// ```dart
/// // Basic usage
/// OurbitSelect<String>(
///   value: selectedValue,
///   items: ['Apple', 'Banana', 'Cherry'],
///   itemBuilder: (context, item) => Text(item),
///   onChanged: (value) => setState(() => selectedValue = value),
///   placeholder: Text('Select a fruit'),
/// )
///
/// // With search
/// OurbitSelect<String>(
///   value: selectedValue,
///   items: ['Apple', 'Banana', 'Cherry'],
///   itemBuilder: (context, item) => Text(item),
///   onChanged: (value) => setState(() => selectedValue = value),
///   placeholder: Text('Select a fruit'),
///   searchPlaceholder: 'Search fruits...',
/// )
/// ```
class OurbitSelect<T> extends StatefulWidget {
  final T? value;
  final void Function(T?)? onChanged;
  final Widget? placeholder;
  final Widget Function(BuildContext, T) itemBuilder;
  final List<T> items;
  final String? searchPlaceholder;
  final BoxConstraints? constraints;
  final bool enabled;

  const OurbitSelect({
    super.key,
    this.value,
    this.onChanged,
    this.placeholder,
    required this.itemBuilder,
    required this.items,
    this.searchPlaceholder,
    this.constraints = const BoxConstraints(minHeight: 44, maxHeight: 44),
    this.enabled = true,
  });

  @override
  State<OurbitSelect<T>> createState() => _OurbitSelectState<T>();
}

class _OurbitSelectState<T> extends State<OurbitSelect<T>>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  T? _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;

    // Initialize animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Setup bounce animation
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
  }

  void _triggerBounceAnimation() {
    if (widget.enabled) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  void _handleChanged(T? value) {
    // Trigger animation when value changes (indicating user interaction)
    if (value != _previousValue) {
      _triggerBounceAnimation();
      _previousValue = value;
    }

    // Call original onChanged
    widget.onChanged?.call(value);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        Widget buildItem(BuildContext context, T item) {
          return widget.itemBuilder(context, item);
        }

        final isDark = themeService.isDarkMode;
        final borderColor =
            isDark ? const Color(0xff292524) : const Color(0xFFE5E7EB);

        return AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Listener(
                onPointerDown: (_) => _triggerBounceAnimation(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Select<T>(
                    value: widget.value,
                    onChanged: widget.enabled ? _handleChanged : null,
                    placeholder: widget.placeholder,
                    constraints: widget.constraints,
                    itemBuilder: buildItem,
                    popup: SelectPopup.builder(
                      searchPlaceholder: widget.searchPlaceholder != null
                          ? Text(widget.searchPlaceholder!)
                          : null,
                      builder: (context, searchQuery) {
                        final filteredItems = searchQuery == null
                            ? widget.items
                            : widget.items.where((item) {
                                final itemText = buildItem(context, item)
                                    .toString()
                                    .toLowerCase();
                                return itemText
                                    .contains(searchQuery.toLowerCase());
                              }).toList();

                        return SelectItemList(
                          children: [
                            for (final item in filteredItems)
                              SelectItemButton(
                                value: item,
                                child: buildItem(context, item),
                              ),
                          ],
                        );
                      },
                    ).call,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
