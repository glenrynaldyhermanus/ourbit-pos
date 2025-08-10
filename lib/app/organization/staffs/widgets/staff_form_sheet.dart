import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class StaffFormSheet extends StatefulWidget {
  final Map<String, dynamic>?
      staff; // null = create assignment, not null = update role
  final String? businessId;
  final String? storeId;
  final Future<void> Function()? onSaved;

  const StaffFormSheet(
      {super.key, this.staff, this.businessId, this.storeId, this.onSaved});

  @override
  State<StaffFormSheet> createState() => _StaffFormSheetState();
}

class _StaffFormSheetState extends State<StaffFormSheet> {
  final TextEditingController _emailSearchController = TextEditingController();
  String? _selectedUserId;
  String? _selectedRoleId;
  bool _isSaving = false;
  bool _isSearching = false;

  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _searchResults = [];

  bool get _isEdit =>
      widget.staff != null && widget.staff!['role_assignment_id'] != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _selectedUserId = widget.staff!['user_id']?.toString();
      _emailSearchController.text = (widget.staff!['email'] ?? '').toString();
      _selectedRoleId = widget.staff!['role']?['id']?.toString();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadRoles();
    });
  }

  @override
  void dispose() {
    _emailSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final res =
          await Supabase.instance.client.from('roles').select('id, name');
      setState(() {
        _roles =
            (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      Logger.error('LOAD_ROLES_ERROR: $e');
    }
  }

  Future<void> _searchUsers(String email) async {
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    try {
      // assuming profiles table with email/name
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id, email, name')
          .ilike('email', '%$email%')
          .limit(20);
      setState(() {
        _searchResults =
            (res as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      Logger.error('SEARCH_USERS_ERROR: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      if (_isEdit) {
        final id = widget.staff!['role_assignment_id']?.toString();
        if (id == null ||
            id.isEmpty ||
            _selectedRoleId == null ||
            _selectedRoleId!.isEmpty) {
          throw Exception('Data tidak lengkap');
        }
        await supabase
            .from('role_assignments')
            .update({'role_id': _selectedRoleId}).eq('id', id);
      } else {
        if (_selectedUserId == null || _selectedRoleId == null) {
          throw Exception('User dan Role wajib dipilih');
        }
        if (widget.businessId == null ||
            widget.businessId!.isEmpty ||
            widget.storeId == null ||
            widget.storeId!.isEmpty) {
          throw Exception('Business ID atau Store ID tidak tersedia');
        }
        await supabase.from('role_assignments').insert([
          {
            'user_id': _selectedUserId,
            'business_id': widget.businessId,
            'role_id': _selectedRoleId,
            'store_id': widget.storeId,
          }
        ]);
      }

      if (widget.onSaved != null) {
        await widget.onSaved!();
      }
      if (!mounted) return;
      closeSheet(context);
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Berhasil'),
            content:
                Text(_isEdit ? 'Assignment diperbarui' : 'Staff ditambahkan'),
            trailing: OurbitButton.primary(
              onPressed: () => overlay.close(),
              label: 'Tutup',
            ),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('STAFF_FORM_SAVE_ERROR: $e');
      if (!mounted) return;
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Error'),
            content: Text('Gagal menyimpan data staff: $e'),
            trailing: OurbitButton.primary(
              onPressed: () => overlay.close(),
              label: 'Tutup',
            ),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(_isEdit ? 'Edit Staff' : 'Tambah Staff')
                      .large()
                      .semiBold(),
                ),
                OurbitButton.ghost(
                  onPressed: _isSaving ? null : () => closeSheet(context),
                  label: 'Tutup',
                ),
              ],
            ),
            const Gap(16),
            Text(_isEdit
                    ? 'Perbarui assignment staff.'
                    : 'Assign staff ke role untuk toko ini.')
                .muted(),
            const Gap(24),

            // Email search (disabled on edit)
            const Text('Email Staff *',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _emailSearchController,
              placeholder: 'Cari staff berdasarkan email',
              // OurbitTextInput belum expose enabled; biarkan tetap aktif namun abaikan saat edit
              onChanged: (v) {
                final value = (v ?? '').trim();
                if (!_isEdit && value.length >= 3) {
                  _searchUsers(value);
                } else {
                  setState(() => _searchResults = []);
                }
              },
            ),
            if (_isSearching) ...[
              const Gap(8),
              const Text('Mencari...').muted(),
            ],
            if (_searchResults.isNotEmpty) ...[
              const Gap(8),
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.border),
                  borderRadius: Theme.of(context).borderRadiusMd,
                ),
                child: Column(
                  children: _searchResults.map((u) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedUserId = u['id'].toString();
                          _emailSearchController.text =
                              (u['email'] ?? '').toString();
                          _searchResults = [];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((u['name'] ?? 'No Name').toString()),
                                  Text(
                                    (u['email'] ?? '-').toString(),
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
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const Gap(16),

            // Role select
            const Text('Role *', style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitSelect<String>(
              value: _selectedRoleId,
              items: _roles.map((r) => r['id'].toString()).toList(),
              itemBuilder: (context, id) {
                final role = _roles.firstWhere(
                  (r) => r['id'].toString() == id,
                  orElse: () => {'name': '-'},
                );
                return Text((role['name'] ?? '-').toString());
              },
              onChanged: (v) => setState(() => _selectedRoleId = v),
            ),

            const Gap(24),

            Row(
              children: [
                Expanded(
                  child: OurbitButton.outline(
                    onPressed: _isSaving ? null : () => closeSheet(context),
                    label: 'Batal',
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: OurbitButton.primary(
                    onPressed: _isSaving ? null : _handleSubmit,
                    label: _isEdit ? 'Update Assignment' : 'Simpan',
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
