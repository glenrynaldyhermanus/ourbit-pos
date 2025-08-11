import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/blocs/cashier_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_event.dart';
import 'package:ourbit_pos/blocs/cashier_state.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CashierPageMobile extends StatefulWidget {
  const CashierPageMobile({super.key});

  @override
  State<CashierPageMobile> createState() => _CashierPageMobileState();
}

class _CashierPageMobileState extends State<CashierPageMobile> {
  @override
  void initState() {
    super.initState();
    Logger.cashier('CashierPageMobile - initState called');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Logger.cashier('CashierPageMobile - Post frame callback executed');
      LocalStorageService.debugStoredData();

      Logger.cashier('CashierPageMobile - Resetting CashierBloc');

      LocalStorageService.getStoreId().then((storeId) {
        Logger.cashier('CashierPageMobile - Current store ID: $storeId');
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

    if (state.selectedCategory != 'all' &&
        state.selectedCategory != 'Semua Kategori') {
      filtered = filtered
          .where((p) => p.categoryName == state.selectedCategory)
          .toList();
    }

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
          Logger.cashier('CashierPageMobile - Current state: ${state.runtimeType}');

          if (state is CashierInitial) {
            Logger.cashier(
                'CashierPageMobile - State is CashierInitial, calling LoadProducts');
            final cashierBloc = context.read<CashierBloc>();
            Future.delayed(const Duration(milliseconds: 100), () {
              Logger.cashier('CashierPageMobile - Delayed LoadProducts call');
              cashierBloc.add(LoadProducts());
            });
            return const material.Scaffold(
              body: material.Center(child: OurbitCircularProgress()),
            );
          }

          if (state is CashierLoading) {
            return material.Scaffold(
              drawer: const SidebarDrawer(),
              appBar: material.AppBar(
                title: const material.Text('POS'),
                backgroundColor: isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.surfaceBackground,
                leading: Builder(
                  builder: (context) => material.IconButton(
                    icon: const material.Icon(material.Icons.menu),
                    onPressed: () => material.Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              body: const material.Center(child: OurbitCircularProgress()),
            );
          }

          if (state is CashierError) {
            return material.Scaffold(
              drawer: const SidebarDrawer(),
              appBar: material.AppBar(
                title: const material.Text('POS'),
                backgroundColor: isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.surfaceBackground,
                leading: Builder(
                  builder: (context) => material.IconButton(
                    icon: const material.Icon(material.Icons.menu),
                    onPressed: () => material.Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              body: material.Center(
                child: material.Column(
                  mainAxisAlignment: material.MainAxisAlignment.center,
                  children: [
                    const material.Icon(
                      material.Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const material.SizedBox(height: 16),
                    material.Text(
                      'Error loading data',
                      style: material.TextStyle(
                        fontSize: 18,
                        fontWeight: material.FontWeight.w600,
                      ),
                    ),
                    const material.SizedBox(height: 8),
                    material.Text(
                      state.message,
                      style: material.TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
                      ),
                    ),
                    const material.SizedBox(height: 24),
                    OurbitButton.primary(
                      onPressed: () =>
                          context.read<CashierBloc>().add(LoadProducts()),
                      label: 'Coba Lagi',
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CashierLoaded) {
            final cartItems = state.cartItems;
                          final total = cartItems.fold<double>(
                  0, (sum, item) => sum + (item.product.sellingPrice * item.quantity));

            return material.Scaffold(
              drawer: const SidebarDrawer(),
              appBar: material.AppBar(
                title: const material.Text('POS'),
                backgroundColor: isDark
                    ? AppColors.darkSurfaceBackground
                    : AppColors.surfaceBackground,
                leading: Builder(
                  builder: (context) => material.IconButton(
                    icon: const material.Icon(material.Icons.menu),
                    onPressed: () => material.Scaffold.of(context).openDrawer(),
                  ),
                ),
                actions: [
                  if (cartItems.isNotEmpty)
                    material.IconButton(
                      icon: const material.Icon(material.Icons.shopping_cart),
                      onPressed: () {
                        _showCartBottomSheet(context, cartItems, total);
                      },
                    ),
                ],
              ),
              body: material.Column(
                children: [
                  // Search and Filters
                  material.Container(
                    padding: const material.EdgeInsets.all(16),
                    child: material.Column(
                      children: [
                        // Search Field
                        OurbitTextInput(
                          placeholder: 'Cari nama produk...',
                          label: 'Cari Produk',
                          leading: const material.Icon(material.Icons.search),
                          onChanged: (value) {
                            context
                                .read<CashierBloc>()
                                .add(SearchProducts(value ?? ''));
                          },
                        ),
                        const material.SizedBox(height: 12),
                        // Filters Row
                        material.Row(
                          children: [
                            // Category Filter
                            Expanded(
                              child: OurbitSelect<String>(
                                value: state.selectedCategory == 'all'
                                    ? 'Semua Kategori'
                                    : state.selectedCategory,
                                items: _getCategories(state),
                                itemBuilder: (context, category) =>
                                    material.Text(category),
                                onChanged: (category) {
                                  if (category != null) {
                                    context
                                        .read<CashierBloc>()
                                        .add(FilterByCategory(category));
                                  }
                                },
                                placeholder: const material.Text('Kategori'),
                              ),
                            ),
                            const material.SizedBox(width: 8),
                            // Type Filter
                            Expanded(
                              child: OurbitSelect<String>(
                                value: state.selectedType == 'all'
                                    ? 'Semua Tipe'
                                    : state.selectedType,
                                items: _getProductTypes(state),
                                itemBuilder: (context, type) =>
                                    material.Text(type),
                                onChanged: (type) {
                                  if (type != null) {
                                    context
                                        .read<CashierBloc>()
                                        .add(FilterByType(type));
                                  }
                                },
                                placeholder: const material.Text('Tipe'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Products Grid
                  Expanded(
                    child: material.GridView.builder(
                      padding: const material.EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const material.SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _getFilteredProducts(state).length,
                      itemBuilder: (context, index) {
                        final product = _getFilteredProducts(state)[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
                  
                  // Bottom Action Bar
                  if (cartItems.isNotEmpty)
                    material.Container(
                      padding: const material.EdgeInsets.all(16),
                      decoration: material.BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceBackground
                            : AppColors.surfaceBackground,
                        border: material.Border(
                          top: material.BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                      ),
                      child: material.Row(
                        children: [
                          material.Expanded(
                            child: material.Column(
                              crossAxisAlignment: material.CrossAxisAlignment.start,
                              mainAxisSize: material.MainAxisSize.min,
                              children: [
                                material.Text(
                                  'Total:',
                                  style: material.TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.secondaryText,
                                  ),
                                ),
                                material.Text(
                                  'Rp ${total.toStringAsFixed(0).replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (Match m) => '${m[1]}.',
                                  )}',
                                  style: material.TextStyle(
                                    fontSize: 18,
                                    fontWeight: material.FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OurbitButton.primary(
                            onPressed: _processPayment,
                            label: 'Bayar',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }

          return const material.Scaffold(
            body: material.Center(child: OurbitCircularProgress()),
          );
        },
      ),
    );
  }

  material.Widget _buildProductCard(Product product) {
    final isDark = Theme.of(context).brightness == material.Brightness.dark;
    
    return material.Card(
      child: material.InkWell(
        onTap: () => _addToCart(product),
        borderRadius: material.BorderRadius.circular(12),
        child: material.Padding(
          padding: const material.EdgeInsets.all(12),
          child: material.Column(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              // Product Image
              material.Expanded(
                child: material.Container(
                  width: double.infinity,
                  decoration: material.BoxDecoration(
                    borderRadius: material.BorderRadius.circular(8),
                    color: isDark
                        ? AppColors.darkSecondaryBackground
                        : AppColors.secondaryBackground,
                  ),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? material.ClipRRect(
                          borderRadius: material.BorderRadius.circular(8),
                          child: material.Image.network(
                            product.imageUrl!,
                            fit: material.BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const material.Icon(
                              material.Icons.image,
                              size: 48,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        )
                      : const material.Icon(
                          material.Icons.image,
                          size: 48,
                          color: AppColors.secondaryText,
                        ),
                ),
              ),
              const material.SizedBox(height: 8),
              
              // Product Name
              material.Text(
                product.name,
                style: material.TextStyle(
                  fontWeight: material.FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: material.TextOverflow.ellipsis,
              ),
              const material.SizedBox(height: 4),
              
              // Product Price
              material.Text(
                                 'Rp ${product.sellingPrice.toStringAsFixed(0).replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]}.',
                )}',
                style: material.TextStyle(
                  fontSize: 16,
                  fontWeight: material.FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCartBottomSheet(
    material.BuildContext context,
    List<dynamic> cartItems,
    double total,
  ) {
    material.showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: material.Colors.transparent,
      builder: (context) => material.Container(
        height: material.MediaQuery.of(context).size.height * 0.7,
        decoration: const material.BoxDecoration(
          color: material.Colors.white,
          borderRadius: material.BorderRadius.vertical(
            top: material.Radius.circular(20),
          ),
        ),
        child: material.Column(
          children: [
            // Handle
            material.Container(
              margin: const material.EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: material.BoxDecoration(
                color: material.Colors.grey[300],
                borderRadius: material.BorderRadius.circular(2),
              ),
            ),
            
            // Header
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.Row(
                children: [
                  const material.Icon(material.Icons.shopping_cart),
                  const material.SizedBox(width: 8),
                  const material.Text(
                    'Keranjang',
                    style: material.TextStyle(
                      fontSize: 18,
                      fontWeight: material.FontWeight.bold,
                    ),
                  ),
                  const material.Spacer(),
                  material.TextButton(
                    onPressed: () {
                      _clearCart();
                      material.Navigator.of(context).pop();
                    },
                    child: const material.Text('Kosongkan'),
                  ),
                ],
              ),
            ),
            
            const material.Divider(),
            
            // Cart Items
            material.Expanded(
              child: material.ListView.builder(
                padding: const material.EdgeInsets.symmetric(horizontal: 16),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return material.Card(
                    margin: const material.EdgeInsets.only(bottom: 8),
                    child: material.ListTile(
                      leading: material.CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: material.Text(
                          item.product.name[0].toUpperCase(),
                          style: const material.TextStyle(
                            color: AppColors.primary,
                            fontWeight: material.FontWeight.bold,
                          ),
                        ),
                      ),
                      title: material.Text(
                        item.product.name,
                        style: const material.TextStyle(
                          fontWeight: material.FontWeight.w600,
                        ),
                      ),
                      subtitle: material.Text(
                                                 'Rp ${item.product.sellingPrice.toStringAsFixed(0).replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        )}',
                      ),
                      trailing: material.Row(
                        mainAxisSize: material.MainAxisSize.min,
                        children: [
                          material.IconButton(
                            icon: const material.Icon(material.Icons.remove),
                            onPressed: () => _updateQuantity(index, item.quantity - 1),
                          ),
                          material.Text(
                            '${item.quantity}',
                            style: const material.TextStyle(
                              fontWeight: material.FontWeight.bold,
                            ),
                          ),
                          material.IconButton(
                            icon: const material.Icon(material.Icons.add),
                            onPressed: () => _updateQuantity(index, item.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Total and Checkout
            material.Container(
              padding: const material.EdgeInsets.all(16),
              decoration: material.BoxDecoration(
                border: material.Border(
                  top: material.BorderSide(
                    color: material.Colors.grey[300]!,
                  ),
                ),
              ),
              child: material.Row(
                children: [
                  material.Expanded(
                    child: material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      mainAxisSize: material.MainAxisSize.min,
                      children: [
                        const material.Text(
                          'Total:',
                          style: material.TextStyle(
                            fontSize: 14,
                            color: material.Colors.grey,
                          ),
                        ),
                        material.Text(
                          'Rp ${total.toStringAsFixed(0).replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]}.',
                          )}',
                          style: const material.TextStyle(
                            fontSize: 20,
                            fontWeight: material.FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OurbitButton.primary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      _processPayment();
                    },
                    label: 'Bayar',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
