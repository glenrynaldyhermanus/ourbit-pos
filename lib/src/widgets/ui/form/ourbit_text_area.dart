import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';

/// Custom Text Area Widget dengan efek shrink animation saat focus
///
/// Widget ini memberikan feedback visual yang subtle saat user focus pada text area.
/// Menggunakan animasi shrink (scale 0.98) dengan duration 200ms dan curve easeInOut.
///
/// ## Fitur:
/// - ✅ Shrink animation saat focus
/// - ✅ Support semua fitur TextArea shadcn_flutter
/// - ✅ Expandable width dan height
/// - ✅ Form validation integration
/// - ✅ Customizable styling
/// - ✅ Focus management
///
/// ## Penggunaan:
///
/// ```dart
/// // Basic usage
/// OurbitTextArea(
///   initialValue: 'Hello, World!',
///   onChanged: (value) => print(value),
/// )
///
/// // Expandable height
/// OurbitTextArea(
///   initialValue: 'Hello, World!',
///   expandableHeight: true,
///   initialHeight: 300,
/// )
///
/// // Expandable width
/// OurbitTextArea(
///   initialValue: 'Hello, World!',
///   expandableWidth: true,
///   initialWidth: 500,
/// )
///
/// // Expandable width dan height
/// OurbitTextArea(
///   initialValue: 'Hello, World!',
///   expandableWidth: true,
///   expandableHeight: true,
///   initialWidth: 500,
///   initialHeight: 300,
/// )
///
/// // With form validation
/// OurbitFormField(
///   fieldKey: const TextFieldKey('description'),
///   label: 'Description',
///   initialValue: 'Enter description',
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Description is required';
///     }
///     return null;
///   },
/// )
/// ```
class OurbitTextArea extends StatefulWidget {
  final String? initialValue;
  final String? placeholder;
  final String? label;
  final bool expandableWidth;
  final bool expandableHeight;
  final double? initialWidth;
  final double? initialHeight;
  final List<InputFeature>? features;
  final TextFieldKey? fieldKey;
  final FormValidationMode? showErrors;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(bool)? onFocusChange;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const OurbitTextArea({
    super.key,
    this.initialValue,
    this.placeholder,
    this.label,
    this.expandableWidth = false,
    this.expandableHeight = false,
    this.initialWidth,
    this.initialHeight,
    this.features,
    this.fieldKey,
    this.showErrors,
    this.validator,
    this.onChanged,
    this.onFocusChange,
    this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  State<OurbitTextArea> createState() => _OurbitTextAreaState();
}

class _OurbitTextAreaState extends State<OurbitTextArea>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    // Initialize focus node
    _focusNode = widget.focusNode ?? FocusNode();

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

    // Add focus listener
    _focusNode.addListener(() {
      _onFocusChange(_focusNode.hasFocus);
    });
  }

  void _onFocusChange(bool focused) {
    if (focused) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }

    // Call parent onFocusChange if provided
    widget.onFocusChange?.call(focused);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            return Transform.scale(
              scale: _bounceAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                child: TextArea(
                  key: widget.fieldKey,
                  initialValue: widget.initialValue,
                  placeholder:
                      widget.placeholder != null ? Text(widget.placeholder!) : null,
                  expandableWidth: widget.expandableWidth,
                  expandableHeight: widget.expandableHeight,
                  initialWidth: widget.initialWidth ?? 300,
                  initialHeight: widget.initialHeight ?? 200,
                  onChanged: widget.onChanged,
                  controller: widget.controller,
                  focusNode: _focusNode,
                ).constrained(
                  width: widget.width,
                  height: widget.height,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// FormField wrapper untuk OurbitTextArea
///
/// Widget ini menggabungkan OurbitTextArea dengan FormField untuk
/// integrasi yang mudah dengan form validation.
///
/// ## Penggunaan:
///
/// ```dart
/// Form(
///   onSubmit: (context, values) {
///     // Handle form submission
///   },
///   child: Column(
///     children: [
///       OurbitFormField(
///         fieldKey: const TextFieldKey('description'),
///         label: 'Description',
///         initialValue: 'Enter description',
///         expandableHeight: true,
///         initialHeight: 200,
///         validator: (value) {
///           if (value == null || value.isEmpty) {
///             return 'Description is required';
///           }
///           return null;
///         },
///       ),
///     ],
///   ),
/// )
/// ```
class OurbitFormField extends StatelessWidget {
  final TextFieldKey fieldKey;
  final String? label;
  final String? initialValue;
  final String? placeholder;
  final bool expandableWidth;
  final bool expandableHeight;
  final double? initialWidth;
  final double? initialHeight;
  final List<InputFeature>? features;
  final Set<FormValidationMode>? showErrors;
  final Validator<String>? validator;
  final void Function(String?)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const OurbitFormField({
    super.key,
    required this.fieldKey,
    this.label,
    this.initialValue,
    this.placeholder,
    this.expandableWidth = false,
    this.expandableHeight = false,
    this.initialWidth,
    this.initialHeight,
    this.features,
    this.showErrors,
    this.validator,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return FormField(
      key: fieldKey,
      label: label != null ? Text(label!) : const Text(''),
      showErrors: showErrors,
      validator: validator,
      child: OurbitTextArea(
        initialValue: initialValue,
        placeholder: placeholder,
        expandableWidth: expandableWidth,
        expandableHeight: expandableHeight,
        initialWidth: initialWidth,
        initialHeight: initialHeight,
        features: features,
        onChanged: onChanged,
        controller: controller,
        focusNode: focusNode,
        width: width,
        height: height,
        padding: padding,
        borderRadius: borderRadius,
      ),
    );
  }
}
