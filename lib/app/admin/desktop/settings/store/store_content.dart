import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/core/services/business_store_service.dart';

class StoreContent extends material.StatefulWidget {
  const StoreContent({super.key});

  @override
  material.State<StoreContent> createState() => _StoreContentState();
}

class _StoreContentState extends material.State<StoreContent> {
  final _nameController = material.TextEditingController();
  final _addressController = material.TextEditingController();
  final _phoneController = material.TextEditingController();
  final _taxController = material.TextEditingController(text: '0');

  String _currency = 'IDR';
  String _timezone = 'Asia/Jakarta';
  bool _loading = true;
  bool _saving = false;
  String? _storeId;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  Future<void> _loadStore() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final storeService = BusinessStoreService(client);
      final storeId = await storeService.getCurrentStoreId();
      _storeId = storeId;
      if (storeId == null) {
        OurbitToast.error(
          context: context,
          title: 'Gagal',
          content: 'Store ID tidak ditemukan',
        );
        return;
      }

      final response = await client
          .schema('common')
          .from('stores')
          .select(
              'name, address, phone_country_code, phone_number, currency, default_tax_rate')
          .eq('id', storeId)
          .single();

      _nameController.text = (response['name'] ?? '').toString();
      _addressController.text = (response['address'] ?? '').toString();
      final phone = [
        (response['phone_country_code'] ?? '+62').toString(),
        (response['phone_number'] ?? '').toString(),
      ].where((e) => e.isNotEmpty).join(' ');
      _phoneController.text = phone;
      _currency = (response['currency'] ?? 'IDR').toString();
      _taxController.text = ((response['default_tax_rate'] ?? 0).toString());
    } catch (_) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Tidak dapat memuat data toko',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveStore() async {
    if (_storeId == null) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Store ID tidak ditemukan',
      );
      return;
    }
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

      OurbitToast.success(
        context: context,
        title: 'Berhasil',
        content: 'Pengaturan toko berhasil diperbarui',
      );
    } catch (e) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Gagal menyimpan pengaturan toko',
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

    return material.SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Toko',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mata Uang'),
                    const SizedBox(height: 8),
                    OurbitSelect<String>(
                      value: _currency,
                      items: const ['IDR', 'USD'],
                      itemBuilder: (context, item) => Text(
                        item == 'IDR' ? 'IDR - Rupiah' : 'USD - Dollar',
                      ),
                      onChanged: (val) =>
                          setState(() => _currency = val ?? 'IDR'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OurbitTextInput(
                  controller: _taxController,
                  placeholder: 'Pajak (%)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Zona Waktu'),
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
                onChanged: (val) =>
                    setState(() => _timezone = val ?? 'Asia/Jakarta'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OurbitButton.primary(
            onPressed: _saving ? null : _saveStore,
            label: _saving ? 'Menyimpan...' : 'Simpan Pengaturan',
          ),
        ],
      ),
    );
  }
}
