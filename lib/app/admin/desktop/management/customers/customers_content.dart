import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/app/admin/desktop/management/customers/widgets/customer_form_sheet.dart';
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

class CustomersContent extends StatefulWidget {
  const CustomersContent({super.key});

  @override
  State<CustomersContent> createState() => _CustomersContentState();
}

class _CustomersContentState extends State<CustomersContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  String _sortKey = 'name';
  bool _sortAsc = true;
  int _currentPage = 1;
  int _pageSize = 10;
  List<Map<String, dynamic>> _cachedCustomers = [];

  String _formatCurrency(num amount) {
    final double value = amount.toDouble();
    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(0)}.000.000';
    } else if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)}.000';
    } else {
      return 'Rp ${value.toStringAsFixed(0)}';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadCustomers());
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
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ManagementError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        // Pakai cache untuk hindari flicker saat state lain emit
        List<Map<String, dynamic>> customers = [];
        if (state is CustomersLoaded) {
          _cachedCustomers = state.customers;
          customers = state.customers;
        } else if (_cachedCustomers.isNotEmpty) {
          customers = _cachedCustomers;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pelanggan',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('Kelola data pelanggan'),
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
                          builder: (context) => const CustomerFormSheet(),
                          position: OverlayPosition.right,
                        );
                      },
                      label: 'Tambah Pelanggan',
                      leadingIcon:
                          const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search bar
            Row(
              children: [
                Expanded(
                  child: OurbitTextInput(
                    controller: _searchController,
                    placeholder:
                        'Cari pelanggan berdasarkan nama/email/telepon',
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

            // Table + Pagination / Empty state
            Expanded(
              child: customers.isEmpty
                  ? const Center(child: Text('Belum ada pelanggan'))
                  : Consumer<ThemeService>(
                      builder: (context, themeService, _) {
                        final bool isDark = themeService.isDarkMode;
                        final Color borderColor = isDark
                            ? const Color(0xff292524)
                            : const Color(0xFFE5E7EB);

                        // Filter by search
                        final filtered = customers.where((c) {
                          if (_searchTerm.isEmpty) return true;
                          final name =
                              (c['name'] ?? '').toString().toLowerCase();
                          final email =
                              (c['email'] ?? '').toString().toLowerCase();
                          final phone =
                              (c['phone'] ?? '').toString().toLowerCase();
                          return name.contains(_searchTerm) ||
                              email.contains(_searchTerm) ||
                              phone.contains(_searchTerm);
                        }).toList();

                        // Sort
                        filtered.sort((a, b) {
                          int res = 0;
                          switch (_sortKey) {
                            case 'name':
                              res = (a['name'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .compareTo((b['name'] ?? '')
                                      .toString()
                                      .toLowerCase());
                              break;
                            case 'customer_type':
                              res = (a['customer_type'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .compareTo((b['customer_type'] ?? '')
                                      .toString()
                                      .toLowerCase());
                              break;
                            case 'credit_limit':
                              final na = (a['credit_limit'] ?? 0) as num;
                              final nb = (b['credit_limit'] ?? 0) as num;
                              res = na.compareTo(nb);
                              break;
                            case 'payment_terms':
                              final pa = (a['payment_terms'] ?? 0) as num;
                              final pb = (b['payment_terms'] ?? 0) as num;
                              res = pa.compareTo(pb);
                              break;
                            case 'status':
                              res = ((a['is_active'] ?? true) ? 1 : 0)
                                  .compareTo(
                                      ((b['is_active'] ?? true) ? 1 : 0));
                              break;
                            default:
                              res = 0;
                          }
                          return _sortAsc ? res : -res;
                        });

                        // Pagination
                        final totalItems = filtered.length;
                        final totalPages =
                            (totalItems / _pageSize).ceil().clamp(1, 1 << 31);
                        if (_currentPage > totalPages)
                          _currentPage = totalPages;
                        final start = (_currentPage - 1) * _pageSize;
                        final end = (start + _pageSize).clamp(0, totalItems);
                        final pageItems = filtered.sublist(start, end);

                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: borderColor, width: 0.5),
                                borderRadius: Theme.of(context).borderRadiusMd,
                              ),
                              child: OurbitTable(
                                minHeight: 400,
                                scrollable: false,
                                borderRadius: Theme.of(context).borderRadiusMd,
                                borderColor: borderColor,
                                headers: [
                                  const OurbitTableCell(
                                    child: Text('Pelanggan'),
                                    isHeader: true,
                                    expanded: false,
                                    width: 320,
                                  ).build(context),
                                  const OurbitTableCell(
                                    child: Text('Kontak'),
                                    isHeader: true,
                                    expanded: false,
                                    width: 220,
                                  ).build(context),
                                  const OurbitTableCell(
                                    child: Text('Tipe'),
                                    isHeader: true,
                                    expanded: false,
                                    width: 140,
                                  ).build(context),
                                  const OurbitTableCell(
                                    child: Text('Limit Kredit'),
                                    isHeader: true,
                                    alignment: Alignment.centerRight,
                                    expanded: false,
                                    width: 160,
                                  ).build(context),
                                  const OurbitTableCell(
                                    child: Text('Term Pembayaran'),
                                    isHeader: true,
                                    expanded: false,
                                    width: 160,
                                  ).build(context),
                                  const OurbitTableCell(
                                    child: Text('Status'),
                                    isHeader: true,
                                    expanded: false,
                                    width: 140,
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
                                          // Pelanggan (nama + email)
                                          OurbitTableCell(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .muted,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                      Icons.person,
                                                      size: 20),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        (c['name'] ?? '-')
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                      Text(
                                                        (c['email'] ??
                                                                'Tanpa email')
                                                            .toString(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                                  context)
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

                                          // Kontak
                                          OurbitTableCell(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if ((c['phone'] ?? '')
                                                    .toString()
                                                    .isNotEmpty)
                                                  Text((c['phone'] ?? '')
                                                      .toString()),
                                                Text(
                                                  (c['email'] ?? '—')
                                                      .toString(),
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
                                            width: 220,
                                          ).build(context),

                                          // Tipe
                                          OurbitTableCell(
                                            child: Text(_mapCustomerType(
                                                (c['customer_type'] ?? 'retail')
                                                    .toString())),
                                            expanded: false,
                                            width: 140,
                                          ).build(context),

                                          // Limit Kredit
                                          OurbitTableCell(
                                            child: Text(
                                              _formatCurrency(
                                                  (c['credit_limit'] ?? 0)
                                                      as num),
                                            ),
                                            alignment: Alignment.centerRight,
                                            expanded: false,
                                            width: 160,
                                          ).build(context),

                                          // Term Pembayaran
                                          OurbitTableCell(
                                            child: Text(
                                                '${(c['payment_terms'] ?? 0)} hari'),
                                            expanded: false,
                                            width: 160,
                                          ).build(context),

                                          // Status
                                          OurbitTableCell(
                                            child: _buildStatusChip(
                                              context,
                                              label: (c['is_active'] ?? true)
                                                  ? 'Aktif'
                                                  : 'Nonaktif',
                                              isPositive:
                                                  (c['is_active'] ?? true),
                                            ),
                                            expanded: false,
                                            width: 140,
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
                                                      builder: (cxt) =>
                                                          CustomerFormSheet(
                                                        customer: {
                                                          'id': c['id'],
                                                          'name': c['name'],
                                                          'code': c['code'],
                                                          'email': c['email'],
                                                          'phone': c['phone'],
                                                          'address':
                                                              c['address'],
                                                          'city_id':
                                                              c['city_id'],
                                                          'province_id':
                                                              c['province_id'],
                                                          'country_id':
                                                              c['country_id'],
                                                          'tax_number':
                                                              c['tax_number'],
                                                          'customer_type': c[
                                                              'customer_type'],
                                                          'credit_limit':
                                                              c['credit_limit'],
                                                          'payment_terms': c[
                                                              'payment_terms'],
                                                          'is_active':
                                                              c['is_active'],
                                                          'notes': c['notes'],
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
                                                      title: 'Hapus Pelanggan',
                                                      content:
                                                          'Apakah Anda yakin ingin menghapus "${(c['name'] ?? '-').toString()}"?',
                                                      confirmText: 'Hapus',
                                                      cancelText: 'Batal',
                                                      isDestructive: true,
                                                    );
                                                    if (confirmed == true &&
                                                        context.mounted) {
                                                      context
                                                          .read<
                                                              ManagementBloc>()
                                                          .add(DeleteCustomer(
                                                              customerId: (c[
                                                                          'id'] ??
                                                                      '')
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

  String _mapCustomerType(String key) {
    switch (key) {
      case 'wholesale':
        return 'Grosir';
      case 'corporate':
        return 'Korporat';
      case 'retail':
      default:
        return 'Retail';
    }
  }
}

Widget _buildStatusChip(BuildContext context,
    {required String label, required bool isPositive}) {
  final Color fg = isPositive ? Colors.green.shade600 : Colors.red.shade600;
  final Color bg = isPositive
      ? Colors.green.withValues(alpha: 0.1)
      : Colors.red.withValues(alpha: 0.1);
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
