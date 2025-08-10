import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/table/ourbit_table.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/app/management/products/widgets/product_form_sheet.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';

class ProductsContent extends StatefulWidget {
  const ProductsContent({super.key});

  @override
  State<ProductsContent> createState() => _ProductsContentState();
}

class _ProductsContentState extends State<ProductsContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _sortKey = 'name';
  bool _sortAsc = true;
  int _currentPage = 1;
  int _pageSize = 10;
  List<Product> _cachedProducts = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategoryKey = 'all';

  // Sort setter reserved for future interactive header sorting

  String _formatCurrency(double amount) {
    // Mengikuti pola di product_card.dart
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)}.000.000';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}.000';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadProducts());
      context.read<ManagementBloc>().add(LoadCategories());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ManagementError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }

        // Use cached products to avoid UI flicker when other states (e.g., CategoriesLoaded) are emitted
        List<Product> products = [];
        if (state is ProductsLoaded) {
          _cachedProducts = state.products;
          products = state.products;
        } else if (_cachedProducts.isNotEmpty) {
          products = _cachedProducts;
        }

        if (products.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title + actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produk',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Kelola data master produk'),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OurbitButton.primary(
                        onPressed: () {
                          openSheet(
                            context: context,
                            builder: (context) => const ProductFormSheet(),
                            position: OverlayPosition.right,
                          );
                        },
                        label: 'Tambah Produk',
                        leadingIcon: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search and filter row
              Row(
                children: [
                  Expanded(
                    child: OurbitTextInput(
                      controller: _searchController,
                      placeholder:
                          'Cari produk berdasarkan nama/kode/deskripsi',
                      leading: const Icon(Icons.search, size: 16),
                      onChanged: (v) {
                        setState(() {
                          _searchTerm = (v ?? '').trim().toLowerCase();
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 240,
                    child: BlocListener<ManagementBloc, ManagementState>(
                      listenWhen: (prev, curr) => curr is CategoriesLoaded,
                      listener: (context, state) {
                        if (state is CategoriesLoaded) {
                          setState(() {
                            _categories = state.categories;
                          });
                        }
                      },
                      child: OurbitSelect<String>(
                        value: _selectedCategoryKey,
                        items: [
                          'all',
                          'no-category',
                          ..._categories.map((c) => c['id'] as String),
                        ],
                        placeholder: const Text('Semua Kategori'),
                        itemBuilder: (context, key) {
                          if (key == 'all') return const Text('Semua Kategori');
                          if (key == 'no-category')
                            return const Text('Tanpa Kategori');
                          final found = _categories.firstWhere(
                              (c) => c['id'] == key,
                              orElse: () => {'name': '-'});
                          return Text(found['name']?.toString() ?? '-');
                        },
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedCategoryKey = value;
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Table + Pagination
              Expanded(
                child: Consumer<ThemeService>(
                  builder: (context, themeService, _) {
                    final bool isDark = themeService.isDarkMode;
                    final Color borderColor = isDark
                        ? const Color(0xff292524)
                        : const Color(0xFFE5E7EB);
                    // Prepare data: filter, sort, paginate
                    final all = (products).where((p) {
                      if (_searchTerm.isEmpty) return true;
                      final name = p.name.toLowerCase();
                      final code = (p.code ?? '').toLowerCase();
                      final desc = (p.description ?? '').toLowerCase();
                      return name.contains(_searchTerm) ||
                          code.contains(_searchTerm) ||
                          desc.contains(_searchTerm);
                    }).toList();

                    // Category filter
                    final filteredByCategory = all.where((p) {
                      if (_selectedCategoryKey == 'all') return true;
                      if (_selectedCategoryKey == 'no-category') {
                        return p.categoryId == null;
                      }
                      return p.categoryId == _selectedCategoryKey;
                    }).toList();

                    filteredByCategory.sort((a, b) {
                      int res = 0;
                      switch (_sortKey) {
                        case 'name':
                          res = a.name
                              .toLowerCase()
                              .compareTo(b.name.toLowerCase());
                          break;
                        case 'category':
                          res = (a.categoryName ?? '')
                              .toLowerCase()
                              .compareTo((b.categoryName ?? '').toLowerCase());
                          break;
                        case 'stock':
                          res = a.stock.compareTo(b.stock);
                          break;
                        case 'selling_price':
                          res = a.sellingPrice.compareTo(b.sellingPrice);
                          break;
                        case 'purchase_price':
                          res = a.purchasePrice.compareTo(b.purchasePrice);
                          break;
                        case 'stock_value':
                          res = (a.sellingPrice * a.stock)
                              .compareTo(b.sellingPrice * b.stock);
                          break;
                        case 'status':
                          res = a.isActive
                              .toString()
                              .compareTo(b.isActive.toString());
                          break;
                        default:
                          res = 0;
                      }
                      return _sortAsc ? res : -res;
                    });

                    final totalItems = filteredByCategory.length;
                    final totalPages =
                        (totalItems / _pageSize).ceil().clamp(1, 1 << 31);
                    if (_currentPage > totalPages) _currentPage = totalPages;
                    final start = (_currentPage - 1) * _pageSize;
                    final end = (start + _pageSize).clamp(0, totalItems);
                    final pageItems = filteredByCategory.sublist(start, end);

                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: borderColor,
                              width: 0.5,
                            ),
                            borderRadius: Theme.of(context).borderRadiusMd,
                          ),
                          child: OurbitTable(
                            minHeight: 400,
                            scrollable: false,
                            borderRadius: Theme.of(context).borderRadiusMd,
                            borderColor: borderColor,
                            headers: [
                              const OurbitTableCell(
                                child: Text('Produk'),
                                isHeader: true,
                                expanded: false,
                                width: 320,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Kategori'),
                                isHeader: true,
                                expanded: false,
                                width: 160,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Stok'),
                                isHeader: true,
                                expanded: false,
                                width: 140,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Harga Jual'),
                                isHeader: true,
                                alignment: Alignment.centerRight,
                                expanded: false,
                                width: 140,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Harga Beli'),
                                isHeader: true,
                                alignment: Alignment.centerRight,
                                expanded: false,
                                width: 140,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Status'),
                                isHeader: true,
                                expanded: false,
                                width: 180,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text(''),
                                isHeader: true,
                                expanded: false,
                                width: 96,
                              ).build(context),
                            ],
                            rows: pageItems
                                .map(
                                  (p) => TableRow(
                                    cells: [
                                      // Produk (gambar + nama + kode)
                                      OurbitTableCell(
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: p.imageUrl != null
                                                    ? Image.network(
                                                        p.imageUrl!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Container(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .muted,
                                                        child: const Icon(
                                                            Icons.image,
                                                            size: 20),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    p.code?.isNotEmpty == true
                                                        ? p.code!
                                                        : 'Tanpa Kode',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .mutedForeground,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        expanded: false,
                                        width: 320,
                                      ).build(context),

                                      // Kategori
                                      OurbitTableCell(
                                        child: Text(
                                            p.categoryName ?? 'Tanpa Kategori'),
                                        expanded: false,
                                        width: 160,
                                      ).build(context),

                                      // Stok + Min
                                      OurbitTableCell(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${p.stock} ${p.unit ?? 'pcs'}'),
                                            Text(
                                              'Min: ${p.minStock} ${p.unit ?? 'pcs'}',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .mutedForeground,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        expanded: false,
                                        width: 140,
                                      ).build(context),

                                      // Harga Jual
                                      OurbitTableCell(
                                        child: Text(_formatCurrency(
                                            p.sellingPrice.toDouble())),
                                        alignment: Alignment.centerRight,
                                        expanded: false,
                                        width: 140,
                                      ).build(context),

                                      // Harga Beli
                                      OurbitTableCell(
                                        child: Text(_formatCurrency(
                                            p.purchasePrice.toDouble())),
                                        alignment: Alignment.centerRight,
                                        expanded: false,
                                        width: 140,
                                      ).build(context),

                                      // Status badges
                                      OurbitTableCell(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            _buildStatusChip(
                                              context,
                                              label: p.isActive
                                                  ? 'Aktif'
                                                  : 'Nonaktif',
                                              isPositive: p.isActive,
                                            ),
                                            _buildStatusChip(
                                              context,
                                              label: p.stock <= 10
                                                  ? 'Stok Habis'
                                                  : (p.stock <= p.minStock
                                                      ? 'Stok Menipis'
                                                      : 'Stok Normal'),
                                              isPositive: p.stock > p.minStock,
                                              warning: p.stock <= p.minStock &&
                                                  p.stock > 10,
                                            ),
                                          ],
                                        ),
                                        expanded: false,
                                        width: 180,
                                      ).build(context),

                                      // Actions
                                      OurbitTableCell(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            OurbitIconButton.ghost(
                                              onPressed: () {
                                                openSheet(
                                                  context: context,
                                                  builder: (c) =>
                                                      ProductFormSheet(
                                                    item: {
                                                      'id': p.id,
                                                      'name': p.name,
                                                      'code': p.code,
                                                      'category_name':
                                                          p.categoryName,
                                                      'category_id':
                                                          p.categoryId,
                                                      'price': p.sellingPrice,
                                                      'purchase_price':
                                                          p.purchasePrice,
                                                      'stock': p.stock,
                                                      'unit': p.unit,
                                                      'weight_grams':
                                                          p.weightGrams,
                                                      'discount_value':
                                                          p.discountValue,
                                                      'description':
                                                          p.description,
                                                      'min_stock': p.minStock,
                                                      'type': p.type,
                                                      'is_active': p.isActive,
                                                    },
                                                  ),
                                                  position:
                                                      OverlayPosition.right,
                                                );
                                              },
                                              icon: const Icon(Icons.edit,
                                                  size: 16),
                                            ),
                                            const SizedBox(width: 6),
                                            OurbitIconButton.destructive(
                                              onPressed: () async {
                                                final confirmed =
                                                    await OurbitDialog.show(
                                                  context: context,
                                                  title: 'Hapus Produk',
                                                  content:
                                                      'Apakah Anda yakin ingin menghapus "${p.name}"?',
                                                  confirmText: 'Hapus',
                                                  cancelText: 'Batal',
                                                  isDestructive: true,
                                                );
                                                if (confirmed == true &&
                                                    context.mounted) {
                                                  context
                                                      .read<ManagementBloc>()
                                                      .add(DeleteProduct(
                                                          productId: p.id));
                                                }
                                              },
                                              icon: const Icon(Icons.delete,
                                                  size: 16),
                                            ),
                                          ],
                                        ),
                                        expanded: false,
                                        width: 96,
                                      ).build(context),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Pagination controls
                        Row(
                          children: [
                            // Rows per page
                            const Text('Baris per halaman'),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: OurbitSelect<int>(
                                value: _pageSize,
                                items: const [10, 20, 50],
                                itemBuilder: (context, v) => Text('$v'),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() {
                                    _pageSize = v;
                                    _currentPage = 1;
                                  });
                                },
                              ),
                            ),
                            const Spacer(),
                            Text('Halaman $_currentPage dari $totalPages'),
                            const SizedBox(width: 8),
                            OurbitButton.outline(
                              onPressed: _currentPage > 1
                                  ? () => setState(() => _currentPage -= 1)
                                  : null,
                              label: 'Sebelumnya',
                            ),
                            const SizedBox(width: 8),
                            OurbitButton.outline(
                              onPressed: _currentPage < totalPages
                                  ? () => setState(() => _currentPage += 1)
                                  : null,
                              label: 'Berikutnya',
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Tampilkan header + tombol aksi walaupun data kosong
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Kelola data master produk'),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OurbitButton.primary(
                      onPressed: () {
                        openSheet(
                          context: context,
                          builder: (context) => const ProductFormSheet(),
                          position: OverlayPosition.right,
                        );
                      },
                      label: 'Tambah Produk',
                      leadingIcon:
                          const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('Tidak ada data produk'),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildStatusChip(BuildContext context,
    {required String label, required bool isPositive, bool warning = false}) {
  final Color fg = isPositive
      ? Colors.green.shade600
      : (warning ? Colors.yellow.shade700 : Colors.red.shade600);
  final Color bg = isPositive
      ? Colors.green.withValues(alpha: 0.1)
      : (warning
          ? Colors.yellow.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1));
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}
