import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/auth_event.dart';
import 'package:ourbit_pos/blocs/auth_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/utils/responsive.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_theme_toggle.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:provider/provider.dart';

class LoginPanel extends StatefulWidget {
  const LoginPanel({super.key});

  @override
  State<LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends State<LoginPanel> with TickerProviderStateMixin {
  // Form keys
  final _usernameKey = const TextFieldKey('username');
  final _passwordKey = const TextFieldKey('password');

  // Text controllers for direct access
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _fadeController;

  // Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    Logger.login('LoginPanel - initState called');

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Setup animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations with fallback
    Logger.login('LoginPanel - Starting animations with fallback');
    _startAnimationsWithFallback();
  }

  void _startAnimations() async {
    try {
      Logger.login('LoginPanel - Starting logo animation');
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _logoController.forward();
        Logger.login('LoginPanel - Logo animation started');

        // Wait for logo animation to complete
        await Future.delayed(const Duration(milliseconds: 500));
        Logger.login('LoginPanel - Logo animation completed');
      }

      Logger.login('LoginPanel - Starting form animation');
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _formController.forward();
        Logger.login('LoginPanel - Form animation started');

        // Wait for form animation to complete
        await Future.delayed(const Duration(milliseconds: 300));
        Logger.login('LoginPanel - Form animation completed');
      }

      Logger.login('LoginPanel - Starting fade animation');
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _fadeController.forward();
        Logger.login('LoginPanel - Fade animation started');

        // Wait for fade animation to complete
        await Future.delayed(const Duration(milliseconds: 200));
        Logger.login('LoginPanel - Fade animation completed');
      }

      Logger.login('LoginPanel - All animations completed');
    } catch (e) {
      Logger.error(' Animation failed: $e');
      // If animation fails, force the form to show
      if (mounted) {
        setState(() {
          // Force rebuild to show form
        });
      }
    }
  }

  void _startAnimationsWithFallback() async {
    try {
      Logger.login('LoginPanel - Starting animations with fallback');
      _startAnimations();
      Logger.login(
          'LoginPanel - Animations with fallback completed successfully');
    } catch (e) {
      Logger.error(' Animation with fallback failed: $e');
      // If all animations fail, force show form after a delay
      if (mounted) {
        Logger.login('LoginPanel - Using fallback, forcing form to show');
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          setState(() {
            // Force rebuild to show form
          });
          Logger.login('LoginPanel - Fallback form display triggered');
        }
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _formController.dispose();
    _fadeController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      OurbitToast.error(
        context: context,
        title: 'Data Tidak Lengkap',
        content: 'Masukkan username dan password',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    context.read<AuthBloc>().add(SignInRequested(
          email: username,
          password: password,
        ));
  }

  @override
  Widget build(BuildContext context) {
    Logger.login('LoginPanel - build method called');
    return BlocListener<AuthBloc, AuthState>(listener: (context, state) {
      if (state is Authenticated) {
        setState(() {
          _isLoading = false;
        });
        context.go('/pos');
      } else if (state is AuthError) {
        setState(() {
          _isLoading = false;
        });

        // Show toast for all errors
        OurbitToast.error(
          context: context,
          title: 'Login Gagal',
          content: state.message,
        );
      } else if (state is AuthLoading) {
        // Hanya set loading jika bukan pengecekan auth status
        if (!state.isCheckingAuth) {
          setState(() {
            _isLoading = true;
          });
        }
      }
    }, child: Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
            constraints: BoxConstraints(
              maxWidth: Responsive.isMobile(context) ? double.infinity : 400,
            ),
            decoration: BoxDecoration(
              color: themeService.isDarkMode
                  ? AppColors.darkSurfaceBackground
                  : AppColors.surfaceBackground,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          Responsive.isMobile(context) ? double.infinity : 400,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section (only show on desktop)
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScaleAnimation.value,
                              child: Transform.rotate(
                                angle: _logoRotationAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.point_of_sale,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const Gap(40),

                        // Title Section (only on mobile)
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Selamat Datang Kembali',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: themeService.isDarkMode
                                        ? AppColors.darkPrimaryText
                                        : AppColors.primaryText,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  'Masuk ke akun Ourbit Kasir Anda',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeService.isDarkMode
                                        ? AppColors.darkSecondaryText
                                        : AppColors.secondaryText,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Gap(32),

                        // Login Form
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Form(
                              onSubmit: (context, values) {
                                _handleLogin();
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Username field
                                      OurbitFormField(
                                        fieldKey: _usernameKey,
                                        label: 'Email',
                                        placeholder: 'Email',
                                        controller: _usernameController,
                                        showErrors: const {
                                          FormValidationMode.changed,
                                          FormValidationMode.submitted
                                        },
                                        onSubmitted: (value) {
                                          // Focus to password field when Enter is pressed
                                          FocusScope.of(context).nextFocus();
                                        },
                                      ),

                                      // Password field
                                      OurbitFormField(
                                        fieldKey: _passwordKey,
                                        label: 'Password',
                                        placeholder: 'Password',
                                        obscureText: !_isPasswordVisible,
                                        controller: _passwordController,
                                        showErrors: const {
                                          FormValidationMode.changed,
                                          FormValidationMode.submitted
                                        },
                                        onSubmitted: (value) {
                                          // Trigger login directly when Enter is pressed
                                          if (!_isLoading) {
                                            _handleLogin();
                                          }
                                        },
                                        features: [
                                          InputFeature.trailing(
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible =
                                                      !_isPasswordVisible;
                                                });
                                              },
                                              icon: Icon(
                                                _isPasswordVisible
                                                    ? LucideIcons.eyeOff
                                                    : LucideIcons.eye,
                                              ),
                                              variance: ButtonVariance.ghost,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ).gap(24),
                                  const Gap(24),
                                  FormErrorBuilder(
                                    builder: (context, errors, child) {
                                      return OurbitButton(
                                        onPressed: errors.isEmpty && !_isLoading
                                            ? _handleLogin
                                            : null,
                                        label: 'Masuk',
                                        isLoading: _isLoading,
                                        trailingIcon: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            '↵',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Gap(32),

                        // Theme Toggle Section
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Center(
                              child: OurbitThemeToggle(
                                size: 40,
                                showTooltip: true,
                                variant: OurbitThemeToggleVariant.ghost,
                              ),
                            ),
                          ),
                        ),

                        const Gap(32),
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    ));
  }
}
