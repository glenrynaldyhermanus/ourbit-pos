import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileContentMobile extends material.StatefulWidget {
  const ProfileContentMobile({super.key});

  @override
  material.State<ProfileContentMobile> createState() =>
      _ProfileContentMobileState();
}

class _ProfileContentMobileState extends material.State<ProfileContentMobile> {
  bool _loading = false;
  bool _saving = false;
  String? _userId;

  final material.TextEditingController _nameController =
      material.TextEditingController();
  final material.TextEditingController _emailController =
      material.TextEditingController();
  final material.TextEditingController _phoneController =
      material.TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        _userId = user.id;
        _nameController.text = user.userMetadata?['name'] ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.userMetadata?['phone'] ?? '';
      }
    } catch (e) {
      Logger.error('LOAD_PROFILE_MOBILE_ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_userId == null) return;
    setState(() => _saving = true);
    try {
      final userData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: userData,
        ),
      );

      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Profil berhasil diperbarui'),
          backgroundColor: material.Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('SAVE_PROFILE_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Gagal memperbarui profil'),
          backgroundColor: material.Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    if (_loading) {
      return const material.Center(
        child: material.CircularProgressIndicator(),
      );
    }

    return material.SingleChildScrollView(
      padding: const material.EdgeInsets.all(16),
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          // Header
          material.Text(
            'Profil Pengguna',
            style: material.Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: material.FontWeight.bold,
                ),
          ),
          const material.SizedBox(height: 8),
          material.Text(
            'Kelola informasi profil Anda',
            style: material.Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: material.Colors.grey[600],
                ),
          ),
          const material.SizedBox(height: 24),

          // Profile Form
          material.Card(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  material.Text(
                    'Informasi Pribadi',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 16),
                  OurbitTextInput(
                    controller: _nameController,
                    placeholder: 'Nama lengkap',
                  ),
                  const material.SizedBox(height: 12),
                  material.TextField(
                    controller: _emailController,
                    decoration: const material.InputDecoration(
                      labelText: 'Email',
                      border: material.OutlineInputBorder(),
                    ),
                    enabled: false,
                  ),
                  const material.SizedBox(height: 12),
                  OurbitTextInput(
                    controller: _phoneController,
                    placeholder: 'Nomor telepon',
                  ),
                  const material.SizedBox(height: 16),
                  material.SizedBox(
                    width: double.infinity,
                    child: OurbitButton.primary(
                      onPressed: _saving ? null : _saveProfile,
                      label: _saving ? 'Menyimpan...' : 'Simpan Perubahan',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
