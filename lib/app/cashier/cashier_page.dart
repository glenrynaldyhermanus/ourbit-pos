import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/app/cashier/widgets/pos_cart.dart';
import 'package:ourbit_pos/app/cashier/widgets/pos_header.dart';
import 'package:ourbit_pos/app/cashier/widgets/product_card.dart';
import 'package:ourbit_pos/blocs/cashier_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_event.dart';
import 'package:ourbit_pos/blocs/cashier_state.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/utils/responsive.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/widgets/app_sidebar.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  // Business, Store, and User data
  String _businessName = '';
  String _storeName = '';
  String _cashierName = '';

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

  @override
  void initState() {
    super.initState();
    _loadBusinessAndStoreData();
  }

  Future<void> _loadBusinessAndStoreData() async {
    try {
      // Load business data
      final businessData = await LocalStorageService.getBusinessData();
      if (businessData != null) {
        setState(() {
          _businessName = businessData['name'] ?? 'Unknown Business';
        });
      }

      // Load store data
      final storeData = await LocalStorageService.getStoreData();
      if (storeData != null) {
        setState(() {
          _storeName = storeData['name'] ?? 'Unknown Store';
        });
      }

      // Load user data
      final userData = await LocalStorageService.getUserData();
      if (userData != null) {
        setState(() {
          _cashierName = userData['name'] ?? 'Unknown Cashier';
        });
      }
    } catch (e) {
      //print('Error loading business/store data: $e');
    }
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
    final categories = state.products
        .map((p) => p.categoryName ?? 'Uncategorized')
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<Product> _getFilteredProducts(CashierLoaded state) {
    if (state.selectedCategory == 'all' || state.selectedCategory == 'All') {
      return state.products;
    }

    final filtered = state.products
        .where((p) => p.categoryName == state.selectedCategory)
        .toList();
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<CashierBloc, CashierState>(
      listener: (context, state) {
        if (state is CashierError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<CashierBloc, CashierState>(
        builder: (context, state) {
          if (state is CashierInitial) {
            context.read<CashierBloc>().add(LoadProducts());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CashierLoading) {
            return const Center(
              child: CircularProgressIndicator(),
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
                      fontWeight: FontWeight.w600,
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
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CashierBloc>().add(LoadProducts()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CashierLoaded) {
            return Scaffold(
              body: Container(
                color: isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.surfaceBackground,
                child: Row(
                  children: [
                    // Sidebar - hanya tampil jika bukan web
                    if (!Responsive.isWeb()) const AppSidebar(),
                    // Main Content
                    Expanded(
                      child: Column(
                        children: [
                          // Page Header
                          PosHeader(
                            businessName: _businessName,
                            storeName: _storeName,
                            cashierName: _cashierName,
                          ),
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
                                          // Search and Category Row
                                          Row(
                                            children: [
                                              // Search Field
                                              Expanded(
                                                flex: 2,
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Search Products',
                                                    hintText:
                                                        'Type product name...',
                                                    prefixIcon:
                                                        Icon(Icons.search),
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    context
                                                        .read<CashierBloc>()
                                                        .add(SearchProducts(
                                                            value));
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              // Category Filter
                                              Expanded(
                                                flex: 1,
                                                child: DropdownButtonFormField<
                                                    String>(
                                                  value:
                                                      state.selectedCategory ==
                                                              'all'
                                                          ? 'All'
                                                          : state
                                                              .selectedCategory,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Category',
                                                    border:
                                                        OutlineInputBorder(),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8),
                                                  ),
                                                  isExpanded: true,
                                                  items: _getCategories(state)
                                                      .map((category) {
                                                    return DropdownMenuItem(
                                                      value: category,
                                                      child: Text(
                                                        category,
                                                        style: _getSystemFont(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      context
                                                          .read<CashierBloc>()
                                                          .add(FilterByCategory(
                                                              value));
                                                    }
                                                  },
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
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
