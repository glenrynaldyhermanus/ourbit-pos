import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';

class ProductFormSheet extends StatefulWidget {
  final Map<String, dynamic>? item; // null untuk create, not null untuk edit

  const ProductFormSheet({super.key, this.item});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  // Controller untuk setiap field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _maxStockController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();

  bool _isActive = true;
  bool _isPrescriptionRequired = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      // Edit mode - populate fields with existing data
      _nameController.text = widget.item!['name'] ?? '';
      _codeController.text = widget.item!['code'] ?? '';
      _categoryController.text = widget.item!['category_name'] ?? '';
      _priceController.text = (widget.item!['price'] ?? 0.0).toString();
      _purchasePriceController.text =
          (widget.item!['purchase_price'] ?? 0.0).toString();
      _stockController.text = (widget.item!['stock'] ?? 0).toString();
      _unitController.text = widget.item!['unit'] ?? '';
      _weightController.text = (widget.item!['weight_grams'] ?? 0.0).toString();
      _discountController.text =
          (widget.item!['discount_value'] ?? 0.0).toString();
      _descriptionController.text = widget.item!['description'] ?? '';
      _minStockController.text = (widget.item!['min_stock'] ?? 0).toString();
      _maxStockController.text = widget.item!['max_stock']?.toString() ?? '';
      _shelfLifeController.text =
          widget.item!['shelf_life_days']?.toString() ?? '';
      _isActive = widget.item!['is_active'] ?? true;
      _isPrescriptionRequired =
          widget.item!['is_prescription_required'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _weightController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implement actual API call
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      // Reload products using BLoC
      context.read<ManagementBloc>().add(LoadProducts());

      // Close sheet
      closeSheet(context);

      // Show success toast
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              content: Text(widget.item != null
                  ? 'Produk berhasil diperbarui'
                  : 'Produk berhasil disimpan'),
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
      // Show error toast
      if (mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              content: Text(
                  'Gagal ${widget.item != null ? 'memperbarui' : 'menyimpan'} produk: ${e.toString()}'),
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
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.item != null;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 480),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(isEditMode ? 'Edit Produk' : 'Tambah Produk')
                      .large()
                      .semiBold(),
                ),
                OurbitButton.ghost(
                  onPressed: () => closeSheet(context),
                  label: 'Tutup',
                ),
              ],
            ),
            const Gap(16),
            Text(isEditMode
                    ? 'Edit detail produk di bawah ini.'
                    : 'Isi detail produk di bawah ini.')
                .muted(),
            const Gap(24),

            // Nama Produk
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Produk',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'Masukkan nama produk',
                  controller: _nameController,
                ),
              ],
            ),
            const Gap(16),

            // Kode Produk
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kode Produk',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'Masukkan kode produk (opsional)',
                  controller: _codeController,
                ),
              ],
            ),
            const Gap(16),

            // Kategori
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategori',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'Masukkan kategori produk',
                  controller: _categoryController,
                ),
              ],
            ),
            const Gap(16),

            // Harga Jual
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Harga Jual',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'Masukkan harga jual',
                  controller: _priceController,
                  features: const [
                    InputFeature.leading(Icon(Icons.attach_money)),
                  ],
                ),
              ],
            ),
            const Gap(16),

            // Harga Beli
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Harga Beli',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'Masukkan harga beli',
                  controller: _purchasePriceController,
                  features: const [
                    InputFeature.leading(Icon(Icons.attach_money)),
                  ],
                ),
              ],
            ),
            const Gap(16),

            // Stok
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stok',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'Masukkan jumlah stok',
                  controller: _stockController,
                  features: const [
                    InputFeature.leading(Icon(Icons.inventory)),
                  ],
                ),
              ],
            ),
            const Gap(16),

            // Status
            OurbitSwitchBuilder.withLabel(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              label: 'Status Aktif',
            ),
            const Gap(16),

            // Butuh Resep
            OurbitSwitchBuilder.withLabel(
              value: _isPrescriptionRequired,
              onChanged: (value) {
                setState(() {
                  _isPrescriptionRequired = value;
                });
              },
              label: 'Butuh Resep',
            ),
            const Gap(24),

            // Submit Button
            OurbitButton.primary(
              onPressed: _isSubmitting ? null : _submit,
              label: isEditMode ? 'Update Produk' : 'Simpan Produk',
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
