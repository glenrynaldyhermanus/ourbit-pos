import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/app/admin/desktop/management/categories/widgets/category_form_sheet.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/table/ourbit_table.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CategoriesContent extends StatefulWidget {
  const CategoriesContent({super.key});

  @override
  State<CategoriesContent> createState() => _CategoriesContentState();
}

class _CategoriesContentState extends State<CategoriesContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _sortKey = 'name';
  bool _sortAsc = true;
  int _currentPage = 1;
  int _pageSize = 10;
  List<Map<String, dynamic>> _cachedCategories = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

        // Build from cached + latest state to avoid flicker
        List<Map<String, dynamic>> categories = [];
        if (state is CategoriesLoaded) {
          _cachedCategories = state.categories;
          categories = state.categories;
        } else if (_cachedCategories.isNotEmpty) {
          categories = _cachedCategories;
        }

        if (categories.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Kelola kategori produk toko Anda'),
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
                            builder: (c) => const CategoryFormSheet(),
                            position: OverlayPosition.right,
                          );
                        },
                        label: 'Tambah Kategori',
                        leadingIcon: const Icon(Icons.add,
                            size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search
              Row(
                children: [
                  Expanded(
                    child: OurbitTextInput(
                      controller: _searchController,
                      placeholder:
                          'Cari kategori berdasarkan nama atau deskripsi...',
                      leading: const Icon(Icons.search, size: 16),
                      onChanged: (v) {
                        setState(() {
                          _searchTerm = (v ?? '').trim().toLowerCase();
                          _currentPage = 1;
                        });
                      },
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

                    // Filter + sort + paginate
                    final filtered = categories.where((c) {
                      if (_searchTerm.isEmpty) return true;
                      final name = (c['name'] ?? '').toString().toLowerCase();
                      final desc =
                          (c['description'] ?? '').toString().toLowerCase();
                      return name.contains(_searchTerm) ||
                          desc.contains(_searchTerm);
                    }).toList();

                    filtered.sort((a, b) {
                      int res = 0;
                      switch (_sortKey) {
                        case 'name':
                          res = (a['name'] ?? '')
                              .toString()
                              .toLowerCase()
                              .compareTo(
                                  (b['name'] ?? '').toString().toLowerCase());
                          break;
                        case 'product_count':
                          res = ((a['product_count'] ?? 0) as int)
                              .compareTo((b['product_count'] ?? 0) as int);
                          break;
                        case 'created_at':
                          final da = DateTime.tryParse(
                                  (a['created_at'] ?? '').toString()) ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          final db = DateTime.tryParse(
                                  (b['created_at'] ?? '').toString()) ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          res = da.compareTo(db);
                          break;
                        default:
                          res = 0;
                      }
                      return _sortAsc ? res : -res;
                    });

                    final totalItems = filtered.length;
                    final totalPages =
                        (totalItems / _pageSize).ceil().clamp(1, 1 << 31);
                    if (_currentPage > totalPages) _currentPage = totalPages;
                    final start = (_currentPage - 1) * _pageSize;
                    final end = (start + _pageSize).clamp(0, totalItems);
                    final pageItems = filtered.sublist(start, end);

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
                                child: Text('Kategori'),
                                isHeader: true,
                                expanded: false,
                                width: 360,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Jumlah Produk'),
                                isHeader: true,
                                expanded: false,
                                width: 160,
                              ).build(context),
                              const OurbitTableCell(
                                child: Text('Dibuat'),
                                isHeader: true,
                                expanded: false,
                                width: 160,
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
                                  (c) => TableRow(
                                    cells: [
                                      OurbitTableCell(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: const Center(
                                                child: Icon(Icons.grid_view,
                                                    size: 18,
                                                    color: Colors.orange),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (c['name'] ?? '-')
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    (c['description'] ??
                                                            'Tanpa deskripsi')
                                                        .toString(),
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
                                        width: 360,
                                      ).build(context),
                                      OurbitTableCell(
                                        child: Text(
                                            '${c['product_count'] ?? 0} produk'),
                                        expanded: false,
                                        width: 160,
                                      ).build(context),
                                      OurbitTableCell(
                                        child:
                                            Text(_formatDate(c['created_at'])),
                                        expanded: false,
                                        width: 160,
                                      ).build(context),
                                      OurbitTableCell(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            OurbitIconButton.ghost(
                                              onPressed: () {
                                                openSheet(
                                                  context: context,
                                                  builder: (ctx) =>
                                                      CategoryFormSheet(
                                                    category: c,
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
                                                final count =
                                                    (c['product_count'] ?? 0)
                                                        as int;
                                                if (count > 0) {
                                                  showToast(
                                                    context: context,
                                                    builder:
                                                        (context, overlay) =>
                                                            SurfaceCard(
                                                      child: Basic(
                                                        title: const Text(
                                                            'Tidak dapat menghapus'),
                                                        content: Text(
                                                            'Kategori "${c['name']}" masih memiliki $count produk'),
                                                        trailing: OurbitButton
                                                            .primary(
                                                          onPressed: () =>
                                                              overlay.close(),
                                                          label: 'Tutup',
                                                        ),
                                                      ),
                                                    ),
                                                    location:
                                                        ToastLocation.topCenter,
                                                  );
                                                  return;
                                                }

                                                final confirmed =
                                                    await OurbitDialog.show(
                                                  context: context,
                                                  title: 'Hapus Kategori',
                                                  content:
                                                      'Apakah Anda yakin ingin menghapus "${c['name']}"?',
                                                  confirmText: 'Hapus',
                                                  cancelText: 'Batal',
                                                  isDestructive: true,
                                                );
                                                if (confirmed == true &&
                                                    context.mounted) {
                                                  context
                                                      .read<ManagementBloc>()
                                                      .add(DeleteCategory(
                                                          categoryId:
                                                              (c['id'] ?? '')
                                                                  .toString()));
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
              ),
            ],
          );
        }

        return const Center(
          child: Text('Tidak ada data kategori'),
        );
      },
    );
  }
}

String _formatDate(dynamic value) {
  try {
    final date =
        value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  } catch (_) {
    return '-';
  }
}
