// ignore_for_file: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material
    show Icons; // avoid material widgets
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class StoreFormSheet extends StatefulWidget {
  final Map<String, dynamic>? store; // null untuk create, not null untuk edit
  final String? businessId; // diperlukan untuk insert

  const StoreFormSheet({super.key, this.store, this.businessId});

  @override
  State<StoreFormSheet> createState() => _StoreFormSheetState();
}

class _StoreFormSheetState extends State<StoreFormSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _businessFieldController =
      TextEditingController();
  final TextEditingController _businessDescriptionController =
      TextEditingController();
  final TextEditingController _defaultTaxRateController =
      TextEditingController();
  final TextEditingController _mottoController = TextEditingController();

  String _stockSetting = 'auto';
  String _currency = 'IDR';
  bool _isBranch = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      final s = widget.store!;
      _nameController.text = (s['name'] ?? '').toString();
      _addressController.text = (s['address'] ?? '').toString();
      _phoneCodeController.text = (s['phone_country_code'] ?? '+62').toString();
      _phoneNumberController.text = (s['phone_number'] ?? '').toString();
      _businessFieldController.text = (s['business_field'] ?? '').toString();
      _businessDescriptionController.text =
          (s['business_description'] ?? '').toString();
      _stockSetting = (s['stock_setting'] ?? 'auto').toString();
      _currency = (s['currency'] ?? 'IDR').toString();
      _defaultTaxRateController.text = (s['default_tax_rate'] ?? 0).toString();
      _mottoController.text = (s['motto'] ?? '').toString();
      _isBranch = s['is_branch'] ?? true;
    } else {
      _phoneCodeController.text = '+62';
      _currency = 'IDR';
      _stockSetting = 'auto';
      _isBranch = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneCodeController.dispose();
    _phoneNumberController.dispose();
    _businessFieldController.dispose();
    _businessDescriptionController.dispose();
    _defaultTaxRateController.dispose();
    _mottoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final supabase = Supabase.instance.client;

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone_country_code': _phoneCodeController.text.trim().isEmpty
            ? '+62'
            : _phoneCodeController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'business_field': _businessFieldController.text.trim(),
        'business_description':
            _businessDescriptionController.text.trim().isEmpty
                ? null
                : _businessDescriptionController.text.trim(),
        'stock_setting': _stockSetting,
        'currency': _currency,
        'default_tax_rate':
            double.tryParse(_defaultTaxRateController.text) ?? 0,
        'motto': _mottoController.text.trim().isEmpty
            ? null
            : _mottoController.text.trim(),
        'is_branch': _isBranch,
      };

      if (widget.store != null) {
        // Update
        final id = widget.store!['id'];
        await supabase.schema('common').from('stores').update({
          ...payload,
          'updated_at': DateTime.now().toIso8601String()
        }).eq('id', id);
      } else {
        // Insert - needs businessId
        if (widget.businessId == null || widget.businessId!.isEmpty) {
          throw Exception('businessId tidak tersedia');
        }
        await supabase.schema('common').from('stores').insert([
          {
            ...payload,
            'business_id': widget.businessId,
          }
        ]);
      }

      if (!mounted) return;
      closeSheet(context);
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Berhasil'),
            content: Text(widget.store != null
                ? 'Toko diperbarui'
                : 'Toko berhasil ditambahkan'),
            trailing: OurbitButton.primary(
              onPressed: () => overlay.close(),
              label: 'Tutup',
            ),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('STORE_FORM_SAVE_ERROR: $e');
      if (!mounted) return;
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Error'),
            content: Text('Gagal menyimpan toko: $e'),
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
    final isEdit = widget.store != null;
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
                  child: Text(isEdit ? 'Edit Toko' : 'Tambah Toko')
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
            Text(isEdit
                    ? 'Perbarui data toko di bawah ini.'
                    : 'Isi data toko di bawah ini.')
                .muted(),
            const Gap(24),

            // Nama Toko
            const Text('Nama Toko',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _nameController,
              placeholder: 'Masukkan nama toko',
            ),
            const Gap(16),

            // Alamat
            const Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _addressController,
              placeholder: 'Masukkan alamat lengkap',
            ),
            const Gap(16),

            // Telepon
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kode Negara',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        controller: _phoneCodeController,
                        placeholder: '+62',
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor Telepon',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        controller: _phoneNumberController,
                        placeholder: '812-3456-7890',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Bidang & Deskripsi
            const Text('Bidang Usaha',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _businessFieldController,
              placeholder: 'Contoh: Retail, F&B, Fashion',
            ),
            const Gap(12),
            const Text('Deskripsi Bisnis',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _businessDescriptionController,
              placeholder: 'Deskripsi singkat (opsional)',
            ),
            const Gap(16),

            // Pengaturan Stok
            const Text('Pengaturan Stok',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitSelect<String>(
              value: _stockSetting,
              items: const ['auto', 'manual', 'none'],
              itemBuilder: (context, v) {
                switch (v) {
                  case 'auto':
                    return const Text('Otomatis');
                  case 'manual':
                    return const Text('Manual');
                  case 'none':
                    return const Text('Tidak Ada');
                }
                return Text(v);
              },
              onChanged: (v) => setState(() => _stockSetting = v ?? 'auto'),
            ),
            const Gap(16),

            // Mata Uang
            const Text('Mata Uang',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitSelect<String>(
              value: _currency,
              items: const ['IDR', 'USD'],
              itemBuilder: (context, v) => Text(v),
              onChanged: (v) => setState(() => _currency = v ?? 'IDR'),
            ),
            const Gap(16),

            // Tipe Toko
            const Text('Tipe Toko',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitSelect<bool>(
              value: _isBranch,
              items: const [false, true],
              itemBuilder: (context, v) => Text(v ? 'Cabang' : 'Pusat'),
              onChanged: (v) => setState(() => _isBranch = v ?? true),
            ),
            const Gap(16),

            // Pajak Default
            const Text('Pajak Default (%)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _defaultTaxRateController,
              placeholder: '0',
            ),
            const Gap(16),

            // Motto
            const Text('Motto', style: TextStyle(fontWeight: FontWeight.w600)),
            const Gap(8),
            OurbitTextInput(
              controller: _mottoController,
              placeholder: 'Motto atau tagline toko',
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
                    label: isEdit ? 'Update Toko' : 'Simpan',
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
