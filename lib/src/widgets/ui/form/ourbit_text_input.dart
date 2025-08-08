import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

/// Custom Text Input Widget dengan efek shrink animation saat focus
///
/// Widget ini memberikan feedback visual yang subtle saat user focus pada text field.
/// Menggunakan animasi shrink (scale 0.98) dengan duration 200ms dan curve easeInOut.
///
/// ## Fitur:
/// - ✅ Shrink animation saat focus
/// - ✅ Support semua fitur TextField shadcn_flutter
/// - ✅ Form validation integration
/// - ✅ Customizable styling
/// - ✅ Focus management
/// - ✅ Leading dan trailing widgets
///
/// ## Penggunaan:
///
/// ```dart
/// // Basic usage
/// OurbitTextInput(
///   placeholder: 'Enter your name',
///   onChanged: (value) => print(value),
/// )
///
/// // With leading icon
/// OurbitTextInput(
///   placeholder: 'Search products',
///   leading: Icon(Icons.search),
///   onChanged: (value) => print(value),
/// )
///
/// // With leading and trailing widgets
/// OurbitTextInput(
///   placeholder: 'Enter amount',
///   leading: Icon(Icons.attach_money),
///   features: [
///     InputFeature.trailing(
///       IconButton(
///         onPressed: () => print('Clear'),
///         icon: Icon(Icons.clear),
///       ),
///     ),
///   ],
/// )
///
/// // With form validation
/// OurbitFormField(
///   fieldKey: const TextFieldKey('username'),
///   label: 'Username',
///   placeholder: 'Enter username',
///   leading: Icon(Icons.person),
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Username is required';
///     }
///     return null;
///   },
/// )
///
/// // With password visibility toggle
/// OurbitFormField(
///   fieldKey: const TextFieldKey('password'),
///   label: 'Password',
///   placeholder: 'Enter password',
///   leading: Icon(Icons.lock),
///   obscureText: !_isPasswordVisible,
///   features: [
///     InputFeature.trailing(
///       IconButton(
///         onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
///         icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
///       ),
///     ),
///   ],
/// )
/// ```
class OurbitTextInput extends StatefulWidget {
  final String? placeholder;
  final String? label;
  final bool obscureText;
  final List<InputFeature>? features;
  final Widget? leading;
  final TextFieldKey? fieldKey;
  final FormValidationMode? showErrors;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSubmitted;
  final void Function(bool)? onFocusChange;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const OurbitTextInput({
    super.key,
    this.placeholder,
    this.label,
    this.obscureText = false,
    this.features,
    this.leading,
    this.fieldKey,
    this.showErrors,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChange,
    this.controller,
    this.focusNode,
    this.width,
    this.height = 44,
    this.padding,
    this.borderRadius,
  });

  @override
  State<OurbitTextInput> createState() => _OurbitTextInputState();
}

class _OurbitTextInputState extends State<OurbitTextInput>
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
                child: TextField(
                  key: widget.fieldKey,
                  placeholder:
                      widget.placeholder != null ? Text(widget.placeholder!) : null,
                  obscureText: widget.obscureText,
                  features: [
                    if (widget.leading != null)
                      InputFeature.leading(widget.leading!),
                    ...?widget.features,
                  ],
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  controller: widget.controller,
                  focusNode: _focusNode,
                ).constrained(
                  height: widget.height ?? 44,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// FormField wrapper untuk OurbitTextInput
///
/// Widget ini menggabungkan OurbitTextInput dengan FormField untuk
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
///         fieldKey: const TextFieldKey('email'),
///         label: 'Email',
///         placeholder: 'Enter your email',
///         leading: Icon(Icons.email),
///         validator: (value) {
///           if (value == null || value.isEmpty) {
///             return 'Email is required';
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
  final String? placeholder;
  final bool obscureText;
  final List<InputFeature>? features;
  final Widget? leading;
  final Set<FormValidationMode>? showErrors;
  final Validator<String>? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSubmitted;
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
    this.placeholder,
    this.obscureText = false,
    this.features,
    this.leading,
    this.showErrors,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.width,
    this.height = 44,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
                  return FormField(
            key: fieldKey,
            label: label != null 
                ? Text(
                    label!,
                    style: TextStyle(
                      color: themeService.isDarkMode 
                          ? Colors.white
                          : AppColors.primaryText,
                    ),
                  ) 
                : const Text(''),
          showErrors: showErrors,
          validator: validator,
          child: OurbitTextInput(
            placeholder: placeholder,
            obscureText: obscureText,
            features: features,
            leading: leading,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            controller: controller,
            focusNode: focusNode,
            width: width,
            height: height,
            padding: padding,
            borderRadius: borderRadius,
          ),
        );
      },
    );
  }
}
