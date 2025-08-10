// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/table/ourbit_table.dart';
import 'package:ourbit_pos/app/organization/stores/widgets/store_form_sheet.dart';

class StoresContent extends StatefulWidget {
  const StoresContent({super.key});

  @override
  State<StoresContent> createState() => _StoresContentState();
}

class _StoresContentState extends State<StoresContent> {
  final TextEditingController _searchController = TextEditingController();

  String _searchTerm = '';
  String _sortKey = 'name';
  bool _sortAsc = true;
  int _currentPage = 1;
  int _pageSize = 10;

  String? _businessId;
  bool _loading = false;
  List<Map<String, dynamic>> _stores = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final idValue = businessData?['id'];
      _businessId = idValue is String ? idValue : (idValue?.toString());
      await _loadStores();
    } catch (e) {
      Logger.error('STORES_INIT_ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStores() async {
    if (_businessId == null || _businessId!.isEmpty) {
      Logger.error('STORES_LOAD: businessId null/empty');
      setState(() => _stores = []);
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('stores')
          .select()
          .eq('business_id', _businessId as Object);
      final list = (res as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
      setState(() => _stores = list);
    } catch (e) {
      Logger.error('STORES_LOAD_ERROR: $e');
      setState(() => _stores = []);
    }
  }

  Future<void> _deleteStore(String id, String name) async {
    final confirmed = await OurbitDialog.show(
      context: context,
      title: 'Hapus Toko',
      content: 'Apakah Anda yakin ingin menghapus "$name"?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await Supabase.instance.client.from('stores').delete().eq('id', id);
      await _loadStores();
      if (!mounted) return;
      showToast(
        context: context,
        builder: (ctx, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Berhasil'),
            content: Text('Toko "$name" berhasil dihapus'),
            trailing: OurbitButton.primary(
              onPressed: () => overlay.close(),
              label: 'Tutup',
            ),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('DELETE_STORE_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter + sort + paginate
        final filtered = _stores.where((s) {
          if (_searchTerm.isEmpty) return true;
          final name = (s['name'] ?? '').toString().toLowerCase();
          final address = (s['address'] ?? '').toString().toLowerCase();
          final field = (s['business_field'] ?? '').toString().toLowerCase();
          return name.contains(_searchTerm) ||
              address.contains(_searchTerm) ||
              field.contains(_searchTerm);
        }).toList();

        filtered.sort((a, b) {
          int res = 0;
          switch (_sortKey) {
            case 'name':
              res = (a['name'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b['name'] ?? '').toString().toLowerCase());
              break;
            case 'type':
              res = (a['is_branch'] == true ? 'cab' : 'pus') // simple ordering
                  .compareTo(b['is_branch'] == true ? 'cab' : 'pus');
              break;
            case 'currency':
              res = (a['currency'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo((b['currency'] ?? '').toString().toLowerCase());
              break;
            default:
              res = 0;
          }
          return _sortAsc ? res : -res;
        });

        final totalItems = filtered.length;
        final totalPages = (totalItems / _pageSize).ceil().clamp(1, 1 << 31);
        if (_currentPage > totalPages) _currentPage = totalPages;
        final start = (_currentPage - 1) * _pageSize;
        final end = (start + _pageSize).clamp(0, totalItems);
        final pageItems = filtered.sublist(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toko',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Kelola data toko dan cabang'),
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
                          builder: (c) => StoreFormSheet(
                            businessId: _businessId,
                          ),
                          position: OverlayPosition.right,
                        );
                      },
                      label: 'Tambah',
                      leadingIcon:
                          const Icon(Icons.add, size: 16, color: Colors.white),
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
                        'Cari toko berdasarkan nama/alamat/bidang usaha',
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
                              child: Text('Toko'),
                              isHeader: true,
                              expanded: false,
                              width: 280,
                            ).build(context),
                            const OurbitTableCell(
                              child: Text('Alamat'),
                              isHeader: true,
                              expanded: true,
                            ).build(context),
                            const OurbitTableCell(
                              child: Text('Telepon'),
                              isHeader: true,
                              expanded: false,
                              width: 160,
                            ).build(context),
                            const OurbitTableCell(
                              child: Text('Tipe'),
                              isHeader: true,
                              expanded: false,
                              width: 120,
                            ).build(context),
                            const OurbitTableCell(
                              child: Text('Mata Uang'),
                              isHeader: true,
                              expanded: false,
                              width: 120,
                            ).build(context),
                            const OurbitTableCell(
                              child: Text(''),
                              isHeader: true,
                              expanded: false,
                              width: 96,
                            ).build(context),
                          ],
                          rows: pageItems
                              .map((s) => TableRow(cells: [
                                    // Toko
                                    OurbitTableCell(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (s['name'] ?? '-') as String,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            (s['business_field'] ?? '-')
                                                .toString(),
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
                                      expanded: false,
                                      width: 280,
                                    ).build(context),
                                    // Alamat
                                    OurbitTableCell(
                                      child: Text(
                                        (s['address'] ?? '-') as String,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      expanded: true,
                                    ).build(context),
                                    // Telepon
                                    OurbitTableCell(
                                      child: Text(
                                          '${s['phone_country_code'] ?? ''} ${s['phone_number'] ?? ''}'),
                                      expanded: false,
                                      width: 160,
                                    ).build(context),
                                    // Tipe
                                    OurbitTableCell(
                                      child: _typeChip(
                                          context, s['is_branch'] == true),
                                      expanded: false,
                                      width: 120,
                                    ).build(context),
                                    // Mata Uang
                                    OurbitTableCell(
                                      child: Text(
                                        (s['currency'] ?? '-') as String,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      expanded: false,
                                      width: 120,
                                    ).build(context),
                                    // Aksi
                                    OurbitTableCell(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OurbitIconButton.ghost(
                                            onPressed: () {
                                              openSheet(
                                                context: context,
                                                builder: (c) => StoreFormSheet(
                                                  businessId: _businessId,
                                                  store: s,
                                                ),
                                                position: OverlayPosition.right,
                                              );
                                            },
                                            icon: const Icon(Icons.edit,
                                                size: 16),
                                          ),
                                          const SizedBox(width: 6),
                                          OurbitIconButton.destructive(
                                            onPressed: () => _deleteStore(
                                                (s['id'] ?? '').toString(),
                                                (s['name'] ?? '-') as String),
                                            icon: const Icon(Icons.delete,
                                                size: 16),
                                          ),
                                        ],
                                      ),
                                      expanded: false,
                                      width: 96,
                                    ).build(context),
                                  ]))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Pagination controls
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
      },
    );
  }

  Widget _typeChip(BuildContext context, bool isBranch) {
    final Color fg = isBranch ? Colors.green.shade600 : Colors.blue.shade600;
    final Color bg = isBranch
        ? Colors.green.withValues(alpha: 0.1)
        : Colors.blue.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isBranch ? 'Cabang' : 'Pusat',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
