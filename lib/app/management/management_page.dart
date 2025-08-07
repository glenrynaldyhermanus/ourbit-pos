import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/src/widgets/navigation/sidebar.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'widgets/management_menu_widget.dart';
import 'products/products_content.dart';
import 'inventory/inventory_content.dart';
import 'categories/categories_content.dart';
import 'customers/customers_content.dart';
import 'suppliers/suppliers_content.dart';
import 'discounts/discounts_content.dart';
import 'taxes/taxes_content.dart';
import 'expenses/expenses_content.dart';
import 'loyalty/loyalty_content.dart';

class ManagementPage extends StatefulWidget {
  final String? selectedMenu;

  const ManagementPage({super.key, this.selectedMenu});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  String _selectedMenu = 'products';

  final List<ManagementMenuItem> _menuItems = const [
    ManagementMenuItem(
      id: 'products',
      title: 'Produk',
      icon: LucideIcons.shoppingBasket,
      description: 'Kelola barang dan jasa toko kamu',
    ),
    ManagementMenuItem(
      id: 'inventory',
      title: 'Inventory',
      icon: LucideIcons.warehouse,
      description: 'Kelola stok barang',
    ),
    ManagementMenuItem(
      id: 'categories',
      title: 'Kategori',
      icon: LucideIcons.archive,
      description: 'Kelola kategori barang dan jasa',
    ),
    ManagementMenuItem(
      id: 'customers',
      title: 'Pelanggan',
      icon: LucideIcons.userRound,
      description: 'Kelola data pemilik hewan',
    ),
    ManagementMenuItem(
      id: 'suppliers',
      title: 'Supplier',
      icon: LucideIcons.truck,
      description: 'Kelola data supplier',
    ),
    ManagementMenuItem(
      id: 'discounts',
      title: 'Diskon',
      icon: LucideIcons.tag,
      description: 'Kelola diskon dan promo',
    ),
    ManagementMenuItem(
      id: 'taxes',
      title: 'Pajak',
      icon: LucideIcons.scrollText,
      description: 'Pengaturan pajak barang dan jasa',
    ),
    ManagementMenuItem(
      id: 'expenses',
      title: 'Biaya',
      icon: LucideIcons.banknote,
      description: 'Kelola biaya operasional toko',
    ),
    ManagementMenuItem(
      id: 'loyalty',
      title: 'Loyalty',
      icon: LucideIcons.gift,
      description: 'Program loyalitas pelanggan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedMenu != null) {
      _selectedMenu = widget.selectedMenu!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Row(
        children: [
          // Sidebar
          const Sidebar(),

          // Main content
          Expanded(
            child: Column(
              children: [
                // AppBar
                const AppBar(),

                // Content
                Expanded(
                  child: BlocBuilder<ManagementBloc, ManagementState>(
                    builder: (context, state) {
                      if (state is ManagementMenuSelected) {
                        _selectedMenu = state.selectedMenu;
                      }

                      return Row(
                        children: [
                          // Menu Panel
                          Container(
                            width: 300,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.gray.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ManagementMenuWidget(
                              menuItems: _menuItems,
                              initialSelectedMenu: _selectedMenu,
                              onMenuSelected: (menuId) {
                                context.read<ManagementBloc>().add(
                                      SelectManagementMenu(menuId: menuId),
                                    );
                              },
                            ),
                          ),

                          // Content Panel
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              child: _buildContent(_selectedMenu),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'products':
        return const ProductsContent();
      case 'inventory':
        return const InventoryContent();
      case 'categories':
        return const CategoriesContent();
      case 'customers':
        return const CustomersContent();
      case 'suppliers':
        return const SuppliersContent();
      case 'discounts':
        return const DiscountsContent();
      case 'taxes':
        return const TaxesContent();
      case 'expenses':
        return const ExpensesContent();
      case 'loyalty':
        return const LoyaltyContent();
      default:
        return Container();
    }
  }
}
