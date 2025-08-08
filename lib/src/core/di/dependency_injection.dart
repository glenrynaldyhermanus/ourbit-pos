import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/src/data/repositories/auth_repository_impl.dart';
import 'package:ourbit_pos/src/data/repositories/pos_repository_impl.dart';
import 'package:ourbit_pos/src/data/repositories/management_repository_impl.dart';
import 'package:ourbit_pos/src/data/usecases/add_to_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/clear_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/authenticate_with_token_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_current_user_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_products_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/is_authenticated_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/sign_in_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/sign_out_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/update_cart_quantity_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_user_business_store_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_all_products_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_categories_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_categories_by_store_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_customers_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_suppliers_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_discounts_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_expenses_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_loyalty_programs_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_store_payment_methods_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/process_checkout_usecase.dart';
import 'package:ourbit_pos/blocs/payment_bloc.dart';
import 'package:ourbit_pos/src/core/services/business_store_service.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DependencyInjection {
  // Initialize Supabase client
  static final _supabaseClient = Supabase.instance.client;

  // Initialize repositories
  static final _authRepository = AuthRepositoryImpl(_supabaseClient);
  static final _posRepository = PosRepositoryImpl(_supabaseClient);
  static final _managementRepository =
      ManagementRepositoryImpl(_supabaseClient);

  // Initialize services
  static final _businessStoreService = BusinessStoreService(_supabaseClient);
  static final _themeService = ThemeService();

  // Initialize use cases
  static final _signInUseCase = SignInUseCase(_authRepository);
  static final _signOutUseCase = SignOutUseCase(_authRepository);
  static final _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
  static final _isAuthenticatedUseCase =
      IsAuthenticatedUseCase(_authRepository);
  static final _authenticateWithTokenUseCase =
      AuthenticateWithTokenUseCase(_authRepository);
  static final _getProductsUseCase = GetProductsUseCase(_posRepository);
  static final _getCategoriesByStoreUseCase =
      GetCategoriesByStoreUseCase(_posRepository);
  static final _getCartUseCase = GetCartUseCase(_posRepository);
  static final _addToCartUseCase = AddToCartUseCase(_posRepository);
  static final _updateCartQuantityUseCase =
      UpdateCartQuantityUseCase(_posRepository);
  static final _clearCartUseCase = ClearCartUseCase(_posRepository);
  static final _getStorePaymentMethodsUseCase =
      GetStorePaymentMethodsUseCase(_posRepository);
  static final _processCheckoutUseCase = ProcessCheckoutUseCase(_posRepository);

  // Initialize business store use cases
  static final _getUserBusinessStoreUseCase =
      GetUserBusinessStoreUseCase(_businessStoreService);

  // Initialize management use cases
  static final _getAllProductsUseCase =
      GetAllProductsUseCase(_managementRepository);
  static final _getCategoriesUseCase =
      GetCategoriesUseCase(_managementRepository);
  static final _getCustomersUseCase =
      GetCustomersUseCase(_managementRepository);
  static final _getSuppliersUseCase =
      GetSuppliersUseCase(_managementRepository);
  static final _getDiscountsUseCase =
      GetDiscountsUseCase(_managementRepository);
  static final _getExpensesUseCase = GetExpensesUseCase(_managementRepository);
  static final _getLoyaltyProgramsUseCase =
      GetLoyaltyProgramsUseCase(_managementRepository);

  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<ThemeService>(
        create: (context) => _themeService,
      ),
    ];
  }

  static List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          signInUseCase: _signInUseCase,
          signOutUseCase: _signOutUseCase,
          getCurrentUserUseCase: _getCurrentUserUseCase,
          isAuthenticatedUseCase: _isAuthenticatedUseCase,
          authenticateWithTokenUseCase: _authenticateWithTokenUseCase,
          getUserBusinessStoreUseCase: _getUserBusinessStoreUseCase,
        ),
      ),
      BlocProvider<CashierBloc>(
        create: (context) => CashierBloc(
          getProductsUseCase: _getProductsUseCase,
          getCategoriesByStoreUseCase: _getCategoriesByStoreUseCase,
          getCartUseCase: _getCartUseCase,
          addToCartUseCase: _addToCartUseCase,
          updateCartQuantityUseCase: _updateCartQuantityUseCase,
          clearCartUseCase: _clearCartUseCase,
        ),
      ),
      BlocProvider<ManagementBloc>(
        create: (context) => ManagementBloc(
          getAllProductsUseCase: _getAllProductsUseCase,
          getCategoriesUseCase: _getCategoriesUseCase,
          getCustomersUseCase: _getCustomersUseCase,
          getSuppliersUseCase: _getSuppliersUseCase,
          getDiscountsUseCase: _getDiscountsUseCase,
          getExpensesUseCase: _getExpensesUseCase,
          getLoyaltyProgramsUseCase: _getLoyaltyProgramsUseCase,
        ),
      ),
      BlocProvider<PaymentBloc>(
        create: (context) => PaymentBloc(
          getCartUseCase: _getCartUseCase,
          getStorePaymentMethodsUseCase: _getStorePaymentMethodsUseCase,
          processCheckoutUseCase: _processCheckoutUseCase,
        ),
      ),
    ];
  }
}
