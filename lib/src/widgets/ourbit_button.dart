import 'package:flutter/material.dart';

import 'package:ourbit_pos/src/core/theme/app_theme.dart';

// Helper function untuk menggunakan system font
TextStyle _getSystemFont({
  required double fontSize,
  FontWeight? fontWeight,
  Color? color,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

enum OurbitButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

enum OurbitButtonSize {
  small,
  medium,
  large,
  icon,
}

class OurbitButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final OurbitButtonVariant variant;
  final OurbitButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final Widget? child;

  const OurbitButton({
    super.key,
    this.text,
    this.icon,
    this.variant = OurbitButtonVariant.primary,
    this.size = OurbitButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.child,
  });

  @override
  State<OurbitButton> createState() => _OurbitButtonState();
}

class _OurbitButtonState extends State<OurbitButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTapDown: (widget.isDisabled || widget.isLoading) ? null : _onTapDown,
        onTapUp: (widget.isDisabled || widget.isLoading) ? null : _onTapUp,
        onTapCancel:
            (widget.isDisabled || widget.isLoading) ? null : _onTapCancel,
        onTap:
            (widget.isDisabled || widget.isLoading) ? null : widget.onPressed,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          scale: _isPressed ? 0.95 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: _getPadding(),
            decoration: _getDecoration(theme),
            child: _buildContent(theme),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case OurbitButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case OurbitButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
      case OurbitButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 36, vertical: 18);
      case OurbitButtonSize.icon:
        return const EdgeInsets.all(14);
    }
  }

  BoxDecoration _getDecoration(ThemeData theme) {
    // Base shadows - enhanced when hovered
    List<BoxShadow> getBoxShadows(Color shadowColor) {
      if (_isHovered) {
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ];
      } else {
        return [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      }
    }

    switch (widget.variant) {
      case OurbitButtonVariant.primary:
        return BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: getBoxShadows(Colors.black26),
        );
      case OurbitButtonVariant.secondary:
        return BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? AppColors.darkMuted
              : AppColors.muted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.border,
          ),
          boxShadow: getBoxShadows(Colors.black26),
        );
      case OurbitButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.border,
            width: 1.5,
          ),
          boxShadow: getBoxShadows(Colors.black26),
        );
      case OurbitButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered ? getBoxShadows(Colors.black26) : null,
        );
      case OurbitButtonVariant.destructive:
        return BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
          boxShadow: getBoxShadows(Colors.black26),
        );
    }
  }

  Widget _buildContent(ThemeData theme) {
    if (widget.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(theme),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: _getSystemFont(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _getTextColor(theme),
            ),
          ),
        ],
      );
    }

    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.size == OurbitButtonSize.icon && widget.icon != null) {
      return Icon(
        widget.icon,
        size: 20,
        color: _getTextColor(theme),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: 18,
            color: _getTextColor(theme),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.text != null)
          Text(
            widget.text!,
            style: _getSystemFont(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w500,
              color: _getTextColor(theme),
            ),
          ),
      ],
    );
  }

  Color _getTextColor(ThemeData theme) {
    switch (widget.variant) {
      case OurbitButtonVariant.primary:
      case OurbitButtonVariant.destructive:
        return Colors.white;
      case OurbitButtonVariant.secondary:
        return theme.brightness == Brightness.dark
            ? AppColors.darkPrimaryText
            : AppColors.primaryText;
      case OurbitButtonVariant.outline:
        return theme.brightness == Brightness.dark
            ? AppColors.darkPrimary
            : AppColors.primary;
      case OurbitButtonVariant.ghost:
        return theme.brightness == Brightness.dark
            ? AppColors.darkPrimary
            : AppColors.primary;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case OurbitButtonSize.small:
        return 12;
      case OurbitButtonSize.medium:
        return 14;
      case OurbitButtonSize.large:
        return 16;
      case OurbitButtonSize.icon:
        return 14;
    }
  }
}

// Convenience constructors
class OurbitPrimaryButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final OurbitButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final Widget? child;

  const OurbitPrimaryButton({
    super.key,
    this.text,
    this.icon,
    this.size = OurbitButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OurbitButton(
      text: text,
      icon: icon,
      variant: OurbitButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: onPressed,
      child: child,
    );
  }
}

class OurbitSecondaryButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final OurbitButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final Widget? child;

  const OurbitSecondaryButton({
    super.key,
    this.text,
    this.icon,
    this.size = OurbitButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OurbitButton(
      text: text,
      icon: icon,
      variant: OurbitButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: onPressed,
      child: child,
    );
  }
}

class OurbitOutlineButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final OurbitButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final Widget? child;

  const OurbitOutlineButton({
    super.key,
    this.text,
    this.icon,
    this.size = OurbitButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OurbitButton(
      text: text,
      icon: icon,
      variant: OurbitButtonVariant.outline,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      onPressed: onPressed,
      child: child,
    );
  }
}
