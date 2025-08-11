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
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CashierPageMobile extends StatefulWidget {
  const CashierPageMobile({super.key});

  @override
  State<CashierPageMobile> createState() => _CashierPageMobileState();
}

class _CashierPageMobileState extends State<CashierPageMobile>
    with material.TickerProviderStateMixin {
  // Keys for fly-to-cart animation
  final GlobalKey _cartIconKey = GlobalKey();
  final Map<String, GlobalKey> _productImageKeys = {};

  // Badge animation
  late final material.AnimationController _badgeController;
  late final material.Animation<double> _badgeScale;
  int _lastItemCount = 0;

  @override
  void initState() {
    super.initState();
    Logger.cashier('CashierPageMobile - initState called');

    _badgeController = material.AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _badgeScale = material.CurvedAnimation(
      parent: _badgeController,
      curve: material.Curves.easeOutBack,
    );

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

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    context
        .read<CashierBloc>()
        .add(AddToCart(productId: product.id, quantity: 1));
  }

  Future<void> _animateAddToCart(GlobalKey fromKey, {String? imageUrl}) async {
    final overlay = material.Overlay.of(context);
    final startContext = fromKey.currentContext;
    final endContext = _cartIconKey.currentContext;
    if (startContext == null || endContext == null) return;

    final startBox = startContext.findRenderObject() as material.RenderBox?;
    final endBox = endContext.findRenderObject() as material.RenderBox?;
    if (startBox == null || endBox == null) return;

    final startPos = startBox.localToGlobal(material.Offset.zero);
    final endPos = endBox.localToGlobal(material.Offset.zero);
    final startSize = startBox.size;
    final endSize = endBox.size;

    final controller = material.AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final curve = material.CurvedAnimation(
      parent: controller,
      curve: material.Curves.easeInOutCubic,
    );

    final entry = material.OverlayEntry(
      builder: (_) {
        final t = curve.value;
        final x = startPos.dx + (endPos.dx - startPos.dx) * t;
        final y = startPos.dy + (endPos.dy - startPos.dy) * t;
        final w =
            (startSize.width + (endSize.width - startSize.width) * t) * 0.5;
        final h =
            (startSize.height + (endSize.height - startSize.height) * t) * 0.5;
        final opacity = 1.0 - (t * 0.2);

        return material.IgnorePointer(
          child: material.Stack(
            children: [
              material.Positioned(
                left: x,
                top: y,
                width: w,
                height: h,
                child: material.Opacity(
                  opacity: opacity,
                  child: material.Material(
                    color: material.Colors.transparent,
                    child: material.ClipRRect(
                      borderRadius:
                          material.BorderRadius.circular(12 * (1 - t) + 16),
                      child: (imageUrl != null && imageUrl.isNotEmpty)
                          ? material.Image.network(imageUrl,
                              fit: material.BoxFit.cover)
                          : material.Container(
                              color: AppColors.secondaryBackground),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(entry);
    await controller.forward();
    entry.remove();
    controller.dispose();
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
          Logger.cashier(
              'CashierPageMobile - Current state: ${state.runtimeType}');

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
                title: const material.Text('Ourbit Kasir'),
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
                title: const material.Text('Ourbit Kasir'),
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
                0,
                (sum, item) =>
                    sum + (item.product.sellingPrice * item.quantity));
            final itemCount =
                cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

            // Trigger badge bounce when count changes
            if (itemCount != _lastItemCount) {
              _badgeController.forward(from: 0);
              _lastItemCount = itemCount;
            }

            return material.Scaffold(
              drawer: const SidebarDrawer(),
              appBar: material.AppBar(
                title: const material.Text('Ourbit Kasir'),
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
                  material.Stack(
                    clipBehavior: material.Clip.none,
                    children: [
                      material.IconButton(
                        key: _cartIconKey,
                        icon: const material.Icon(LucideIcons.shoppingCart),
                        onPressed: () {
                          _showCartBottomSheet(context, cartItems, total);
                        },
                      ),
                      material.Positioned(
                        right: 8,
                        top: 8,
                        child: material.ScaleTransition(
                          scale: _badgeScale,
                          child: material.Container(
                            padding: const material.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: material.BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: material.BorderRadius.circular(12),
                            ),
                            child: material.Text(
                              '$itemCount',
                              style: const material.TextStyle(
                                color: material.Colors.white,
                                fontSize: 11,
                                fontWeight: material.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      padding:
                          const material.EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const material
                          .SliverGridDelegateWithFixedCrossAxisCount(
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
                  material.AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      final offset = material.Tween<material.Offset>(
                        begin: const material.Offset(0, 0.1),
                        end: material.Offset.zero,
                      ).animate(animation);
                      return material.SlideTransition(
                        position: offset,
                        child: material.FadeTransition(
                            opacity: animation, child: child),
                      );
                    },
                    child: cartItems.isNotEmpty
                        ? material.Container(
                            key: const material.ValueKey('bottomBar'),
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
                                    crossAxisAlignment:
                                        material.CrossAxisAlignment.start,
                                    mainAxisSize: material.MainAxisSize.min,
                                    children: [
                                      material.Text(
                                        'Total : $itemCount produk',
                                        style: material.TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText,
                                        ),
                                      ),
                                      material.Text(
                                        'Rp ${total.toStringAsFixed(0).replaceAllMapped(
                                              RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))'),
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
                          )
                        : const material.SizedBox.shrink(),
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
    final currentState = context.read<CashierBloc>().state;
    int quantityInCart = 0;
    if (currentState is CashierLoaded) {
      final existing = currentState.cartItems
          .where((item) => item.product.id == product.id)
          .toList();
      if (existing.isNotEmpty) {
        quantityInCart = existing.first.quantity;
      }
    }

    final imageKey =
        _productImageKeys.putIfAbsent(product.id, () => GlobalKey());

    return material.InkWell(
      onTap: quantityInCart == 0
          ? () {
              _animateAddToCart(imageKey, imageUrl: product.imageUrl);
              _addToCart(product);
            }
          : null,
      borderRadius: material.BorderRadius.circular(12),
      child: OurbitCard(
        padding: const material.EdgeInsets.all(12),
        child: material.Column(
          crossAxisAlignment: material.CrossAxisAlignment.start,
          children: [
            // Product Image
            material.Expanded(
              child: material.Container(
                key: imageKey,
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

            if (quantityInCart > 0) ...[
              const material.SizedBox(height: 8),
              material.Center(
                child: material.Container(
                  decoration: material.BoxDecoration(
                    border: material.Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 0.5,
                    ),
                    borderRadius: material.BorderRadius.circular(12),
                  ),
                  padding: const material.EdgeInsets.symmetric(horizontal: 6),
                  child: material.Row(
                    mainAxisSize: material.MainAxisSize.min,
                    children: [
                      material.SizedBox(
                        width: 36,
                        height: 36,
                        child: material.IconButton(
                          padding: material.EdgeInsets.zero,
                          constraints: const material.BoxConstraints(),
                          icon: const material.Icon(material.Icons.remove),
                          onPressed: () {
                            final newQty = quantityInCart - 1;
                            context.read<CashierBloc>().add(
                                  UpdateCartQuantity(
                                    productId: product.id,
                                    quantity: newQty,
                                  ),
                                );
                          },
                        ),
                      ),
                      material.Padding(
                        padding:
                            const material.EdgeInsets.symmetric(horizontal: 8),
                        child: material.AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          transitionBuilder: (child, animation) =>
                              material.ScaleTransition(
                                  scale: animation, child: child),
                          child: material.Text(
                            '$quantityInCart',
                            key: material.ValueKey<int>(quantityInCart),
                            style: const material.TextStyle(
                              fontWeight: material.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      material.SizedBox(
                        width: 36,
                        height: 36,
                        child: material.IconButton(
                          padding: material.EdgeInsets.zero,
                          constraints: const material.BoxConstraints(),
                          icon: const material.Icon(material.Icons.add),
                          onPressed: () {
                            final newQty = quantityInCart + 1;
                            context.read<CashierBloc>().add(
                                  UpdateCartQuantity(
                                    productId: product.id,
                                    quantity: newQty,
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
      builder: (context) => BlocBuilder<CashierBloc, CashierState>(
        builder: (context, state) {
          final items = state is CashierLoaded ? state.cartItems : <dynamic>[];

          return material.Container(
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
                      const material.Icon(LucideIcons.shoppingCart),
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
                    padding:
                        const material.EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isDark = material.Theme.of(context).brightness ==
                          material.Brightness.dark;
                      return OurbitCard(
                        padding: const material.EdgeInsets.all(12),
                        child: material.Row(
                          crossAxisAlignment:
                              material.CrossAxisAlignment.center,
                          children: [
                            material.Expanded(
                              child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                mainAxisSize: material.MainAxisSize.min,
                                children: [
                                  material.Text(
                                    item.product.name,
                                    style: const material.TextStyle(
                                      fontWeight: material.FontWeight.w600,
                                    ),
                                  ),
                                  const material.SizedBox(height: 4),
                                  material.Text(
                                    'Rp ${item.product.sellingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '${m[1]}.')}',
                                  ),
                                ],
                              ),
                            ),
                            material.Container(
                              decoration: material.BoxDecoration(
                                border: material.Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.border,
                                  width: 0.5,
                                ),
                                borderRadius:
                                    material.BorderRadius.circular(12),
                              ),
                              padding: const material.EdgeInsets.symmetric(
                                  horizontal: 6),
                              child: material.Row(
                                mainAxisSize: material.MainAxisSize.min,
                                children: [
                                  material.SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: material.IconButton(
                                      padding: material.EdgeInsets.zero,
                                      constraints:
                                          const material.BoxConstraints(),
                                      icon: const material.Icon(
                                          material.Icons.remove),
                                      onPressed: () => _updateQuantity(
                                          index, item.quantity - 1),
                                    ),
                                  ),
                                  material.Padding(
                                    padding:
                                        const material.EdgeInsets.symmetric(
                                            horizontal: 8),
                                    child: material.AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      transitionBuilder: (child, animation) =>
                                          material.ScaleTransition(
                                              scale: animation, child: child),
                                      child: material.Text(
                                        '${item.quantity}',
                                        key: material.ValueKey<int>(
                                            item.quantity),
                                        style: const material.TextStyle(
                                          fontWeight: material.FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  material.SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: material.IconButton(
                                      padding: material.EdgeInsets.zero,
                                      constraints:
                                          const material.BoxConstraints(),
                                      icon: const material.Icon(
                                          material.Icons.add),
                                      onPressed: () => _updateQuantity(
                                          index, item.quantity + 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
          );
        },
      ),
    );
  }
}
