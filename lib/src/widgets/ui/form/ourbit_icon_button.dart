import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:ourbit_pos/src/core/theme/app_theme.dart';

enum OurbitIconButtonVariance {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

class OurbitIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isLoading;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final OurbitIconButtonVariance variance;

  const OurbitIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.size = 40,
    this.padding,
    this.borderRadius,
    this.variance = OurbitIconButtonVariance.primary,
  });

  // Named constructors for each variance
  const OurbitIconButton.primary({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.size = 40,
    this.padding,
    this.borderRadius,
  }) : variance = OurbitIconButtonVariance.primary;

  const OurbitIconButton.secondary({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.size = 40,
    this.padding,
    this.borderRadius,
  }) : variance = OurbitIconButtonVariance.secondary;

  const OurbitIconButton.outline({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.size = 40,
    this.padding,
    this.borderRadius,
  }) : variance = OurbitIconButtonVariance.outline;

  const OurbitIconButton.ghost({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.size = 40,
    this.padding,
    this.borderRadius,
  }) : variance = OurbitIconButtonVariance.ghost;

  const OurbitIconButton.destructive({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.size = 40,
    this.padding,
    this.borderRadius,
  }) : variance = OurbitIconButtonVariance.destructive;

  @override
  State<OurbitIconButton> createState() => _OurbitIconButtonState();
}

class _OurbitIconButtonState extends State<OurbitIconButton>
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

  Color _getBackgroundColor() {
    switch (widget.variance) {
      case OurbitIconButtonVariance.primary:
        return AppColors.primary;
      case OurbitIconButtonVariance.secondary:
        return AppColors.secondary;
      case OurbitIconButtonVariance.outline:
        return Colors.transparent;
      case OurbitIconButtonVariance.ghost:
        return Colors.transparent;
      case OurbitIconButtonVariance.destructive:
        return AppColors.error;
    }
  }

  Color _getIconColor() {
    switch (widget.variance) {
      case OurbitIconButtonVariance.primary:
        return Colors.white;
      case OurbitIconButtonVariance.secondary:
        return Colors.white;
      case OurbitIconButtonVariance.outline:
        return AppColors.primaryText;
      case OurbitIconButtonVariance.ghost:
        return AppColors.primaryText;
      case OurbitIconButtonVariance.destructive:
        return Colors.white;
    }
  }

  Color _getShadowColor() {
    switch (widget.variance) {
      case OurbitIconButtonVariance.primary:
        return AppColors.primary;
      case OurbitIconButtonVariance.secondary:
        return AppColors.secondary;
      case OurbitIconButtonVariance.outline:
        return AppColors.border;
      case OurbitIconButtonVariance.ghost:
        return AppColors.muted;
      case OurbitIconButtonVariance.destructive:
        return AppColors.error;
    }
  }

  Border? _getBorder() {
    switch (widget.variance) {
      case OurbitIconButtonVariance.primary:
      case OurbitIconButtonVariance.secondary:
      case OurbitIconButtonVariance.destructive:
        return null;
      case OurbitIconButtonVariance.outline:
        return Border.all(color: AppColors.border);
      case OurbitIconButtonVariance.ghost:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onPressed != null ? _handleTap : null,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_bounceAnimation, _hoverAnimation, _shadowAnimation]),
          builder: (context, child) {
            return Transform.translate(
              offset: _hoverAnimation.value,
              child: Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(8),
                    border: _getBorder(),
                    boxShadow: _shadowAnimation.value > 0
                        ? [
                            BoxShadow(
                              color: _getShadowColor().withValues(
                                  alpha: 0.3 * _shadowAnimation.value),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: _getShadowColor().withValues(
                                  alpha: 0.2 * _shadowAnimation.value),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              onSurface: true,
                            ),
                          )
                        : DefaultTextStyle(
                            style: TextStyle(color: _getIconColor()),
                            child: widget.icon,
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
