import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileContent extends material.StatefulWidget {
  const ProfileContent({super.key});

  @override
  material.State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends material.State<ProfileContent> {
  final _nameController = material.TextEditingController();
  final _emailController = material.TextEditingController();
  final _phoneController = material.TextEditingController();
  bool _loading = true;
  bool _saving = false;

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
        _nameController.text = user.userMetadata?['name'] ??
            user.userMetadata?['display_name'] ??
            '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.userMetadata?['phone'] ?? '';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
        ),
      );
      OurbitToast.success(
        context: context,
        title: 'Berhasil',
        content: 'Profil berhasil diperbarui',
      );
    } catch (_) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Tidak dapat menyimpan profil',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    if (_loading) {
      return const Center(child: material.CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil Pengguna',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        OurbitTextInput(
          controller: _nameController,
          placeholder: 'Nama Lengkap',
        ),
        const SizedBox(height: 12),
        material.TextField(
          controller: _emailController,
          decoration: const material.InputDecoration(
            labelText: 'Email',
            border: material.OutlineInputBorder(),
          ),
          enabled: false,
        ),
        const SizedBox(height: 12),
        OurbitTextInput(
          controller: _phoneController,
          placeholder: 'Nomor Telepon',
        ),
        const SizedBox(height: 16),
        OurbitButton.primary(
          onPressed: _saving ? null : _saveProfile,
          label: _saving ? 'Menyimpan...' : 'Simpan Perubahan',
        ),
      ],
    );
  }
}
