import 'package:ourbit_pos/app/admin/desktop/organization/staffs/widgets/staff_form_sheet.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/table/ourbit_table.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StaffsContent extends StatefulWidget {
  const StaffsContent({super.key});

  @override
  State<StaffsContent> createState() => _StaffsContentState();
}

class _StaffsContentState extends State<StaffsContent> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = false;
  String? _businessId;
  String? _storeId;

  String _searchTerm = '';
  String _sortKey = 'name';
  bool _sortAsc = true;
  int _currentPage = 1;
  int _pageSize = 10;

  // Staff data: each item example
  // { role_assignment_id, created_at, user_id, email, name, phone, role: {id, name} }
  List<Map<String, dynamic>> _staff = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
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
      _businessId = (businessData?['id'])?.toString();
      _storeId = await LocalStorageService.getStoreId();
      await _loadStaff();
    } catch (e) {
      Logger.error('STAFF_INIT_ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStaff() async {
    if ((_businessId == null || _businessId!.isEmpty) ||
        (_storeId == null || _storeId!.isEmpty)) {
      Logger.error('STAFF_LOAD: businessId or storeId null/empty');
      setState(() => _staff = []);
      return;
    }

    try {
      // Get role assignments for business + store
      final ra = await Supabase.instance.client
          .from('role_assignments')
          .select('id, created_at, user_id, role_id')
          .eq('business_id', _businessId as Object)
          .eq('store_id', _storeId as Object);

      final roleIds = <String>{};
      final userIds = <String>{};
      for (final e in (ra as List)) {
        final m = Map<String, dynamic>.from(e as Map);
        if (m['role_id'] != null) roleIds.add(m['role_id'].toString());
        if (m['user_id'] != null) userIds.add(m['user_id'].toString());
      }

      // Fetch roles map
      Map<String, Map<String, dynamic>> rolesById = {};
      if (roleIds.isNotEmpty) {
        final rolesRes = await Supabase.instance.client
            .from('roles')
            .select('id, name')
            .inFilter('id', roleIds.toList());
        for (final r in (rolesRes as List)) {
          final rm = Map<String, dynamic>.from(r as Map);
          rolesById[rm['id'].toString()] = rm;
        }
      }

      // Try fetch user profiles (best-effort). Assuming table 'profiles' exists.
      Map<String, Map<String, dynamic>> usersById = {};
      if (userIds.isNotEmpty) {
        try {
          final usersRes = await Supabase.instance.client
              .from('profiles')
              .select('id, email, name, phone')
              .inFilter('id', userIds.toList());
          for (final u in (usersRes as List)) {
            final um = Map<String, dynamic>.from(u as Map);
            usersById[um['id'].toString()] = um;
          }
        } catch (_) {
          // ignore if profiles is not available
        }
      }

      final list = <Map<String, dynamic>>[];
      for (final e in (ra as List)) {
        final m = Map<String, dynamic>.from(e as Map);
        final uid = m['user_id']?.toString();
        final rid = m['role_id']?.toString();
        final role = rid != null ? rolesById[rid] : null;
        final user = uid != null ? usersById[uid] : null;
        list.add({
          'role_assignment_id': m['id'],
          'created_at': m['created_at'],
          'user_id': uid,
          'email': user?['email'] ?? '-',
          'name': user?['name'],
          'phone': user?['phone'],
          'role': role,
        });
      }

      setState(() => _staff = list);
    } catch (e) {
      Logger.error('STAFF_LOAD_ERROR: $e');
      setState(() => _staff = []);
    }
  }

  Future<void> _deleteAssignment(Map<String, dynamic> item) async {
    final confirmed = await OurbitDialog.show(
      context: context,
      title: 'Hapus Staff dari Toko',
      content:
          'Apakah Anda yakin ingin menghapus staff ${item['email'] ?? item['user_id']} dari toko ini?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      final id = item['role_assignment_id']?.toString();
      if (id == null || id.isEmpty) return;
      await Supabase.instance.client
          .from('role_assignments')
          .delete()
          .eq('id', id);
      await _loadStaff();
      if (!mounted) return;
      showToast(
        context: context,
        builder: (ctx, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Berhasil'),
            content: const Text('Staff berhasil dihapus dari toko'),
            trailing: OurbitButton.primary(
              onPressed: () => overlay.close(),
              label: 'Tutup',
            ),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('DELETE_ASSIGNMENT_ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter + sort + paginate
    final filtered = _staff.where((s) {
      if (_searchTerm.isEmpty) return true;
      final email = (s['email'] ?? '').toString().toLowerCase();
      final name = (s['name'] ?? '').toString().toLowerCase();
      final roleName = (s['role']?['name'] ?? '').toString().toLowerCase();
      return email.contains(_searchTerm) ||
          name.contains(_searchTerm) ||
          roleName.contains(_searchTerm);
    }).toList();

    filtered.sort((a, b) {
      int res = 0;
      switch (_sortKey) {
        case 'name':
          res = (a['name'] ?? a['email'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo(
                  (b['name'] ?? b['email'] ?? '').toString().toLowerCase());
          break;
        case 'role':
          res = (a['role']?['name'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['role']?['name'] ?? '').toString().toLowerCase());
          break;
        case 'created_at':
          res = DateTime.parse(a['created_at'].toString())
              .compareTo(DateTime.parse(b['created_at'].toString()));
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
                    'Staff',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Kelola staff dan role di toko Anda'),
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
                      builder: (c) => StaffFormSheet(
                        businessId: _businessId,
                        storeId: _storeId,
                        onSaved: _loadStaff,
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
                placeholder: 'Cari staff berdasarkan nama, email, atau role',
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
              final Color borderColor =
                  isDark ? const Color(0xff292524) : const Color(0xFFE5E7EB);
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
                          child: Text('Staff'),
                          isHeader: true,
                          expanded: false,
                          width: 280,
                        ).build(context),
                        const OurbitTableCell(
                          child: Text('Telepon'),
                          isHeader: true,
                          expanded: false,
                          width: 160,
                        ).build(context),
                        const OurbitTableCell(
                          child: Text('Role'),
                          isHeader: true,
                          expanded: false,
                          width: 160,
                        ).build(context),
                        const OurbitTableCell(
                          child: Text('Bergabung'),
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
                      rows: pageItems.map((s) {
                        final created = DateTime.tryParse(
                            (s['created_at'] ?? '').toString());
                        final createdStr = created != null
                            ? '${created.day.toString().padLeft(2, '0')} ${_monthShort(created.month)} ${created.year}'
                            : '-';
                        return TableRow(cells: [
                          // Staff
                          OurbitTableCell(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (s['name'] ?? 'No Name').toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  (s['email'] ?? '-').toString(),
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
                          // Telepon
                          OurbitTableCell(
                            child: Text((s['phone'] ?? '-').toString()),
                            expanded: false,
                            width: 160,
                          ).build(context),
                          // Role
                          OurbitTableCell(
                            child: _roleChip(
                                context, (s['role']?['name'] ?? '-') as String),
                            expanded: false,
                            width: 160,
                          ).build(context),
                          // Bergabung
                          OurbitTableCell(
                            child: Text(createdStr),
                            expanded: false,
                            width: 160,
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
                                      builder: (c) => StaffFormSheet(
                                        businessId: _businessId,
                                        storeId: _storeId,
                                        staff: s,
                                        onSaved: _loadStaff,
                                      ),
                                      position: OverlayPosition.right,
                                    );
                                  },
                                  icon: const Icon(Icons.edit, size: 16),
                                ),
                                const SizedBox(width: 6),
                                OurbitIconButton.destructive(
                                  onPressed: () => _deleteAssignment(s),
                                  icon: const Icon(Icons.delete, size: 16),
                                ),
                              ],
                            ),
                            expanded: false,
                            width: 96,
                          ).build(context),
                        ]);
                      }).toList(),
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
  }

  String _monthShort(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  Widget _roleChip(BuildContext context, String name) {
    final Color fg = Colors.blue.shade600;
    final Color bg = Colors.blue.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name.isEmpty ? '-' : name,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
