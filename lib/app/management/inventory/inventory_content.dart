import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/table/ourbit_table.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';

class InventoryContent extends StatefulWidget {
  const InventoryContent({super.key});

  @override
  State<InventoryContent> createState() => _InventoryContentState();
}

class _InventoryContentState extends State<InventoryContent> {
  final TextEditingController _searchController = TextEditingController();

  String _searchTerm = '';
  String _sortKey = 'product';
  bool _sortAsc = true;
  int _currentPage = 1;
  int _pageSize = 10;

  List<Product> _cachedInventory = [];
  List<Map<String, dynamic>> _categories = [];
  String _selectedCategoryKey = 'all';
  String _selectedStatusKey = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<ManagementBloc>();
      bloc.add(LoadInventory());
      bloc.add(LoadCategories());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)}.000.000';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  String _computeStatus(Product p) {
    if (p.stock <= 0) return 'out_of_stock';
    if (p.stock <= p.minStock) return 'low_stock';
    return 'in_stock';
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventori',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text('Kelola stok dan lakukan stock opname'),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OurbitButton.primary(
              onPressed: () {},
              label: 'Stock Opname',
              leadingIcon:
                  const Icon(Icons.assignment, size: 16, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: OurbitTextInput(
            controller: _searchController,
            placeholder: 'Cari produk berdasarkan nama/kode/kategori/lokasi',
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
          width: 220,
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
              if (key == 'no-category') return const Text('Tanpa Kategori');
              final found = _categories.firstWhere(
                (c) => c['id'] == key,
                orElse: () => {'name': '-'},
              );
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
        const SizedBox(width: 12),
        SizedBox(
          width: 220,
          child: OurbitSelect<String>(
            value: _selectedStatusKey,
            items: const ['all', 'in_stock', 'low_stock', 'out_of_stock'],
            placeholder: const Text('Semua Status'),
            itemBuilder: (context, key) {
              switch (key) {
                case 'all':
                  return const Text('Semua Status');
                case 'in_stock':
                  return const Text('Stok Normal');
                case 'low_stock':
                  return const Text('Stok Menipis');
                case 'out_of_stock':
                  return const Text('Stok Habis');
                default:
                  return Text(key);
              }
            },
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedStatusKey = value;
                _currentPage = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Column _buildTableSection(List<Product> inventory) {
    return Column(
      children: [
        Consumer<ThemeService>(
          builder: (context, themeService, _) {
            final bool isDark = themeService.isDarkMode;
            final Color borderColor =
                isDark ? const Color(0xff292524) : const Color(0xFFE5E7EB);

            final filteredBySearch = inventory.where((p) {
              if (_searchTerm.isEmpty) return true;
              final name = p.name.toLowerCase();
              final code = (p.code ?? '').toLowerCase();
              final category = (p.categoryName ?? '').toLowerCase();
              final location = (p.rackLocation ?? '').toLowerCase();
              return name.contains(_searchTerm) ||
                  code.contains(_searchTerm) ||
                  category.contains(_searchTerm) ||
                  location.contains(_searchTerm);
            }).toList();

            final filteredByCategory = filteredBySearch.where((p) {
              if (_selectedCategoryKey == 'all') return true;
              if (_selectedCategoryKey == 'no-category')
                return p.categoryId == null;
              return p.categoryId == _selectedCategoryKey;
            }).toList();

            final filteredByStatus = filteredByCategory.where((p) {
              if (_selectedStatusKey == 'all') return true;
              return _computeStatus(p) == _selectedStatusKey;
            }).toList();

            filteredByStatus.sort((a, b) {
              int res = 0;
              switch (_sortKey) {
                case 'product':
                  res = a.name.toLowerCase().compareTo(b.name.toLowerCase());
                  break;
                case 'category':
                  res = (a.categoryName ?? '')
                      .toLowerCase()
                      .compareTo((b.categoryName ?? '').toLowerCase());
                  break;
                case 'stock':
                  res = a.stock.compareTo(b.stock);
                  break;
                case 'purchase_price':
                  res = a.purchasePrice.compareTo(b.purchasePrice);
                  break;
                case 'location':
                  res = (a.rackLocation ?? '')
                      .toLowerCase()
                      .compareTo((b.rackLocation ?? '').toLowerCase());
                  break;
                case 'status':
                  res = _computeStatus(a).compareTo(_computeStatus(b));
                  break;
                default:
                  res = 0;
              }
              return _sortAsc ? res : -res;
            });

            final totalItems = filteredByStatus.length;
            final totalPages =
                (totalItems / _pageSize).ceil().clamp(1, 1 << 31);
            if (_currentPage > totalPages) _currentPage = totalPages;
            final start = (_currentPage - 1) * _pageSize;
            final end = (start + _pageSize).clamp(0, totalItems);
            final pageItems = filteredByStatus.sublist(start, end);

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
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
                        child: Text('Lokasi'),
                        isHeader: true,
                        expanded: false,
                        width: 160,
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
                              OurbitTableCell(
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
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
                                                child: const Icon(Icons.image,
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
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            p.code?.isNotEmpty == true
                                                ? p.code!
                                                : 'Tanpa Kode',
                                            overflow: TextOverflow.ellipsis,
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
                              OurbitTableCell(
                                child: Text(p.categoryName ?? 'Tanpa Kategori'),
                                expanded: false,
                                width: 160,
                              ).build(context),
                              OurbitTableCell(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${p.stock} ${p.unit ?? 'pcs'}'),
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
                              OurbitTableCell(
                                child: Text(p.rackLocation?.isNotEmpty == true
                                    ? p.rackLocation!
                                    : '-'),
                                expanded: false,
                                width: 160,
                              ).build(context),
                              OurbitTableCell(
                                child: Text(_formatCurrency(
                                    p.purchasePrice.toDouble())),
                                alignment: Alignment.centerRight,
                                expanded: false,
                                width: 140,
                              ).build(context),
                              OurbitTableCell(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _statusChip(
                                      context,
                                      label: () {
                                        final s = _computeStatus(p);
                                        if (s == 'in_stock')
                                          return 'Stok Normal';
                                        if (s == 'low_stock')
                                          return 'Stok Menipis';
                                        return 'Stok Habis';
                                      }(),
                                      statusKey: _computeStatus(p),
                                    ),
                                  ],
                                ),
                                expanded: false,
                                width: 180,
                              ).build(context),
                              OurbitTableCell(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OurbitIconButton.ghost(
                                      onPressed: null,
                                      icon: const Icon(Icons.edit, size: 16),
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
                Row(
                  children: [
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
      ],
    );
  }

  Widget _statusChip(BuildContext context,
      {required String label, required String statusKey}) {
    final bool isPositive = statusKey == 'in_stock';
    final bool warning = statusKey == 'low_stock';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading && _cachedInventory.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ManagementError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }

        // Cache data untuk menghindari flicker saat state lain teremit
        List<Product> inventory = [];
        if (state is InventoryLoaded) {
          _cachedInventory = state.inventory;
          inventory = state.inventory;
        } else if (_cachedInventory.isNotEmpty) {
          inventory = _cachedInventory;
        }

        if (inventory.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              const Expanded(
                child: Center(
                  child: Text('Tidak ada data inventori'),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(child: _buildTableSection(inventory)),
          ],
        );
      },
    );
  }
}
