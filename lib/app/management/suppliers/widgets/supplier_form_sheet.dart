import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';

class SupplierFormSheet extends StatefulWidget {
  final Map<String, dynamic>? supplier;

  const SupplierFormSheet({super.key, this.supplier});

  @override
  State<SupplierFormSheet> createState() => _SupplierFormSheetState();
}

class _SupplierFormSheetState extends State<SupplierFormSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplier != null) {
      _nameController.text = widget.supplier!['name'] ?? '';
      _emailController.text = widget.supplier!['email'] ?? '';
      _phoneController.text = widget.supplier!['phone'] ?? '';
      _addressController.text = widget.supplier!['address'] ?? '';
      _isActive = widget.supplier!['is_active'] ?? true;
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

  Future<void> _saveSupplier() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      _showErrorToast('Nama supplier harus diisi');
      return;
    }

    if (_emailController.text.trim().isNotEmpty) {
      // Simple email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        _showErrorToast('Format email tidak valid');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual API call
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      // Reload suppliers using BLoC
      context.read<ManagementBloc>().add(LoadSuppliers());

      // Close sheet
      if (mounted) {
        closeSheet(context);

        // Show success toast
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              content: Text(widget.supplier != null
                  ? 'Supplier berhasil diperbarui'
                  : 'Supplier berhasil ditambahkan'),
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
      _showErrorToast('Gagal menyimpan supplier: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorToast(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(
          title: const Text('Error'),
          content: Text(message),
          trailing: OurbitButton.primary(
            onPressed: () => overlay.close(),
            label: 'Tutup',
          ),
        ),
      ),
      location: ToastLocation.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.supplier != null ? 'Edit Supplier' : 'Tambah Supplier',
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Name field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nama Supplier',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OurbitTextInput(
                        placeholder: 'Masukkan nama supplier',
                        controller: _nameController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OurbitTextInput(
                        placeholder: 'Masukkan email supplier',
                        controller: _emailController,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Telepon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                      const Text(
                        'Alamat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OurbitTextArea(
                        placeholder: 'Masukkan alamat supplier',
                        controller: _addressController,
                        initialHeight: 100,
                        expandableHeight: true,
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

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
                  onPressed: _isLoading ? null : _saveSupplier,
                  label: widget.supplier != null ? 'Simpan' : 'Tambah',
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
