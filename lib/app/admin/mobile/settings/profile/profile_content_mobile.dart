import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';

class ProfileContentMobile extends StatefulWidget {
  const ProfileContentMobile({super.key});

  @override
  State<ProfileContentMobile> createState() => _ProfileContentMobileState();
}

class _ProfileContentMobileState extends State<ProfileContentMobile> {
  bool _loading = false;
  bool _saving = false;
  String? _userId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('SAVE_PROFILE_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Gagal memperbarui profil'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: OurbitCircularProgress(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Profil Pengguna',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkPrimaryText
                  : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola informasi profil Anda',
            style: TextStyle(
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkSecondaryText
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Form
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              OurbitTextInput(
                controller: _nameController,
                placeholder: 'Nama lengkap',
              ),
              const SizedBox(height: 12),
              OurbitTextInput(
                controller: _emailController,
                placeholder: 'Email',
              ),
              const SizedBox(height: 12),
              OurbitTextInput(
                controller: _phoneController,
                placeholder: 'Nomor telepon',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OurbitButton.primary(
                  onPressed: _saving ? null : _saveProfile,
                  label: _saving ? 'Menyimpan...' : 'Simpan Perubahan',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
