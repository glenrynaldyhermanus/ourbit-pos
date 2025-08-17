import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class NotificationsContentMobile extends StatefulWidget {
  const NotificationsContentMobile({super.key});

  @override
  State<NotificationsContentMobile> createState() =>
      _NotificationsContentMobileState();
}

class _NotificationsContentMobileState
    extends State<NotificationsContentMobile> {
  bool _emailNotifications = true;
  bool _lowStockAlerts = true;
  bool _orderNotifications = true;
  bool _dailyReports = false;
  bool _weeklyReports = true;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    material.ScaffoldMessenger.of(context).showSnackBar(
      const material.SnackBar(
        content: Text('Pengaturan notifikasi diperbarui'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() => _saving = false);
  }

  Widget _tile(String title, String subtitle, bool value,
      void Function(bool) onChanged) {
    return OurbitCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? AppColors.darkPrimaryText
                            : AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkPrimaryText
                  : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          _tile(
              'Email Notifikasi',
              'Terima notifikasi via email untuk aktivitas penting',
              _emailNotifications,
              (v) => setState(() => _emailNotifications = v)),
          _tile(
              'Peringatan Stok Rendah',
              'Dapatkan notifikasi saat stok hampir habis',
              _lowStockAlerts,
              (v) => setState(() => _lowStockAlerts = v)),
          _tile(
              'Notifikasi Pesanan',
              'Notifikasi untuk pesanan baru/perubahan status',
              _orderNotifications,
              (v) => setState(() => _orderNotifications = v)),
          _tile('Laporan Harian', 'Terima ringkasan penjualan harian via email',
              _dailyReports, (v) => setState(() => _dailyReports = v)),
          _tile(
              'Laporan Mingguan',
              'Terima ringkasan penjualan mingguan via email',
              _weeklyReports,
              (v) => setState(() => _weeklyReports = v)),
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
