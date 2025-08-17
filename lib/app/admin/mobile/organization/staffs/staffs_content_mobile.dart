import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class StaffsContentMobile extends StatefulWidget {
  const StaffsContentMobile({super.key});

  @override
  State<StaffsContentMobile> createState() => _StaffsContentMobileState();
}

class _StaffsContentMobileState extends State<StaffsContentMobile>
    with TickerProviderStateMixin {
  String _query = '';
  String? _businessId;
  String? _storeId;
  bool _loading = false;
  List<Map<String, dynamic>> _staff = [];

  // Animation controllers
  late AnimationController _listController;
  late AnimationController _detailController;
  String? _selectedStaffId;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initialize();
  }

  void _initAnimationControllers() {
    _listController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _detailController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _listController.dispose();
    _detailController.dispose();
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
      Logger.error('STAFF_MOBILE_INIT_ERROR: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _listController.forward();
      }
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
          .schema('common')
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
            .schema('common')
            .from('roles')
            .select('id, name')
            .inFilter('id', roleIds.toList());
        for (final r in (rolesRes as List)) {
          final rm = Map<String, dynamic>.from(r as Map);
          rolesById[rm['id'].toString()] = rm;
        }
      }

      // Fetch users map from common.users
      Map<String, Map<String, dynamic>> usersById = {};
      if (userIds.isNotEmpty) {
        final usersRes = await Supabase.instance.client
            .schema('common')
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
          .schema('common')
          .from('role_assignments')
          .delete()
          .eq('id', roleAssignmentId);
      await _loadStaff();
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Staff "$name" berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('DELETE_STAFF_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Gagal menghapus staff'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStaffDetail(Map<String, dynamic> staff) {
    _selectedStaffId = staff['user_id']?.toString();
    _detailController.forward();

    material
        .showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: material.Theme.of(context).colorScheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                material.CircleAvatar(
                  backgroundColor:
                      Theme.of(context).brightness == material.Brightness.dark
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15)
                          : Colors.green[50],
                  child: Icon(
                    Icons.person,
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (staff['name'] ?? '-').toString(),
                        style: material.Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: material.FontWeight.bold),
                      ),
                      Text(
                        (staff['role']['name'] ?? '-').toString(),
                        style: material.Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: material.Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnimatedDetailRow(
                'Email', (staff['email'] ?? '-').toString(), 0),
            _buildAnimatedDetailRow(
                'Telepon', (staff['phone'] ?? '-').toString(), 1),
            _buildAnimatedDetailRow(
                'Role', (staff['role']['name'] ?? '-').toString(), 2),
            _buildAnimatedDetailRow(
              'Bergabung',
              DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(staff['created_at'])),
              3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Open edit form
                    },
                    label: 'Edit',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OurbitButton.destructive(
                    onPressed: () {
                      Navigator.of(context).pop();
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
    )
        .then((_) {
      _selectedStaffId = null;
      _detailController.reset();
    });
  }

  Widget _buildAnimatedDetailRow(String label, String value, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - opacity)),
            child: _buildDetailRow(label, value),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String roleName, String userId) {
    final isSelected = _selectedStaffId == userId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[100] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected ? Border.all(color: Colors.blue[300]!, width: 1) : null,
      ),
      child: Text(
        roleName,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.blue[800] : Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Center(
        child: OurbitCircularProgress(),
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

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: OurbitTextInput(
            placeholder: 'Cari staff berdasarkan nama/email/role',
            leading: const Icon(Icons.search, size: 16),
            onChanged: (v) {
              setState(() {
                _query = (v ?? '').trim().toLowerCase();
              });
            },
          ),
        ),

        // List
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: filtered.isEmpty
                ? Center(
                    key: const ValueKey('empty'),
                    child: Text(
                      'Tidak ada staff',
                      style: TextStyle(
                        color: Theme.of(context).brightness ==
                                material.Brightness.dark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _listController,
                    child: ListView.separated(
                      key: const ValueKey('list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 150 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - opacity)),
                                child: OurbitCard(
                                  child: material.ListTile(
                                    leading: material.CircleAvatar(
                                      backgroundColor: theme.brightness ==
                                              material.Brightness.dark
                                          ? theme.colorScheme.primary
                                              .withValues(alpha: 0.15)
                                          : Colors.green[50],
                                      child: Icon(
                                        Icons.person,
                                        color: theme.brightness ==
                                                material.Brightness.dark
                                            ? theme.colorScheme.primary
                                            : Colors.green,
                                      ),
                                    ),
                                    title: Text(
                                      (s['name'] ?? '-').toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkPrimaryText
                                            : AppColors.primaryText,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (s['email'] ?? '—').toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    material.Brightness.dark
                                                ? AppColors.darkSecondaryText
                                                : AppColors.secondaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (s['phone'] ?? '—').toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    material.Brightness.dark
                                                ? AppColors.darkSecondaryText
                                                : AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: _buildRoleBadge(
                                      (s['role']['name'] ?? '—').toString(),
                                      (s['user_id'] ?? '').toString(),
                                    ),
                                    onTap: () => _showStaffDetail(s),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
