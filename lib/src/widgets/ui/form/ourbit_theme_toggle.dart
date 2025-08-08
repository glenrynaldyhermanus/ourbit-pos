import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';

/// Widget untuk toggle tema antara light mode dan dark mode
///
/// Widget ini memberikan UI yang intuitif untuk beralih antara mode terang dan gelap.
/// Menggunakan animasi smooth dan feedback visual yang baik.
///
/// ## Fitur:
/// - ✅ Toggle antara light mode dan dark mode
/// - ✅ Animasi smooth saat perpindahan
/// - ✅ Icon yang berubah sesuai mode
/// - ✅ Tooltip yang informatif
/// - ✅ Support keyboard navigation
/// - ✅ Responsive design
///
/// ## Penggunaan:
///
/// ```dart
/// // Basic usage
/// OurbitThemeToggle()
///
/// // With custom size
/// OurbitThemeToggle(
///   size: 48,
///   showTooltip: true,
/// )
///
/// // With custom styling
/// OurbitThemeToggle(
///   variant: OurbitThemeToggleVariant.outline,
///   showLabel: true,
/// )
/// ```
class OurbitThemeToggle extends StatefulWidget {
  final double? size;
  final bool showTooltip;
  final bool showLabel;
  final OurbitThemeToggleVariant variant;
  final String? lightModeLabel;
  final String? darkModeLabel;

  const OurbitThemeToggle({
    super.key,
    this.size,
    this.showTooltip = true,
    this.showLabel = false,
    this.variant = OurbitThemeToggleVariant.ghost,
    this.lightModeLabel,
    this.darkModeLabel,
  });

  @override
  State<OurbitThemeToggle> createState() => _OurbitThemeToggleState();
}

class _OurbitThemeToggleState extends State<OurbitThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleToggle(ThemeService themeService) {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    _rotationController.forward().then((_) {
      _rotationController.reset();
    });

    themeService.toggleTheme();
  }

  Widget _buildIcon(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 0.5 * 3.14159,
          child: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            size: widget.size != null ? widget.size! * 0.5 : 20,
          ),
        );
      },
    );
  }

  Widget _buildContent(ThemeService themeService) {
    final isDarkMode = themeService.isDarkMode;
    final icon = _buildIcon(isDarkMode);

    if (widget.showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            isDarkMode
                ? (widget.darkModeLabel ?? 'Mode Gelap')
                : (widget.lightModeLabel ?? 'Mode Terang'),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );
    }

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final isDarkMode = themeService.isDarkMode;

        Widget toggleWidget = AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildToggleButton(themeService, isDarkMode),
            );
          },
        );

        if (widget.showTooltip) {
          toggleWidget = Tooltip(
            tooltip: (context) => Text(isDarkMode
                ? 'Beralih ke Mode Terang'
                : 'Beralih ke Mode Gelap'),
            child: toggleWidget,
          );
        }

        return toggleWidget;
      },
    );
  }

  Widget _buildToggleButton(ThemeService themeService, bool isDarkMode) {
    switch (widget.variant) {
      case OurbitThemeToggleVariant.ghost:
        return OurbitIconButton.ghost(
          onPressed: () => _handleToggle(themeService),
          icon: _buildContent(themeService),
          size: widget.size,
        );

      case OurbitThemeToggleVariant.outline:
        return OurbitIconButton.outline(
          onPressed: () => _handleToggle(themeService),
          icon: _buildContent(themeService),
          size: widget.size,
        );

      case OurbitThemeToggleVariant.primary:
        return OurbitIconButton.primary(
          onPressed: () => _handleToggle(themeService),
          icon: _buildContent(themeService),
          size: widget.size,
        );

      case OurbitThemeToggleVariant.secondary:
        return OurbitIconButton.secondary(
          onPressed: () => _handleToggle(themeService),
          icon: _buildContent(themeService),
          size: widget.size,
        );
    }
  }
}

/// Variant untuk OurbitThemeToggle
enum OurbitThemeToggleVariant {
  ghost,
  outline,
  primary,
  secondary,
}

/// Helper class untuk membuat theme toggle dengan mudah
class OurbitThemeToggleBuilder {
  static OurbitThemeToggle basic({
    double? size,
    bool showTooltip = true,
  }) {
    return OurbitThemeToggle(
      size: size,
      showTooltip: showTooltip,
    );
  }

  static OurbitThemeToggle withLabel({
    double? size,
    bool showTooltip = true,
    String? lightModeLabel,
    String? darkModeLabel,
  }) {
    return OurbitThemeToggle(
      size: size,
      showTooltip: showTooltip,
      showLabel: true,
      lightModeLabel: lightModeLabel,
      darkModeLabel: darkModeLabel,
    );
  }

  static OurbitThemeToggle outline({
    double? size,
    bool showTooltip = true,
  }) {
    return OurbitThemeToggle(
      size: size,
      showTooltip: showTooltip,
      variant: OurbitThemeToggleVariant.outline,
    );
  }

  static OurbitThemeToggle primary({
    double? size,
    bool showTooltip = true,
  }) {
    return OurbitThemeToggle(
      size: size,
      showTooltip: showTooltip,
      variant: OurbitThemeToggleVariant.primary,
    );
  }

  static OurbitThemeToggle secondary({
    double? size,
    bool showTooltip = true,
  }) {
    return OurbitThemeToggle(
      size: size,
      showTooltip: showTooltip,
      variant: OurbitThemeToggleVariant.secondary,
    );
  }

  static OurbitThemeToggle large({
    bool showTooltip = true,
    bool showLabel = false,
  }) {
    return OurbitThemeToggle(
      size: 56,
      showTooltip: showTooltip,
      showLabel: showLabel,
    );
  }

  static OurbitThemeToggle small({
    bool showTooltip = true,
  }) {
    return OurbitThemeToggle(
      size: 32,
      showTooltip: showTooltip,
    );
  }
}
