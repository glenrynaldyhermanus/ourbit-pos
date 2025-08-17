import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_theme_toggle.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';

class SystemContent extends material.StatefulWidget {
  const SystemContent({super.key});

  @override
  material.State<SystemContent> createState() => _SystemContentState();
}

class _SystemContentState extends material.State<SystemContent> {
  String _language = 'id';
  String _dateFormat = 'DD/MM/YYYY';
  String _backupFrequency = 'daily';
  final _autoLogoutController = material.TextEditingController(text: '30');
  bool _saving = false;

  @override
  void dispose() {
    _autoLogoutController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      OurbitToast.success(
        context: context,
        title: 'Berhasil',
        content: 'Pengaturan sistem diperbarui',
      );
    } catch (_) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Tidak dapat menyimpan pengaturan sistem',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan Sistem',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        const OurbitThemeToggle(showLabel: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bahasa'),
                  const SizedBox(height: 8),
                  OurbitSelect<String>(
                    value: _language,
                    items: const ['id', 'en'],
                    itemBuilder: (context, item) => Text(
                      item == 'id' ? 'Bahasa Indonesia' : 'English',
                    ),
                    onChanged: (v) => setState(() => _language = v ?? 'id'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Format Tanggal'),
                  const SizedBox(height: 8),
                  OurbitSelect<String>(
                    value: _dateFormat,
                    items: const ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                    itemBuilder: (context, item) => Text(item),
                    onChanged: (v) =>
                        setState(() => _dateFormat = v ?? 'DD/MM/YYYY'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frekuensi Backup'),
                  const SizedBox(height: 8),
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
                    onChanged: (v) =>
                        setState(() => _backupFrequency = v ?? 'daily'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OurbitTextInput(
                  controller: _autoLogoutController,
                  placeholder: 'Auto Logout (menit)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OurbitButton.primary(
          onPressed: _saving ? null : _save,
          label: _saving ? 'Menyimpan...' : 'Simpan Pengaturan',
        ),
        const SizedBox(height: 24),
        Text(
          'Manajemen Database',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const material.EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('Backup Database secara manual'),
              ),
              OurbitButton.primary(
                onPressed: () {
                  OurbitToast.success(
                    context: context,
                    title: 'Mulai',
                    content: 'Backup database dimulai',
                  );
                },
                label: 'Backup',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const material.EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text('Restore Database dari file backup'),
              ),
              OurbitButton.outline(
                onPressed: () {
                  OurbitToast.error(
                    context: context,
                    title: 'Belum Tersedia',
                    content: 'Fitur restore akan segera tersedia',
                  );
                },
                label: 'Restore',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
