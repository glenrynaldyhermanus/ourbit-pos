import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoreContentMobile extends StatefulWidget {
  const StoreContentMobile({super.key});

  @override
  State<StoreContentMobile> createState() => _StoreContentMobileState();
}

class _StoreContentMobileState extends State<StoreContentMobile> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxController = TextEditingController(text: '0');
  String _currency = 'IDR';
  String _timezone = 'Asia/Jakarta';
  String? _storeId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final role = await client
          .schema('common')
          .from('role_assignments')
          .select('store_id')
          .eq('user_id', client.auth.currentUser!.id)
          .limit(1)
          .single();
      _storeId = role['store_id'] as String?;
      if (_storeId == null) {
        return;
      }
      final store = await client
          .schema('common')
          .from('stores')
          .select(
              'name, address, phone_country_code, phone_number, currency, default_tax_rate')
          .eq('id', _storeId!)
          .single();
      _nameController.text = (store['name'] ?? '').toString();
      _addressController.text = (store['address'] ?? '').toString();
      _currency = (store['currency'] ?? 'IDR').toString();
      _taxController.text = ((store['default_tax_rate'] ?? 0).toString());
      final phone = [
        (store['phone_country_code'] ?? '+62').toString(),
        (store['phone_number'] ?? '').toString(),
      ].where((e) => e.isNotEmpty).join(' ');
      _phoneController.text = phone;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_storeId == null) return;
    setState(() => _saving = true);
    try {
      final client = Supabase.instance.client;
      final parts = _phoneController.text.trim().split(' ');
      final cc =
          parts.isNotEmpty && parts.first.startsWith('+') ? parts.first : '+62';
      final number = parts.length > 1 ? parts.sublist(1).join(' ').trim() : '';
      await client.schema('common').from('stores').update({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone_country_code': cc,
        'phone_number': number,
        'currency': _currency,
        'default_tax_rate': double.tryParse(_taxController.text) ?? 0,
      }).eq('id', _storeId!);

      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: Text('Pengaturan toko berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: Text('Gagal menyimpan pengaturan toko'),
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
      return const Center(child: OurbitCircularProgress());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Toko',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkPrimaryText
                  : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          OurbitTextInput(
            controller: _nameController,
            placeholder: 'Nama Toko',
          ),
          const SizedBox(height: 12),
          OurbitTextInput(
            controller: _addressController,
            placeholder: 'Alamat',
          ),
          const SizedBox(height: 12),
          OurbitTextInput(
            controller: _phoneController,
            placeholder: 'Nomor Telepon (+62 8123456789)',
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mata Uang',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).brightness == material.Brightness.dark
                          ? AppColors.darkPrimaryText
                          : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              OurbitSelect<String>(
                value: _currency,
                items: const ['IDR', 'USD'],
                itemBuilder: (context, item) => Text(
                  item == 'IDR' ? 'IDR - Rupiah' : 'USD - Dollar',
                ),
                onChanged: (v) => setState(() => _currency = v ?? 'IDR'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OurbitTextInput(
            controller: _taxController,
            placeholder: 'Pajak (%)',
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zona Waktu',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).brightness == material.Brightness.dark
                          ? AppColors.darkPrimaryText
                          : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              OurbitSelect<String>(
                value: _timezone,
                items: const ['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'],
                itemBuilder: (context, item) => Text(
                  item == 'Asia/Jakarta'
                      ? 'Asia/Jakarta (WIB)'
                      : item == 'Asia/Makassar'
                          ? 'Asia/Makassar (WITA)'
                          : 'Asia/Jayapura (WIT)',
                ),
                onChanged: (v) =>
                    setState(() => _timezone = v ?? 'Asia/Jakarta'),
              ),
            ],
          ),
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
