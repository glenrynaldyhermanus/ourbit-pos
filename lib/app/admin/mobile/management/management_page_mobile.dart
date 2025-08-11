import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
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
      ),
    );
  }


}
