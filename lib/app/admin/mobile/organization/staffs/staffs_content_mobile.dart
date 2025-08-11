import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class StaffsContentMobile extends material.StatefulWidget {
  const StaffsContentMobile({super.key});

  @override
  material.State<StaffsContentMobile> createState() =>
      _StaffsContentMobileState();
}

class _StaffsContentMobileState extends material.State<StaffsContentMobile> {
  String _query = '';
  String? _businessId;
  String? _storeId;
  bool _loading = false;
  List<Map<String, dynamic>> _staff = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);
    try {
      final businessData = await LocalStorageService.getBusinessData();
      _businessId = (businessData?['id'])?.toString();
      _storeId = await LocalStorageService.getStoreId();
      await _loadStaff();
    } catch (e) {
      Logger.error('STAFF_MOBILE_INIT_ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStaff() async {
    if ((_businessId == null || _businessId!.isEmpty) ||
        (_storeId == null || _storeId!.isEmpty)) {
      Logger.error('STAFF_MOBILE_LOAD: businessId or storeId null/empty');
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

      // Fetch users map
      Map<String, Map<String, dynamic>> usersById = {};
      if (userIds.isNotEmpty) {
        final usersRes = await Supabase.instance.client
            .from('users')
            .select('id, email, name, phone')
            .inFilter('id', userIds.toList());
        for (final u in (usersRes as List)) {
          final um = Map<String, dynamic>.from(u as Map);
          usersById[um['id'].toString()] = um;
        }
      }

      // Combine data
      final List<Map<String, dynamic>> staffList = [];
      for (final e in (ra as List)) {
        final m = Map<String, dynamic>.from(e as Map);
        final userId = m['user_id']?.toString();
        final roleId = m['role_id']?.toString();
        final user = usersById[userId];
        final role = rolesById[roleId];

        if (user != null && role != null) {
          staffList.add({
            'role_assignment_id': m['id'],
            'created_at': m['created_at'],
            'user_id': userId,
            'email': user['email'],
            'name': user['name'],
            'phone': user['phone'],
            'role': role,
          });
        }
      }

      setState(() => _staff = staffList);
    } catch (e) {
      Logger.error('STAFF_MOBILE_LOAD_ERROR: $e');
      setState(() => _staff = []);
    }
  }

  Future<void> _deleteStaff(String roleAssignmentId, String name) async {
    final confirmed = await OurbitDialog.show(
      context: context,
      title: 'Hapus Staff',
      content: 'Apakah Anda yakin ingin menghapus "$name"?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await Supabase.instance.client
          .from('role_assignments')
          .delete()
          .eq('id', roleAssignmentId);
      await _loadStaff();
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Staff "$name" berhasil dihapus'),
          backgroundColor: material.Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('DELETE_STAFF_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Gagal menghapus staff'),
          backgroundColor: material.Colors.red,
        ),
      );
    }
  }

  void _showStaffDetail(Map<String, dynamic> staff) {
    material.showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => material.Container(
        padding: const material.EdgeInsets.all(16),
        child: material.Column(
          mainAxisSize: material.MainAxisSize.min,
          crossAxisAlignment: material.CrossAxisAlignment.start,
          children: [
            material.Row(
              children: [
                material.CircleAvatar(
                  backgroundColor: material.Colors.green[50],
                  child: material.Icon(
                    material.Icons.person,
                    color: material.Colors.green,
                  ),
                ),
                const material.SizedBox(width: 12),
                material.Expanded(
                  child: material.Column(
                    crossAxisAlignment: material.CrossAxisAlignment.start,
                    children: [
                      material.Text(
                        (staff['name'] ?? '-').toString(),
                        style: const material.TextStyle(
                          fontSize: 18,
                          fontWeight: material.FontWeight.bold,
                        ),
                      ),
                      material.Text(
                        (staff['role']['name'] ?? '-').toString(),
                        style: material.TextStyle(
                          color: material.Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const material.SizedBox(height: 16),
            _buildDetailRow('Email', (staff['email'] ?? '-').toString()),
            _buildDetailRow('Telepon', (staff['phone'] ?? '-').toString()),
            _buildDetailRow('Role', (staff['role']['name'] ?? '-').toString()),
            _buildDetailRow(
              'Bergabung',
              DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(staff['created_at'])),
            ),
            const material.SizedBox(height: 16),
            material.Row(
              children: [
                material.Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      // TODO: Open edit form
                    },
                    label: 'Edit',
                  ),
                ),
                const material.SizedBox(width: 8),
                material.Expanded(
                  child: OurbitButton.destructive(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      _deleteStaff(
                        (staff['role_assignment_id'] ?? '').toString(),
                        (staff['name'] ?? '-').toString(),
                      );
                    },
                    label: 'Hapus',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  material.Widget _buildDetailRow(String label, String value) {
    return material.Padding(
      padding: const material.EdgeInsets.symmetric(vertical: 4),
      child: material.Row(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          material.SizedBox(
            width: 80,
            child: material.Text(
              label,
              style: const material.TextStyle(
                fontWeight: material.FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          material.Expanded(
            child: material.Text(
              value,
              style: const material.TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    if (_loading) {
      return const material.Center(
        child: material.CircularProgressIndicator(),
      );
    }

    final filtered = _staff.where((s) {
      if (_query.isEmpty) return true;
      final name = (s['name'] ?? '').toString().toLowerCase();
      final email = (s['email'] ?? '').toString().toLowerCase();
      final role = (s['role']['name'] ?? '').toString().toLowerCase();
      return name.contains(_query) ||
          email.contains(_query) ||
          role.contains(_query);
    }).toList();

    return material.Column(
      children: [
        // Search
        material.Padding(
          padding: const material.EdgeInsets.all(16),
          child: OurbitTextInput(
            placeholder: 'Cari staff berdasarkan nama/email/role',
            leading: const material.Icon(material.Icons.search, size: 16),
            onChanged: (v) {
              setState(() {
                _query = (v ?? '').trim().toLowerCase();
              });
            },
          ),
        ),

        // List
        material.Expanded(
          child: filtered.isEmpty
              ? const material.Center(
                  child: material.Text('Tidak ada staff'),
                )
              : material.ListView.separated(
                  padding: const material.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const material.SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    return material.Card(
                      child: material.ListTile(
                        leading: material.CircleAvatar(
                          backgroundColor: material.Colors.green[50],
                          child: material.Icon(
                            material.Icons.person,
                            color: material.Colors.green,
                          ),
                        ),
                        title: material.Text(
                          (s['name'] ?? '-').toString(),
                          style: const material.TextStyle(
                            fontWeight: material.FontWeight.w600,
                          ),
                        ),
                        subtitle: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            material.Text(
                              (s['email'] ?? '—').toString(),
                              maxLines: 1,
                              overflow: material.TextOverflow.ellipsis,
                            ),
                            const material.SizedBox(height: 4),
                            material.Text(
                              (s['phone'] ?? '—').toString(),
                              maxLines: 1,
                              overflow: material.TextOverflow.ellipsis,
                              style: material.TextStyle(
                                fontSize: 12,
                                color: material.Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: material.Container(
                          padding: const material.EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: material.BoxDecoration(
                            color: material.Colors.blue[50],
                            borderRadius: material.BorderRadius.circular(12),
                          ),
                          child: material.Text(
                            (s['role']['name'] ?? '—').toString(),
                            style: material.TextStyle(
                              fontSize: 12,
                              color: material.Colors.blue[700],
                              fontWeight: material.FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () => _showStaffDetail(s),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
