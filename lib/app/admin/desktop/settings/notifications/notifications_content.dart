import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';

class NotificationsContent extends material.StatefulWidget {
  const NotificationsContent({super.key});

  @override
  material.State<NotificationsContent> createState() =>
      _NotificationsContentState();
}

class _NotificationsContentState extends material.State<NotificationsContent> {
  bool _emailNotifications = true;
  bool _lowStockAlerts = true;
  bool _orderNotifications = true;
  bool _dailyReports = false;
  bool _weeklyReports = true;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Placeholder: persist to Supabase when table ready
      OurbitToast.success(
        context: context,
        title: 'Berhasil',
        content: 'Pengaturan notifikasi diperbarui',
      );
    } catch (_) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Tidak dapat menyimpan pengaturan notifikasi',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  material.Widget _tile(
      {required String title,
      required String subtitle,
      required bool value,
      required void Function(bool) onChanged}) {
    return Container(
      padding: const material.EdgeInsets.all(16),
      margin: const material.EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          OurbitSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        _tile(
          title: 'Email Notifikasi',
          subtitle: 'Terima notifikasi via email untuk aktivitas penting',
          value: _emailNotifications,
          onChanged: (v) => setState(() => _emailNotifications = v),
        ),
        _tile(
          title: 'Peringatan Stok Rendah',
          subtitle: 'Dapatkan notifikasi saat stok produk hampir habis',
          value: _lowStockAlerts,
          onChanged: (v) => setState(() => _lowStockAlerts = v),
        ),
        _tile(
          title: 'Notifikasi Pesanan',
          subtitle: 'Terima notifikasi untuk pesanan baru dan perubahan status',
          value: _orderNotifications,
          onChanged: (v) => setState(() => _orderNotifications = v),
        ),
        _tile(
          title: 'Laporan Harian',
          subtitle: 'Terima ringkasan penjualan harian via email',
          value: _dailyReports,
          onChanged: (v) => setState(() => _dailyReports = v),
        ),
        _tile(
          title: 'Laporan Mingguan',
          subtitle: 'Terima ringkasan penjualan mingguan via email',
          value: _weeklyReports,
          onChanged: (v) => setState(() => _weeklyReports = v),
        ),
        const SizedBox(height: 8),
        OurbitButton.primary(
          onPressed: _saving ? null : _save,
          label: _saving ? 'Menyimpan...' : 'Simpan Pengaturan',
        ),
      ],
    );
  }
}
