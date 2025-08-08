import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/app/cashier/widgets/pos_cart.dart';
import 'package:ourbit_pos/app/cashier/widgets/product_card.dart';
import 'package:ourbit_pos/app/cashier/widgets/product_skeleton.dart';
import 'package:ourbit_pos/app/cashier/widgets/cart_skeleton.dart';
import 'package:ourbit_pos/blocs/cashier_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_event.dart';
import 'package:ourbit_pos/blocs/cashier_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/utils/responsive.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/widgets/navigation/sidebar.dart';
import 'package:ourbit_pos/src/widgets/navigation/appbar.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  // Helper function untuk menggunakan system font
  TextStyle _getSystemFont({
    required double fontSize,
    material.FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  void initState() {
    super.initState();
    print('DEBUG: CashierPage - initState called');
    // Debug: Check stored data when cashier page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG: CashierPage - Post frame callback executed');
      LocalStorageService.debugStoredData();

      // Reset CashierBloc to ensure fresh data for new user
      print('DEBUG: CashierPage - Resetting CashierBloc');

      // Check if store ID is correct for current user
      LocalStorageService.getStoreId().then((storeId) {
        print('DEBUG: CashierPage - Current store ID: $storeId');
      });

      context.read<CashierBloc>().add(ResetCashier());
    });
  }

  void _addToCart(Product product) {
    context
        .read<CashierBloc>()
        .add(AddToCart(productId: product.id, quantity: 1));
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      // Remove item from cart
      final currentState = context.read<CashierBloc>().state;
      if (currentState is CashierLoaded &&
          index < currentState.cartItems.length) {
        final item = currentState.cartItems[index];
        context.read<CashierBloc>().add(UpdateCartQuantity(
              productId: item.product.id,
              quantity: 0,
            ));
      }
    } else {
      final currentState = context.read<CashierBloc>().state;
      if (currentState is CashierLoaded &&
          index < currentState.cartItems.length) {
        final item = currentState.cartItems[index];
        context.read<CashierBloc>().add(UpdateCartQuantity(
              productId: item.product.id,
              quantity: newQuantity,
            ));
      }
    }
  }

  void _clearCart() {
    context.read<CashierBloc>().add(ClearCart());
  }

  void _processPayment() {
    final currentState = context.read<CashierBloc>().state;
    if (currentState is CashierLoaded && currentState.cartItems.isNotEmpty) {
      // Navigate to payment page instead of showing dialog
      context.go('/payment');
    }
  }

  List<String> _getCategories(CashierLoaded state) {
    final categories =
        state.categories.map((c) => c['name'] as String).toList();
    categories.insert(0, 'Semua Kategori');
    return categories;
  }

  List<String> _getProductTypes(CashierLoaded state) {
    final types = state.productTypes.map((t) => t['value'] as String).toList();
    types.insert(0, 'Semua Tipe');
    return types;
  }

  String _getProductTypeKey(CashierLoaded state, String typeValue) {
    final type = state.productTypes.firstWhere(
      (t) => t['value'] == typeValue,
      orElse: () => {'key': '', 'value': ''},
    );
    return type['key'] as String;
  }

  List<Product> _getFilteredProducts(CashierLoaded state) {
    var filtered = state.products;

    // Filter by category
    if (state.selectedCategory != 'all' &&
        state.selectedCategory != 'Semua Kategori') {
      filtered = filtered
          .where((p) => p.categoryName == state.selectedCategory)
          .toList();
    }

    // Filter by type
    if (state.selectedType != 'all' && state.selectedType != 'Semua Tipe') {
      final typeKey = _getProductTypeKey(state, state.selectedType);
      filtered = filtered.where((p) => p.type == typeKey).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == material.Brightness.dark;

    return BlocListener<CashierBloc, CashierState>(
      listener: (context, state) {
        if (state is CashierError) {
          OurbitToast.error(
            context: context,
            title: 'Error',
            content: state.message,
          );
        }
      },
      child: BlocBuilder<CashierBloc, CashierState>(
        builder: (context, state) {
          print('DEBUG: CashierPage - Current state: ${state.runtimeType}');

          if (state is CashierInitial) {
            print(
                'DEBUG: CashierPage - State is CashierInitial, calling LoadProducts');
            // Add a small delay to ensure data is properly stored
            Future.delayed(const Duration(milliseconds: 100), () {
              print('DEBUG: CashierPage - Delayed LoadProducts call');
              context.read<CashierBloc>().add(LoadProducts());
            });
            return const Center(child: OurbitCircularProgress());
          }

          if (state is CashierLoading) {
            return Scaffold(
              child: Container(
                color: isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.surfaceBackground,
                child: Row(
                  children: [
                    // Sidebar - hanya tampil jika bukan web
                    if (!Responsive.isWeb()) const Sidebar(),
                    // Main Content
                    Expanded(
                      child: Column(
                        children: [
                          // Page Header
                          const OurbitAppBar(),
                          // Content
                          Expanded(
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    // Products Section with Skeleton
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Search and Category Row Skeleton
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? AppColors
                                                            .darkSecondaryBackground
                                                        : AppColors
                                                            .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                              const Gap(16),
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? AppColors
                                                            .darkSecondaryBackground
                                                        : AppColors
                                                            .secondaryBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          // Products Grid Skeleton
                                          const Expanded(
                                            child: ProductSkeleton(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Cart Section with Skeleton
                                    const Expanded(
                                      flex: 1,
                                      child: CartSkeleton(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CashierError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: _getSystemFont(
                      fontSize: 18,
                      fontWeight: material.FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: _getSystemFont(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OurbitButton.primary(
                    onPressed: () =>
                        context.read<CashierBloc>().add(LoadProducts()),
                    label: 'Retry',
                  ),
                ],
              ),
            );
          }

          if (state is CashierLoaded) {
            return Scaffold(
              child: Container(
                color: isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.surfaceBackground,
                child: Row(
                  children: [
                    // Sidebar - hanya tampil jika bukan web
                    if (!Responsive.isWeb()) const Sidebar(),
                    // Main Content
                    Expanded(
                      child: Column(
                        children: [
                          // Page Header
                          const OurbitAppBar(),
                          // Content
                          Expanded(
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    // Products Section
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Search and Filters Row
                                          Row(
                                            children: [
                                              // Search Field
                                              Expanded(
                                                flex: 2,
                                                child: OurbitTextInput(
                                                  placeholder:
                                                      'Cari nama produk...',
                                                  label: 'Search Products',
                                                  leading:
                                                      const Icon(Icons.search),
                                                  onChanged: (value) {
                                                    context
                                                        .read<CashierBloc>()
                                                        .add(SearchProducts(
                                                            value ?? ''));
                                                  },
                                                ),
                                              ),
                                              const Gap(16),
                                              // Category Filter
                                              Expanded(
                                                flex: 1,
                                                child: OurbitSelect<String>(
                                                  value:
                                                      state.selectedCategory ==
                                                              'all'
                                                          ? 'Semua Kategori'
                                                          : state
                                                              .selectedCategory,
                                                  items: _getCategories(state),
                                                  itemBuilder:
                                                      (context, category) =>
                                                          Text(category),
                                                  onChanged: (category) {
                                                    if (category != null) {
                                                      context
                                                          .read<CashierBloc>()
                                                          .add(FilterByCategory(
                                                              category));
                                                    }
                                                  },
                                                  placeholder: const Text(
                                                      'Pilih Kategori'),
                                                ),
                                              ),
                                              const Gap(16),
                                              // Type Filter
                                              Expanded(
                                                flex: 1,
                                                child: OurbitSelect<String>(
                                                  value: state.selectedType ==
                                                          'all'
                                                      ? 'Semua Tipe'
                                                      : state.selectedType,
                                                  items:
                                                      _getProductTypes(state),
                                                  itemBuilder:
                                                      (context, type) =>
                                                          Text(type),
                                                  onChanged: (type) {
                                                    if (type != null) {
                                                      context
                                                          .read<CashierBloc>()
                                                          .add(FilterByType(
                                                              type));
                                                    }
                                                  },
                                                  placeholder: const Text(
                                                      'Pilih Tipe Produk'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          // Products Grid
                                          Expanded(
                                            child: Builder(
                                              builder: (context) {
                                                final filteredProducts =
                                                    _getFilteredProducts(state);

                                                if (filteredProducts.isEmpty) {
                                                  return Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .inventory_2_outlined,
                                                          size: 64,
                                                          color: isDark
                                                              ? AppColors
                                                                  .darkSecondaryText
                                                              : AppColors
                                                                  .secondaryText,
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Text(
                                                          'No products found',
                                                          style: _getSystemFont(
                                                            fontSize: 18,
                                                            fontWeight: material
                                                                .FontWeight
                                                                .w600,
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkSecondaryText
                                                                : AppColors
                                                                    .secondaryText,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Try adjusting your search or filter',
                                                          style: _getSystemFont(
                                                            fontSize: 14,
                                                            color: isDark
                                                                ? AppColors
                                                                    .darkSecondaryText
                                                                : AppColors
                                                                    .secondaryText,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }

                                                return GridView.builder(
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 4,
                                                    childAspectRatio: 1.1,
                                                    crossAxisSpacing: 16,
                                                    mainAxisSpacing: 16,
                                                  ),
                                                  itemCount:
                                                      filteredProducts.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final product =
                                                        filteredProducts[index];
                                                    return ProductCard(
                                                      product: product,
                                                      onTap: () =>
                                                          _addToCart(product),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Cart Section
                                    Expanded(
                                      flex: 1,
                                      child: PosCart(
                                        state: state,
                                        onClearCart: _clearCart,
                                        onUpdateQuantity: _updateQuantity,
                                        onProcessPayment: _processPayment,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: OurbitCircularProgress(),
          );
        },
      ),
    );
  }
}
