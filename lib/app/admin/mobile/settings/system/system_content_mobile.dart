import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_theme_toggle.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SystemContentMobile extends StatefulWidget {
  const SystemContentMobile({super.key});

  @override
  State<SystemContentMobile> createState() => _SystemContentMobileState();
}

class _SystemContentMobileState extends State<SystemContentMobile> {
  String _language = 'id';
  String _dateFormat = 'DD/MM/YYYY';
  String _backupFrequency = 'daily';
  final _autoLogoutController = TextEditingController(text: '30');
  bool _saving = false;

  @override
  void dispose() {
    _autoLogoutController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    material.ScaffoldMessenger.of(context).showSnackBar(
      const material.SnackBar(
        content: Text('Pengaturan sistem diperbarui'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Sistem',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkPrimaryText
                  : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          const OurbitThemeToggle(showLabel: true),
          const SizedBox(height: 12),
          OurbitSelect<String>(
            value: _language,
            items: const ['id', 'en'],
            itemBuilder: (context, item) => Text(
              item == 'id' ? 'Bahasa Indonesia' : 'English',
            ),
            onChanged: (v) => setState(() => _language = v ?? 'id'),
          ),
          const SizedBox(height: 12),
          OurbitSelect<String>(
            value: _dateFormat,
            items: const ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
            itemBuilder: (context, item) => Text(item),
            onChanged: (v) => setState(() => _dateFormat = v ?? 'DD/MM/YYYY'),
          ),
          const SizedBox(height: 12),
          OurbitSelect<String>(
            value: _backupFrequency,
            items: const ['daily', 'weekly', 'monthly'],
            itemBuilder: (context, item) => Text(
              item == 'daily'
                  ? 'Harian'
                  : item == 'weekly'
                      ? 'Mingguan'
                      : 'Bulanan',
            ),
            onChanged: (v) => setState(() => _backupFrequency = v ?? 'daily'),
          ),
          const SizedBox(height: 12),
          OurbitTextInput(
              controller: _autoLogoutController,
              placeholder: 'Auto Logout (menit)'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OurbitButton.primary(
              onPressed: _saving ? null : _save,
              label: _saving ? 'Menyimpan...' : 'Simpan Pengaturan',
            ),
          ),
        ],
      ),
    );
  }
}
