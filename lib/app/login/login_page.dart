import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/auth_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/utils/responsive.dart';
import 'package:ourbit_pos/app/login/widgets/product_panel.dart';
import 'package:ourbit_pos/app/login/widgets/login_panel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    print('DEBUG: LoginPage - initState called');
    // Don't call CheckAuthStatus here to avoid infinite loop
    // The router will handle authentication check
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.go('/pos');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          print('DEBUG: LoginPage - Building scaffold');
          return Scaffold(
            backgroundColor: themeService.isDarkMode
                ? AppColors.darkSurfaceBackground
                : AppColors.surfaceBackground,
            body: Row(
              children: [
                // Left Panel - Promo & Products (3/4 width on desktop, hidden on mobile)
                if (!Responsive.isMobile(context))
                  const Expanded(
                    flex: 3,
                    child: ProductPanel(),
                  ),

                // Right Panel - Login Form (1/4 width on desktop, full width on mobile)
                const Expanded(
                  child: LoginPanel(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
