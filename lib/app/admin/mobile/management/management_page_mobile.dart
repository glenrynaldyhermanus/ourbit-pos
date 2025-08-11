import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/app/admin/desktop/management/products/widgets/product_form_sheet.dart';
import 'package:ourbit_pos/app/admin/desktop/management/categories/widgets/category_form_sheet.dart';
import 'package:ourbit_pos/app/admin/desktop/management/customers/widgets/customer_form_sheet.dart';
import 'package:ourbit_pos/app/admin/desktop/management/suppliers/widgets/supplier_form_sheet.dart';
import 'products/products_content_mobile.dart';
import 'inventory/inventory_content_mobile.dart';
import 'categories/categories_content_mobile.dart';
import 'customers/customers_content_mobile.dart';
import 'suppliers/suppliers_content_mobile.dart';
import 'expenses/expenses_content_mobile.dart';
import 'discounts/discounts_content_mobile.dart';
import 'loyalty/loyalty_content_mobile.dart';
import 'taxes/taxes_content_mobile.dart';

class ManagementPageMobile extends material.StatelessWidget {
  const ManagementPageMobile({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    const List<material.Tab> tabs = [
      material.Tab(text: 'Produk'),
      material.Tab(text: 'Inventori'),
      material.Tab(text: 'Kategori'),
      material.Tab(text: 'Pelanggan'),
      material.Tab(text: 'Supplier'),
      material.Tab(text: 'Diskon'),
      material.Tab(text: 'Pajak'),
      material.Tab(text: 'Pengeluaran'),
      material.Tab(text: 'Loyalitas'),
    ];

    return material.DefaultTabController(
      length: tabs.length,
      child: material.Scaffold(
        drawer: const SidebarDrawer(),
        appBar: material.AppBar(
          title: const material.Text('Data'),
          leading: material.Builder(
            builder: (context) => material.IconButton(
              icon: const material.Icon(material.Icons.menu),
              onPressed: () => material.Scaffold.of(context).openDrawer(),
            ),
          ),
          bottom: material.TabBar(
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        body: material.TabBarView(
          children: [
            // Produk
            const ProductsContentMobile(),
            // Inventori
            const InventoryContentMobile(),
            // Kategori
            const CategoriesContentMobile(),
            // Pelanggan
            const CustomersContentMobile(),
            // Supplier
            const SuppliersContentMobile(),
            // Diskon
            const DiscountsContentMobile(),
            // Pajak
            const TaxesContentMobile(),
            // Pengeluaran
            const ExpensesContentMobile(),
            // Loyalitas
            const LoyaltyContentMobile(),
          ],
        ),
        floatingActionButton: material.Builder(
          builder: (fabContext) => material.FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              final controller = material.DefaultTabController.of(fabContext);
              final idx = controller.index;
              switch (idx) {
                case 0: // Produk
                  openSheet(
                    context: fabContext,
                    builder: (c) => const ProductFormSheet(),
                    position: OverlayPosition.bottom,
                  );
                  break;
                case 2: // Kategori
                  openSheet(
                    context: fabContext,
                    builder: (c) => const CategoryFormSheet(),
                    position: OverlayPosition.bottom,
                  );
                  break;
                case 3: // Pelanggan
                  openSheet(
                    context: fabContext,
                    builder: (c) => const CustomerFormSheet(),
                    position: OverlayPosition.bottom,
                  );
                  break;
                case 4: // Supplier
                  openSheet(
                    context: fabContext,
                    builder: (c) => const SupplierFormSheet(),
                    position: OverlayPosition.bottom,
                  );
                  break;
                default:
                  // no-op for tabs without add action
                  break;
              }
            },
            child: const material.Icon(
              material.Icons.add,
              color: material.Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
