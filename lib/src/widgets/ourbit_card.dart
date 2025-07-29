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

class OurbitCard extends StatefulWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const OurbitCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  @override
  State<OurbitCard> createState() => _OurbitCardState();
}

class _OurbitCardState extends State<OurbitCard> {
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

  List<BoxShadow> _getBoxShadows() {
    if (_isHovered) {
      return [
        BoxShadow(
          color: Colors.black26.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black26.withOpacity(0.15),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black26.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark
                ? AppColors.darkPrimaryBackground
                : AppColors.secondaryBackground),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        border: widget.border ??
            Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
        boxShadow: _getBoxShadows(),
      ),
      child: widget.child != null
          ? Padding(
              padding: widget.padding ?? const EdgeInsets.all(20),
              child: widget.child,
            )
          : null,
    );

    // Jika ada onTap, wrap dengan gesture detector
    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => _onHoverChanged(true),
        onExit: (_) => _onHoverChanged(false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            scale: _isPressed ? 0.95 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: widget.margin,
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    (isDark
                        ? AppColors.darkPrimaryBackground
                        : AppColors.secondaryBackground),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                border: widget.border ??
                    Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 1,
                    ),
                boxShadow: _getBoxShadows(),
              ),
              child: widget.child != null
                  ? Padding(
                      padding: widget.padding ?? const EdgeInsets.all(20),
                      child: widget.child,
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    // Jika tidak ada onTap, gunakan container biasa
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark
                ? AppColors.darkPrimaryBackground
                : AppColors.secondaryBackground),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        border: widget.border ??
            Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
        boxShadow: _getBoxShadows(),
      ),
      child: widget.child != null
          ? Padding(
              padding: widget.padding ?? const EdgeInsets.all(20),
              child: widget.child,
            )
          : null,
    );
  }
}

class OurbitCardHeader extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const OurbitCardHeader({
    super.key,
    this.child,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: border ??
            Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              ),
            ),
      ),
      child: child,
    );
  }
}

class OurbitCardTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const OurbitCardTitle({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      style: style ??
          _getSystemFont(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
          ),
      textAlign: textAlign,
    );
  }
}

class OurbitCardSubtitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const OurbitCardSubtitle({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      style: style ??
          _getSystemFont(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color:
                isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
          ),
      textAlign: textAlign,
    );
  }
}

class OurbitCardContent extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const OurbitCardContent({
    super.key,
    this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );
  }
}

class OurbitCardFooter extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final Border? border;

  const OurbitCardFooter({
    super.key,
    this.child,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: border ??
            Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              ),
            ),
      ),
      child: child,
    );
  }
}
