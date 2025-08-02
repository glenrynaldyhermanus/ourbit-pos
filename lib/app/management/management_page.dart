import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/app_sidebar.dart';
import 'package:ourbit_pos/src/widgets/ourbit_card.dart';

class ManagementPage extends StatefulWidget {
  final String? selectedMenu;

  const ManagementPage({super.key, this.selectedMenu});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  String _selectedMenu = 'products';

  final List<ManagementMenuItem> _menuItems = [
    ManagementMenuItem(
      id: 'products',
      title: 'Produk',
      icon: Icons.inventory_2_outlined,
      description: 'Kelola daftar produk',
    ),
    ManagementMenuItem(
      id: 'inventory',
      title: 'Inventory',
      icon: Icons.warehouse_outlined,
      description: 'Kelola stok barang',
    ),
    ManagementMenuItem(
      id: 'categories',
      title: 'Kategori',
      icon: Icons.category_outlined,
      description: 'Kelola kategori produk',
    ),
    ManagementMenuItem(
      id: 'customers',
      title: 'Pelanggan',
      icon: Icons.people_outline,
      description: 'Kelola data pelanggan',
    ),
    ManagementMenuItem(
      id: 'suppliers',
      title: 'Supplier',
      icon: Icons.local_shipping_outlined,
      description: 'Kelola data supplier',
    ),
    ManagementMenuItem(
      id: 'discounts',
      title: 'Diskon',
      icon: Icons.local_offer_outlined,
      description: 'Kelola diskon dan promo',
    ),
    ManagementMenuItem(
      id: 'taxes',
      title: 'Pajak',
      icon: Icons.receipt_long_outlined,
      description: 'Pengaturan pajak',
    ),
    ManagementMenuItem(
      id: 'expenses',
      title: 'Biaya',
      icon: Icons.money_off_outlined,
      description: 'Kelola biaya operasional',
    ),
    ManagementMenuItem(
      id: 'loyalty',
      title: 'Loyalty',
      icon: Icons.card_giftcard_outlined,
      description: 'Program loyalitas',
    ),
  ];

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
    if (widget.selectedMenu != null) {
      _selectedMenu = widget.selectedMenu!;
    }
    // Load initial data based on selected menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForSelectedMenu();
    });
  }

  void _loadDataForSelectedMenu() {
    switch (_selectedMenu) {
      case 'inventory':
        context.read<ManagementBloc>().add(LoadInventory());
        break;
      case 'categories':
        context.read<ManagementBloc>().add(LoadCategories());
        break;
      case 'customers':
        context.read<ManagementBloc>().add(LoadCustomers());
        break;
      case 'suppliers':
        context.read<ManagementBloc>().add(LoadSuppliers());
        break;
      case 'discounts':
        context.read<ManagementBloc>().add(LoadDiscounts());
        break;
      case 'expenses':
        context.read<ManagementBloc>().add(LoadExpenses());
        break;
      case 'loyalty':
        context.read<ManagementBloc>().add(LoadLoyaltyPrograms());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.surfaceBackground,
        child: Row(
          children: [
            // Sidebar
            const AppSidebar(),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Page Header
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimaryBackground
                          : AppColors.primaryBackground,
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isDark ? AppColors.darkBorder : AppColors.border,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Management Data',
                          style: _getSystemFont(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => context.go('/pos'),
                          tooltip: 'Kembali ke POS',
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Row(
                      children: [
                        // Left Panel - Menu List
                        Container(
                          width: MediaQuery.of(context).size.width < 1200
                              ? 250
                              : 300,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkPrimaryBackground
                                : AppColors.primaryBackground,
                            border: Border(
                              right: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Menu',
                                  style: _getSystemFont(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount: _menuItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _menuItems[index];
                                    final isSelected = _selectedMenu == item.id;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () {
                                            setState(() {
                                              _selectedMenu = item.id;
                                            });
                                            _loadDataForSelectedMenu();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                      .withValues(alpha: 0.1)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: isSelected
                                                  ? Border.all(
                                                      color: AppColors.primary
                                                          .withValues(
                                                              alpha: 0.3),
                                                      width: 1,
                                                    )
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  item.icon,
                                                  size: 20,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : isDark
                                                          ? AppColors
                                                              .darkSecondaryText
                                                          : AppColors
                                                              .secondaryText,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.title,
                                                        style: _getSystemFont(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: isSelected
                                                              ? AppColors
                                                                  .primary
                                                              : isDark
                                                                  ? AppColors
                                                                      .darkPrimaryText
                                                                  : AppColors
                                                                      .primaryText,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        item.description,
                                                        style: _getSystemFont(
                                                          fontSize: 12,
                                                          color: isDark
                                                              ? AppColors
                                                                  .darkSecondaryText
                                                              : AppColors
                                                                  .secondaryText,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right Panel - Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _buildContent(isDark),
                          ),
                        ),
                      ],
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

  Widget _buildContent(bool isDark) {
    final selectedItem =
        _menuItems.firstWhere((item) => item.id == _selectedMenu);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildContentByMenu(isDark, selectedItem),
          const SizedBox(height: 24), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildContentByMenu(bool isDark, ManagementMenuItem selectedItem) {
    switch (_selectedMenu) {
      case 'products':
        return _buildProductsContent(isDark);
      case 'inventory':
        return _buildInventoryContent(isDark);
      case 'categories':
        return _buildCategoriesContent(isDark);
      case 'customers':
        return _buildCustomersContent(isDark);
      case 'suppliers':
        return _buildSuppliersContent(isDark);
      case 'discounts':
        return _buildDiscountsContent(isDark);
      case 'taxes':
        return _buildTaxesContent(isDark);
      case 'expenses':
        return _buildExpensesContent(isDark);
      case 'loyalty':
        return _buildLoyaltyContent(isDark);
      default:
        return _buildComingSoonContent(isDark, selectedItem);
    }
  }

  Widget _buildProductsContent(bool isDark) {
    return OurbitCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Kelola Produk',
                  style: _getSystemFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kelola daftar produk, harga, stok, dan informasi produk lainnya',
              style: _getSystemFont(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/management/products'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Buka Halaman Produk'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryContent(bool isDark) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ManagementError) {
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
                  'Error loading inventory',
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
                      context.read<ManagementBloc>().add(LoadInventory()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is InventoryLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.warehouse_outlined,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kelola Inventory',
                    style: _getSystemFont(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add new inventory item
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Stok'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Search and Filter
              OurbitCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari produk...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: 'all',
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('Semua Kategori')),
                          DropdownMenuItem(
                              value: 'low', child: Text('Stok Menipis')),
                          DropdownMenuItem(value: 'out', child: Text('Habis')),
                        ],
                        onChanged: (value) {
                          // TODO: Filter inventory
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Inventory Grid
              SizedBox(
                height: 600,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width < 1200 ? 2 : 3,
                    childAspectRatio: 3.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.inventory.length,
                  itemBuilder: (context, index) {
                    final item = state.inventory[index];
                    final stock = item.stock;
                    final minStock = item.minStock;
                    final isLowStock = stock <= minStock;
                    final isOutOfStock = stock == 0;

                    return OurbitCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: _getSystemFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'SKU: ${item.id}',
                                        style: _getSystemFont(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOutOfStock
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : isLowStock
                                            ? Colors.orange
                                                .withValues(alpha: 0.1)
                                            : Colors.green
                                                .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isOutOfStock
                                        ? 'Habis'
                                        : isLowStock
                                            ? 'Menipis'
                                            : 'Tersedia',
                                    style: _getSystemFont(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isOutOfStock
                                          ? Colors.red
                                          : isLowStock
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stok',
                                        style: _getSystemFont(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText,
                                        ),
                                      ),
                                      Text(
                                        stock.toString(),
                                        style: _getSystemFont(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isOutOfStock
                                              ? Colors.red
                                              : isLowStock
                                                  ? Colors.orange
                                                  : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Min. Stok',
                                        style: _getSystemFont(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText,
                                        ),
                                      ),
                                      Text(
                                        minStock.toString(),
                                        style: _getSystemFont(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // TODO: Edit inventory
                                    },
                                    child: const Text('Edit'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isOutOfStock
                                        ? () {
                                            // TODO: Restock
                                          }
                                        : null,
                                    child: const Text('Restock'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCategoriesContent(bool isDark) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ManagementError) {
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
                  'Error loading categories',
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
                      context.read<ManagementBloc>().add(LoadCategories()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is CategoriesLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kelola Kategori',
                    style: _getSystemFont(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add new category
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kategori'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Categories List
              SizedBox(
                height: 600,
                child: ListView.builder(
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final colors = [
                      Colors.orange,
                      Colors.blue,
                      Colors.green,
                      Colors.red,
                      Colors.purple,
                      Colors.teal,
                      Colors.indigo,
                      Colors.grey,
                    ];
                    final color = colors[index % colors.length];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: OurbitCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category['name'] ?? 'Unknown Category',
                                      style: _getSystemFont(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${category['product_count'] ?? 0} produk',
                                      style: _getSystemFont(
                                        fontSize: 14,
                                        color: isDark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Edit category
                                    },
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit Kategori',
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Delete category
                                    },
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Hapus Kategori',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCustomersContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.people_outline,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Kelola Pelanggan',
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add new customer
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pelanggan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Search and Filter
        OurbitCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari pelanggan...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: 'all',
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                    DropdownMenuItem(value: 'active', child: Text('Aktif')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Tidak Aktif')),
                  ],
                  onChanged: (value) {
                    // TODO: Filter customers
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Customers Table
        SizedBox(
          height: 600,
          child: OurbitCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Telepon')),
                  DataColumn(label: Text('Alamat')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Total Transaksi')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: List.generate(10, (index) {
                  final isActive = index % 3 != 0;
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                'P${index + 1}',
                                style: _getSystemFont(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Pelanggan ${index + 1}'),
                          ],
                        ),
                      ),
                      DataCell(Text('pelanggan${index + 1}@email.com')),
                      DataCell(Text(
                          '+62 812-3456-${(index + 1).toString().padLeft(2, '0')}')),
                      DataCell(Text('Jl. Contoh No. ${index + 1}, Jakarta')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isActive ? 'Aktif' : 'Tidak Aktif',
                            style: _getSystemFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text('${(index + 1) * 3}')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // TODO: Edit customer
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: View customer details
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              tooltip: 'Lihat Detail',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuppliersContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Kelola Supplier',
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add new supplier
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Supplier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Suppliers Grid
        SizedBox(
          height: 600,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 1200 ? 1 : 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 8, // Sample data
            itemBuilder: (context, index) {
              final suppliers = [
                {
                  'name': 'PT Sukses Makmur',
                  'contact': 'Budi Santoso',
                  'phone': '+62 812-1111-001',
                  'email': 'budi@suksesmakmur.com'
                },
                {
                  'name': 'CV Maju Jaya',
                  'contact': 'Siti Aminah',
                  'phone': '+62 812-1111-002',
                  'email': 'siti@majujaya.com'
                },
                {
                  'name': 'UD Berkah Abadi',
                  'contact': 'Ahmad Rizki',
                  'phone': '+62 812-1111-003',
                  'email': 'ahmad@berkahabadi.com'
                },
                {
                  'name': 'PT Sejahtera Bersama',
                  'contact': 'Dewi Sartika',
                  'phone': '+62 812-1111-004',
                  'email': 'dewi@sejahterabersama.com'
                },
                {
                  'name': 'CV Mandiri Jaya',
                  'contact': 'Rudi Hartono',
                  'phone': '+62 812-1111-005',
                  'email': 'rudi@mandirijaya.com'
                },
                {
                  'name': 'PT Indah Permai',
                  'contact': 'Nina Safitri',
                  'phone': '+62 812-1111-006',
                  'email': 'nina@indahpermai.com'
                },
                {
                  'name': 'UD Makmur Sejati',
                  'contact': 'Eko Prasetyo',
                  'phone': '+62 812-1111-007',
                  'email': 'eko@makmursejati.com'
                },
                {
                  'name': 'CV Sukses Mandiri',
                  'contact': 'Rina Marlina',
                  'phone': '+62 812-1111-008',
                  'email': 'rina@suksesmandiri.com'
                },
              ];

              final supplier = suppliers[index];

              return OurbitCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supplier['name'] as String,
                                  style: _getSystemFont(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Kontak: ${supplier['contact']}',
                                  style: _getSystemFont(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              // TODO: Handle menu actions
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 16),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                            child: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              supplier['phone'] as String,
                              style: _getSystemFont(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 14,
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              supplier['email'] as String,
                              style: _getSystemFont(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: View supplier details
                              },
                              child: const Text('Detail'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Contact supplier
                              },
                              child: const Text('Kontak'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountsContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.local_offer_outlined,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Kelola Diskon & Promo',
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add new discount
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Diskon'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Discounts List
        SizedBox(
          height: 600,
          child: ListView.builder(
            itemCount: 6, // Sample data
            itemBuilder: (context, index) {
              final discounts = [
                {
                  'name': 'Diskon 10% Semua Produk',
                  'type': 'percentage',
                  'value': 10,
                  'status': 'active',
                  'expires': '2024-12-31'
                },
                {
                  'name': 'Potongan Rp 5.000',
                  'type': 'fixed',
                  'value': 5000,
                  'status': 'active',
                  'expires': '2024-11-30'
                },
                {
                  'name': 'Buy 1 Get 1 Free',
                  'type': 'bogo',
                  'value': 0,
                  'status': 'inactive',
                  'expires': '2024-10-15'
                },
                {
                  'name': 'Diskon 15% Minuman',
                  'type': 'percentage',
                  'value': 15,
                  'status': 'active',
                  'expires': '2024-12-15'
                },
                {
                  'name': 'Potongan Rp 10.000 Min. Belanja Rp 100.000',
                  'type': 'fixed',
                  'value': 10000,
                  'status': 'active',
                  'expires': '2024-11-20'
                },
                {
                  'name': 'Diskon 20% Rokok',
                  'type': 'percentage',
                  'value': 20,
                  'status': 'inactive',
                  'expires': '2024-09-30'
                },
              ];

              final discount = discounts[index];
              final isActive = discount['status'] == 'active';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: OurbitCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_offer,
                            color: isActive ? Colors.green : Colors.grey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                discount['name'] as String,
                                style: _getSystemFont(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      discount['type'] == 'percentage'
                                          ? '${discount['value']}%'
                                          : discount['type'] == 'fixed'
                                              ? 'Rp ${discount['value']}'
                                              : 'BOGO',
                                      style: _getSystemFont(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isActive ? 'Aktif' : 'Tidak Aktif',
                                      style: _getSystemFont(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Berlaku sampai: ${discount['expires']}',
                                style: _getSystemFont(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // TODO: Edit discount
                              },
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Diskon',
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: Toggle discount status
                              },
                              icon: Icon(
                                isActive ? Icons.pause : Icons.play_arrow,
                              ),
                              tooltip: isActive ? 'Nonaktifkan' : 'Aktifkan',
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: Delete discount
                              },
                              icon: const Icon(Icons.delete),
                              tooltip: 'Hapus Diskon',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaxesContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Pengaturan Pajak',
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add new tax rule
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Aturan Pajak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Tax Settings Form
        SizedBox(
          height: 600,
          child: Row(
            children: [
              // Left Panel - Tax Rules
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aturan Pajak',
                      style: _getSystemFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400, // Fixed height for tax rules list
                      child: ListView.builder(
                        itemCount: 4, // Sample data
                        itemBuilder: (context, index) {
                          final taxRules = [
                            {
                              'name': 'PPN 11%',
                              'rate': 11.0,
                              'type': 'percentage',
                              'status': 'active'
                            },
                            {
                              'name': 'PPh 21',
                              'rate': 5.0,
                              'type': 'percentage',
                              'status': 'active'
                            },
                            {
                              'name': 'Pajak Rokok',
                              'rate': 15.0,
                              'type': 'percentage',
                              'status': 'active'
                            },
                            {
                              'name': 'Pajak Minuman',
                              'rate': 10.0,
                              'type': 'percentage',
                              'status': 'inactive'
                            },
                          ];

                          final rule = taxRules[index];
                          final isActive = rule['status'] == 'active';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: OurbitCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.blue.withValues(alpha: 0.1)
                                            : Colors.grey
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.receipt,
                                        color: isActive
                                            ? Colors.blue
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rule['name'] as String,
                                            style: _getSystemFont(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${rule['rate']}%',
                                            style: _getSystemFont(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.darkSecondaryText
                                                  : AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: isActive,
                                      onChanged: (value) {
                                        // TODO: Toggle tax rule status
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        // TODO: Edit tax rule
                                      },
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit Aturan Pajak',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Panel - Tax Configuration
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konfigurasi Pajak',
                      style: _getSystemFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OurbitCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengaturan Umum',
                              style: _getSystemFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pajak Otomatis',
                                        style: _getSystemFont(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Switch(
                                        value: true,
                                        onChanged: (value) {
                                          // TODO: Toggle auto tax
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tampilkan Pajak',
                                        style: _getSystemFont(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Switch(
                                        value: true,
                                        onChanged: (value) {
                                          // TODO: Toggle tax display
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Pembulatan Pajak',
                              style: _getSystemFont(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: 'round',
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'round',
                                    child: Text('Pembulatan ke atas')),
                                DropdownMenuItem(
                                    value: 'floor',
                                    child: Text('Pembulatan ke bawah')),
                                DropdownMenuItem(
                                    value: 'nearest',
                                    child: Text('Pembulatan terdekat')),
                              ],
                              onChanged: (value) {
                                // TODO: Change tax rounding
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Laporan Pajak',
                              style: _getSystemFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Generate tax report
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Unduh Laporan Pajak'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.money_off_outlined,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Kelola Biaya Operasional',
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add new expense
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Biaya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: OurbitCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total Biaya Bulan Ini',
                            style: _getSystemFont(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp 2.450.000',
                        style: _getSystemFont(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OurbitCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.category,
                            color: Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kategori Biaya',
                            style: _getSystemFont(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '8 Kategori',
                        style: _getSystemFont(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OurbitCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Transaksi Bulan Ini',
                            style: _getSystemFont(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '24 Transaksi',
                        style: _getSystemFont(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Expenses Table
        SizedBox(
          height: 600,
          child: OurbitCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Tanggal')),
                  DataColumn(label: Text('Kategori')),
                  DataColumn(label: Text('Deskripsi')),
                  DataColumn(label: Text('Jumlah')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Aksi')),
                ],
                rows: List.generate(10, (index) {
                  final categories = [
                    'Listrik',
                    'Air',
                    'Internet',
                    'Gaji',
                    'Sewa',
                    'Maintenance',
                    'Lainnya'
                  ];
                  final category = categories[index % categories.length];
                  final amount = (index + 1) * 50000 + 100000;
                  final isPaid = index % 3 != 0;

                  return DataRow(
                    cells: [
                      DataCell(Text(
                          '${DateTime.now().day - index}/${DateTime.now().month}/${DateTime.now().year}')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            category,
                            style: _getSystemFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(
                          'Biaya ${category.toLowerCase()} bulan ${DateTime.now().month}')),
                      DataCell(Text(
                          'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}')),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPaid ? 'Lunas' : 'Belum Lunas',
                            style: _getSystemFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // TODO: Edit expense
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              onPressed: () {
                                // TODO: Mark as paid
                              },
                              icon: Icon(
                                isPaid ? Icons.check_circle : Icons.payment,
                                size: 16,
                              ),
                              tooltip: isPaid ? 'Sudah Lunas' : 'Tandai Lunas',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoyaltyContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.card_giftcard_outlined,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Program Loyalitas',
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add new loyalty program
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Program'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Loyalty Programs Grid
        SizedBox(
          height: 600,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 1200 ? 1 : 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 6, // Sample data
            itemBuilder: (context, index) {
              final programs = [
                {
                  'name': 'Member Silver',
                  'points': 100,
                  'discount': 5,
                  'status': 'active',
                  'members': 45
                },
                {
                  'name': 'Member Gold',
                  'points': 500,
                  'discount': 10,
                  'status': 'active',
                  'members': 28
                },
                {
                  'name': 'Member Platinum',
                  'points': 1000,
                  'discount': 15,
                  'status': 'active',
                  'members': 12
                },
                {
                  'name': 'Member Diamond',
                  'points': 2000,
                  'discount': 20,
                  'status': 'active',
                  'members': 5
                },
                {
                  'name': 'Birthday Special',
                  'points': 0,
                  'discount': 25,
                  'status': 'active',
                  'members': 8
                },
                {
                  'name': 'New Member',
                  'points': 50,
                  'discount': 3,
                  'status': 'inactive',
                  'members': 0
                },
              ];

              final program = programs[index];
              final isActive = program['status'] == 'active';

              return OurbitCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.purple.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.card_giftcard,
                              color: isActive ? Colors.purple : Colors.grey,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  program['name'] as String,
                                  style: _getSystemFont(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isActive ? 'Aktif' : 'Tidak Aktif',
                                    style: _getSystemFont(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              // TODO: Handle menu actions
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 16),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'members',
                                child: Row(
                                  children: [
                                    Icon(Icons.people, size: 16),
                                    SizedBox(width: 8),
                                    Text('Lihat Member'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 16),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                            child: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Min. Poin',
                                  style: _getSystemFont(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.secondaryText,
                                  ),
                                ),
                                Text(
                                  '${program['points']}',
                                  style: _getSystemFont(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diskon',
                                  style: _getSystemFont(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.secondaryText,
                                  ),
                                ),
                                Text(
                                  '${program['discount']}%',
                                  style: _getSystemFont(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Member',
                                  style: _getSystemFont(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.secondaryText,
                                  ),
                                ),
                                Text(
                                  '${program['members']}',
                                  style: _getSystemFont(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: View program details
                              },
                              child: const Text('Detail'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Manage members
                              },
                              child: const Text('Kelola'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonContent(bool isDark, ManagementMenuItem item) {
    return OurbitCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 64,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: _getSystemFont(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: _getSystemFont(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Coming Soon',
                style: _getSystemFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagementMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final String description;

  ManagementMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}
