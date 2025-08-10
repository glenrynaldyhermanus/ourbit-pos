import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';

class SupplierFormSheet extends StatefulWidget {
  final Map<String, dynamic>? item; // null untuk create, not null untuk edit

  const SupplierFormSheet({super.key, this.item});

  @override
  State<SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<SupplierFormSheet> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityIdController = TextEditingController();
  final TextEditingController _provinceIdController = TextEditingController();
  final TextEditingController _countryIdController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountNumberController =
      TextEditingController();
  final TextEditingController _bankAccountNameController =
      TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final it = widget.item!;
      _nameController.text = (it['name'] ?? '').toString();
      _codeController.text = (it['code'] ?? '').toString();
      _contactPersonController.text = (it['contact_person'] ?? '').toString();
      _emailController.text = (it['email'] ?? '').toString();
      _phoneController.text = (it['phone'] ?? '').toString();
      _addressController.text = (it['address'] ?? '').toString();
      _cityIdController.text = (it['city_id'] ?? '').toString();
      _provinceIdController.text = (it['province_id'] ?? '').toString();
      _countryIdController.text = (it['country_id'] ?? '').toString();
      _taxNumberController.text = (it['tax_number'] ?? '').toString();
      _bankNameController.text = (it['bank_name'] ?? '').toString();
      _bankAccountNumberController.text =
          (it['bank_account_number'] ?? '').toString();
      _bankAccountNameController.text =
          (it['bank_account_name'] ?? '').toString();
      _creditLimitController.text = (it['credit_limit'] ?? 0).toString();
      _paymentTermsController.text = (it['payment_terms'] ?? 0).toString();
      _notesController.text = (it['notes'] ?? '').toString();
      _isActive = (it['is_active'] ?? true) == true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityIdController.dispose();
    _provinceIdController.dispose();
    _countryIdController.dispose();
    _taxNumberController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    _creditLimitController.dispose();
    _paymentTermsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _parseInt(String text) {
    final t = text.trim();
    final i = int.tryParse(t);
    if (i != null) return i;
    final d = double.tryParse(t);
    return d?.round() ?? 0;
  }

  double _parseDouble(String text) {
    final t = text.trim();
    final d = double.tryParse(t);
    if (d != null) return d;
    final i = int.tryParse(t);
    return i != null ? i.toDouble() : 0.0;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final currentContext = context;
    final managementBloc = currentContext.read<ManagementBloc>();
    try {
      // Validasi sederhana
      if (_nameController.text.trim().isEmpty) {
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              content: const Text('Nama supplier wajib diisi'),
              trailing: OurbitButton.primary(
                onPressed: () => overlay.close(),
                label: 'Tutup',
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
        return;
      }

      final Map<String, dynamic> supplierData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim(),
        'contact_person': _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'city_id': _cityIdController.text.trim().isEmpty
            ? null
            : _cityIdController.text.trim(),
        'province_id': _provinceIdController.text.trim().isEmpty
            ? null
            : _provinceIdController.text.trim(),
        'country_id': _countryIdController.text.trim().isEmpty
            ? null
            : _countryIdController.text.trim(),
        'tax_number': _taxNumberController.text.trim().isEmpty
            ? null
            : _taxNumberController.text.trim(),
        'bank_name': _bankNameController.text.trim().isEmpty
            ? null
            : _bankNameController.text.trim(),
        'bank_account_number': _bankAccountNumberController.text.trim().isEmpty
            ? null
            : _bankAccountNumberController.text.trim(),
        'bank_account_name': _bankAccountNameController.text.trim().isEmpty
            ? null
            : _bankAccountNameController.text.trim(),
        'credit_limit': _parseDouble(_creditLimitController.text),
        'payment_terms': _parseInt(_paymentTermsController.text),
        'is_active': _isActive,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      };

      if (widget.item != null) {
        managementBloc.add(UpdateSupplier(
          supplierId: (widget.item!['id'] ?? '').toString(),
          supplierData: supplierData,
        ));
      } else {
        managementBloc.add(CreateSupplier(supplierData: supplierData));
      }

      // refresh list
      managementBloc.add(LoadSuppliers());

      if (currentContext.mounted) {
        closeSheet(currentContext);
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              content: Text(widget.item != null
                  ? 'Supplier berhasil diperbarui'
                  : 'Supplier berhasil disimpan'),
              trailing: OurbitButton.primary(
                onPressed: () => overlay.close(),
                label: 'Tutup',
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
      }
    } catch (e) {
      if (currentContext.mounted) {
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              content: Text('Gagal menyimpan supplier: ${e.toString()}'),
              trailing: OurbitButton.primary(
                onPressed: () => overlay.close(),
                label: 'Tutup',
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.item != null;
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 520),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(isEditMode ? 'Edit Supplier' : 'Tambah Supplier')
                      .large()
                      .semiBold(),
                ),
                OurbitButton.ghost(
                  onPressed: _isSubmitting ? null : () => closeSheet(context),
                  label: 'Tutup',
                ),
              ],
            ),
            const Gap(16),
            Text(isEditMode
                    ? 'Edit detail supplier di bawah ini.'
                    : 'Isi detail supplier di bawah ini.')
                .muted(),
            const Gap(24),

            // Nama & Kode
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Supplier *',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Masukkan nama supplier',
                        controller: _nameController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kode Supplier',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Contoh: SUP001',
                        controller: _codeController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Kontak
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contact Person',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Nama contact person',
                        controller: _contactPersonController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'email@example.com',
                        controller: _emailController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor Telepon',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '+62 812-3456-7890',
                        controller: _phoneController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alamat',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Masukkan alamat lengkap',
                        controller: _addressController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Wilayah (ID sederhana)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kota (ID)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'ID kota (opsional)',
                        controller: _cityIdController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Provinsi (ID)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'ID provinsi (opsional)',
                        controller: _provinceIdController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Negara (ID)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'ID negara (opsional)',
                        controller: _countryIdController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NPWP',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '12.345.678.9-123.000',
                        controller: _taxNumberController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Bank info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Bank',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Contoh: BCA, Mandiri',
                        controller: _bankNameController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nomor Rekening',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '1234567890',
                        controller: _bankAccountNumberController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Pemilik Rekening',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Nama pemilik rekening',
                        controller: _bankAccountNameController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Limit Kredit',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '0',
                        controller: _creditLimitController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Term Pembayaran (hari)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '30',
                        controller: _paymentTermsController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Aktif',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitSwitchBuilder.withLabel(
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        label: 'Aktif',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Catatan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catatan',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextArea(
                  controller: _notesController,
                  placeholder: 'Tambahkan catatan tentang supplier (opsional)',
                  expandableHeight: true,
                  initialHeight: 100,
                ),
              ],
            ),
            const Gap(24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OurbitButton.outline(
                    onPressed: _isSubmitting ? null : () => closeSheet(context),
                    label: 'Batal',
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: OurbitButton.primary(
                    onPressed: _isSubmitting ? null : _submit,
                    label: isEditMode ? 'Perbarui Supplier' : 'Simpan',
                    isLoading: _isSubmitting,
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
