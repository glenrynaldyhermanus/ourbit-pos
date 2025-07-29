import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:ourbit_pos/src/data/usecases/get_current_store_id_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_current_business_id_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/has_valid_business_store_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_business_stores_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/switch_store_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_all_products_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_categories_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_customers_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_suppliers_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_discounts_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_expenses_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_loyalty_programs_usecase.dart';
import 'package:ourbit_pos/src/core/services/business_store_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DependencyInjection {
  static List<BlocProvider> getProviders() {
    // Initialize Supabase client
    final supabaseClient = Supabase.instance.client;

    // Initialize repositories
    final authRepository = AuthRepositoryImpl(supabaseClient);
    final posRepository = PosRepositoryImpl(supabaseClient);
    final managementRepository = ManagementRepositoryImpl(supabaseClient);

    // Initialize services
    final businessStoreService = BusinessStoreService(supabaseClient);

    // Initialize use cases
    final signInUseCase = SignInUseCase(authRepository);
    final signOutUseCase = SignOutUseCase(authRepository);
    final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
    final isAuthenticatedUseCase = IsAuthenticatedUseCase(authRepository);
    final authenticateWithTokenUseCase =
        AuthenticateWithTokenUseCase(authRepository);
    final getProductsUseCase = GetProductsUseCase(posRepository);
    final getCartUseCase = GetCartUseCase(posRepository);
    final addToCartUseCase = AddToCartUseCase(posRepository);
    final updateCartQuantityUseCase = UpdateCartQuantityUseCase(posRepository);
    final clearCartUseCase = ClearCartUseCase(posRepository);

    // Initialize business store use cases
    final getUserBusinessStoreUseCase =
        GetUserBusinessStoreUseCase(businessStoreService);
    final getCurrentStoreIdUseCase =
        GetCurrentStoreIdUseCase(businessStoreService);
    final getCurrentBusinessIdUseCase =
        GetCurrentBusinessIdUseCase(businessStoreService);
    final hasValidBusinessStoreUseCase =
        HasValidBusinessStoreUseCase(businessStoreService);
    final getBusinessStoresUseCase =
        GetBusinessStoresUseCase(businessStoreService);
    final switchStoreUseCase = SwitchStoreUseCase(businessStoreService);

    // Initialize management use cases
    final getAllProductsUseCase = GetAllProductsUseCase(managementRepository);
    final getCategoriesUseCase = GetCategoriesUseCase(managementRepository);
    final getCustomersUseCase = GetCustomersUseCase(managementRepository);
    final getSuppliersUseCase = GetSuppliersUseCase(managementRepository);
    final getDiscountsUseCase = GetDiscountsUseCase(managementRepository);
    final getExpensesUseCase = GetExpensesUseCase(managementRepository);
    final getLoyaltyProgramsUseCase =
        GetLoyaltyProgramsUseCase(managementRepository);

    return [
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          signInUseCase: signInUseCase,
          signOutUseCase: signOutUseCase,
          getCurrentUserUseCase: getCurrentUserUseCase,
          isAuthenticatedUseCase: isAuthenticatedUseCase,
          authenticateWithTokenUseCase: authenticateWithTokenUseCase,
          getUserBusinessStoreUseCase: getUserBusinessStoreUseCase,
        ),
      ),
      BlocProvider<CashierBloc>(
        create: (context) => CashierBloc(
          getProductsUseCase: getProductsUseCase,
          getCartUseCase: getCartUseCase,
          addToCartUseCase: addToCartUseCase,
          updateCartQuantityUseCase: updateCartQuantityUseCase,
          clearCartUseCase: clearCartUseCase,
        ),
      ),
      BlocProvider<ManagementBloc>(
        create: (context) => ManagementBloc(
          getAllProductsUseCase: getAllProductsUseCase,
          getCategoriesUseCase: getCategoriesUseCase,
          getCustomersUseCase: getCustomersUseCase,
          getSuppliersUseCase: getSuppliersUseCase,
          getDiscountsUseCase: getDiscountsUseCase,
          getExpensesUseCase: getExpensesUseCase,
          getLoyaltyProgramsUseCase: getLoyaltyProgramsUseCase,
        ),
      ),
    ];
  }
}
