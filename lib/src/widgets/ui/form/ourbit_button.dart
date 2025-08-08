import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

enum OurbitButtonVariance {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

class OurbitButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final OurbitButtonVariance variance;
  final bool isSelected;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final TextStyle? textStyle;

  const OurbitButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.variance = OurbitButtonVariance.primary,
    this.isSelected = false,
    this.leadingIcon,
    this.trailingIcon,
    this.textStyle,
  });

  // Convenience constructors
  const OurbitButton.primary({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
    this.leadingIcon,
    this.trailingIcon,
    this.textStyle,
  }) : variance = OurbitButtonVariance.primary;

  const OurbitButton.secondary({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
    this.leadingIcon,
    this.trailingIcon,
    this.textStyle,
  }) : variance = OurbitButtonVariance.secondary;

  const OurbitButton.outline({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
    this.leadingIcon,
    this.trailingIcon,
    this.textStyle,
  }) : variance = OurbitButtonVariance.outline;

  const OurbitButton.ghost({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
    this.leadingIcon,
    this.trailingIcon,
    this.textStyle,
  }) : variance = OurbitButtonVariance.ghost;

  const OurbitButton.destructive({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
    this.leadingIcon,
    this.trailingIcon,
    this.textStyle,
  }) : variance = OurbitButtonVariance.destructive;

  @override
  State<OurbitButton> createState() => _OurbitButtonState();
}

class _OurbitButtonState extends State<OurbitButton>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _hoverController;
  late AnimationController _shadowController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _hoverAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _hoverAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _hoverController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
      widget.onPressed!();
    }
  }

  void _handleHover(bool isHovered) {
    if (isHovered) {
      _hoverController.forward();
      _shadowController.forward();
    } else {
      _hoverController.reverse();
      _shadowController.reverse();
    }
  }

  Color _getBackgroundColor(ThemeService themeService) {
    if (widget.isSelected) {
      switch (widget.variance) {
        case OurbitButtonVariance.primary:
          return themeService.isDarkMode
              ? AppColors.primary
              : AppColors.primary;
        case OurbitButtonVariance.secondary:
          return themeService.isDarkMode
              ? AppColors.secondary
              : AppColors.secondary;
        case OurbitButtonVariance.outline:
          return themeService.isDarkMode
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.1);
        case OurbitButtonVariance.ghost:
          return themeService.isDarkMode
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.primary.withValues(alpha: 0.1);
        case OurbitButtonVariance.destructive:
          return themeService.isDarkMode ? AppColors.error : AppColors.error;
      }
    }

    switch (widget.variance) {
      case OurbitButtonVariance.primary:
        return themeService.isDarkMode ? AppColors.primary : AppColors.primary;
      case OurbitButtonVariance.secondary:
        return themeService.isDarkMode
            ? AppColors.secondary
            : AppColors.secondary;
      case OurbitButtonVariance.outline:
        return Colors.transparent;
      case OurbitButtonVariance.ghost:
        return Colors.transparent;
      case OurbitButtonVariance.destructive:
        return themeService.isDarkMode ? AppColors.error : AppColors.error;
    }
  }

  Border? _getBorder(ThemeService themeService) {
    if (widget.isSelected) {
      switch (widget.variance) {
        case OurbitButtonVariance.primary:
        case OurbitButtonVariance.secondary:
        case OurbitButtonVariance.ghost:
        case OurbitButtonVariance.destructive:
          return null;
        case OurbitButtonVariance.outline:
          return Border.all(
            color:
                themeService.isDarkMode ? AppColors.primary : AppColors.primary,
            width: 2,
          );
      }
    }

    switch (widget.variance) {
      case OurbitButtonVariance.primary:
      case OurbitButtonVariance.secondary:
      case OurbitButtonVariance.ghost:
      case OurbitButtonVariance.destructive:
        return null;
      case OurbitButtonVariance.outline:
        return Border.all(
          color: themeService.isDarkMode ? AppColors.border : AppColors.border,
          width: 1,
        );
    }
  }

  Color _getShadowColor(ThemeService themeService) {
    switch (widget.variance) {
      case OurbitButtonVariance.primary:
        return themeService.isDarkMode ? AppColors.primary : AppColors.primary;
      case OurbitButtonVariance.secondary:
        return themeService.isDarkMode
            ? AppColors.secondary
            : AppColors.secondary;
      case OurbitButtonVariance.outline:
        return themeService.isDarkMode ? AppColors.border : AppColors.border;
      case OurbitButtonVariance.ghost:
        return themeService.isDarkMode ? AppColors.muted : AppColors.muted;
      case OurbitButtonVariance.destructive:
        return themeService.isDarkMode ? AppColors.error : AppColors.error;
    }
  }

  Color _getTextColor(ThemeService themeService) {
    switch (widget.variance) {
      case OurbitButtonVariance.primary:
        return Colors.white;
      case OurbitButtonVariance.secondary:
        return themeService.isDarkMode
            ? AppColors.primaryText
            : AppColors.primaryText;
      case OurbitButtonVariance.outline:
        return themeService.isDarkMode
            ? AppColors.primaryText
            : AppColors.primaryText;
      case OurbitButtonVariance.ghost:
        return themeService.isDarkMode
            ? AppColors.primaryText
            : AppColors.primaryText;
      case OurbitButtonVariance.destructive:
        return Colors.white;
    }
  }

  Widget _buildContent(ThemeService themeService) {
    if (widget.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          onSurface: true,
        ),
      );
    }

    final List<Widget> children = [];

    // Leading icon
    if (widget.leadingIcon != null) {
      children.add(widget.leadingIcon!);
      children.add(const SizedBox(width: 8));
    }

    // Text
    children.add(
      Text(
        widget.label,
        style: widget.textStyle ??
            TextStyle(
              color: _getTextColor(themeService),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      ),
    );

    // Trailing icon
    if (widget.trailingIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(widget.trailingIcon!);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_bounceAnimation, _hoverAnimation, _shadowAnimation]),
            builder: (context, child) {
              return Transform.translate(
                offset: _hoverAnimation.value,
                child: Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(themeService),
                      border: _getBorder(themeService),
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(8),
                      boxShadow: _shadowAnimation.value > 0
                          ? [
                              BoxShadow(
                                color: _getShadowColor(themeService).withValues(
                                    alpha: 0.3 * _shadowAnimation.value),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: _getShadowColor(themeService).withValues(
                                    alpha: 0.2 * _shadowAnimation.value),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: GestureDetector(
                      onTap: widget.onPressed != null ? _handleTap : null,
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: _buildContent(themeService),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
