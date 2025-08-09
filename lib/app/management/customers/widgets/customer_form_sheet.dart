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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!['name'] ?? '';
      _emailController.text = widget.customer!['email'] ?? '';
      _phoneController.text = widget.customer!['phone'] ?? '';
      _addressController.text = widget.customer!['address'] ?? '';
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
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Store context and bloc before async gap
    final currentContext = context;
    final managementBloc = context.read<ManagementBloc>();

    try {
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      // Reload customers using BLoC
      managementBloc.add(LoadCustomers());

      if (mounted && currentContext.mounted) {
        // Close sheet
        closeSheet(currentContext);

        // Show success toast
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              content: Text(widget.customer != null
                  ? 'Pelanggan berhasil diperbarui'
                  : 'Pelanggan berhasil ditambahkan'),
              trailing: Button.primary(
                onPressed: () => overlay.close(),
                child: const Text('Tutup'),
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
      }
    } catch (e) {
      // Show error toast
      if (mounted && currentContext.mounted) {
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              content: Text('Gagal menyimpan pelanggan: ${e.toString()}'),
              trailing: Button.primary(
                onPressed: () => overlay.close(),
                child: const Text('Tutup'),
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(24),
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
                  onPressed: _isLoading ? null : _saveCustomer,
                  label: widget.customer != null ? 'Simpan' : 'Tambah',
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
