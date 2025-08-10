import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';

class CustomerFormSheet extends StatefulWidget {
  final Map<String, dynamic>? customer;

  const CustomerFormSheet({super.key, this.customer});

  @override
  State<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _taxNumberController = TextEditingController();
  final TextEditingController _creditLimitController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _customerType = 'retail';
  String? _cityId;
  String? _provinceId;
  String? _countryId;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!['name'] ?? '';
      _codeController.text = widget.customer!['code'] ?? '';
      _emailController.text = widget.customer!['email'] ?? '';
      _phoneController.text = widget.customer!['phone'] ?? '';
      _addressController.text = widget.customer!['address'] ?? '';
      _taxNumberController.text = widget.customer!['tax_number'] ?? '';
      _creditLimitController.text =
          (widget.customer!['credit_limit'] ?? 0).toString();
      _paymentTermsController.text =
          (widget.customer!['payment_terms'] ?? 0).toString();
      _notesController.text = widget.customer!['notes'] ?? '';
      _customerType =
          (widget.customer!['customer_type'] ?? 'retail').toString();
      _cityId = widget.customer!['city_id'];
      _provinceId = widget.customer!['province_id'];
      _countryId = widget.customer!['country_id'];
      _isActive = widget.customer!['is_active'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Store context and bloc before async gap
    final currentContext = context;
    final managementBloc = context.read<ManagementBloc>();

    try {
      // Basic validation
      if (_nameController.text.trim().isEmpty) {
        throw Exception('Nama pelanggan wajib diisi');
      }

      num _parseNum(String text) {
        final t = text.trim();
        if (t.isEmpty) return 0;
        final d = num.tryParse(t);
        return d ?? 0;
      }

      final Map<String, dynamic> payload = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'city_id': _cityId,
        'province_id': _provinceId,
        'country_id': _countryId,
        'tax_number': _taxNumberController.text.trim().isEmpty
            ? null
            : _taxNumberController.text.trim(),
        'customer_type': _customerType,
        'credit_limit': _parseNum(_creditLimitController.text),
        'payment_terms': _parseNum(_paymentTermsController.text),
        'is_active': _isActive,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      };

      if (widget.customer != null) {
        managementBloc.add(UpdateCustomer(
          customerId: (widget.customer!['id'] ?? '').toString(),
          customerData: payload,
        ));
      } else {
        managementBloc.add(CreateCustomer(customerData: payload));
      }

      managementBloc.add(LoadCustomers());

      if (mounted && currentContext.mounted) {
        closeSheet(currentContext);
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              content: Text(widget.customer != null
                  ? 'Pelanggan berhasil diperbarui'
                  : 'Pelanggan berhasil ditambahkan'),
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
      if (mounted && currentContext.mounted) {
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              content: Text('Gagal menyimpan pelanggan: ${e.toString()}'),
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
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.customer != null
                        ? 'Edit Pelanggan'
                        : 'Tambah Pelanggan',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                OurbitButton.ghost(
                  onPressed: () => closeSheet(context),
                  label: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form fields
            Column(
              children: [
                // Name field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Pelanggan',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextInput(
                      placeholder: 'Masukkan nama pelanggan',
                      controller: _nameController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Code field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kode Pelanggan',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextInput(
                      placeholder: 'Contoh: CUST001',
                      controller: _codeController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextInput(
                      placeholder: 'Masukkan email pelanggan',
                      controller: _emailController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Telepon',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextInput(
                      placeholder: 'Masukkan nomor telepon',
                      controller: _phoneController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Address field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alamat',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextArea(
                      placeholder: 'Masukkan alamat pelanggan',
                      controller: _addressController,
                      expandableHeight: true,
                      initialHeight: 100,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // NPWP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NPWP',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextInput(
                      placeholder: '12.345.678.9-123.000',
                      controller: _taxNumberController,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Customer Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipe Pelanggan',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OurbitButton.outline(
                          onPressed: () =>
                              setState(() => _customerType = 'retail'),
                          label: 'Retail',
                        ),
                        const SizedBox(width: 8),
                        OurbitButton.outline(
                          onPressed: () =>
                              setState(() => _customerType = 'wholesale'),
                          label: 'Grosir',
                        ),
                        const SizedBox(width: 8),
                        OurbitButton.outline(
                          onPressed: () =>
                              setState(() => _customerType = 'corporate'),
                          label: 'Korporat',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Credit limit & Payment terms
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Limit Kredit',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          OurbitTextInput(
                            placeholder: '0',
                            controller: _creditLimitController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Term Pembayaran (hari)',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          OurbitTextInput(
                            placeholder: '0',
                            controller: _paymentTermsController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active status
                OurbitSwitchBuilder.withLabel(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  label: 'Status Aktif',
                ),
                const SizedBox(height: 16),

                // Notes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catatan',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OurbitTextArea(
                      controller: _notesController,
                      placeholder:
                          'Tambahkan catatan tentang pelanggan (opsional)',
                      expandableHeight: true,
                      initialHeight: 100,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OurbitButton.outline(
                    onPressed: () => closeSheet(context),
                    label: 'Batal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OurbitButton.primary(
                    onPressed: _isSubmitting ? null : _saveCustomer,
                    label: widget.customer != null
                        ? 'Perbarui Pelanggan'
                        : 'Simpan',
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
