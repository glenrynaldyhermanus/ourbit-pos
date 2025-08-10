import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_sku_generator.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';

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
  final TextEditingController _rackLocationController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _maxStockController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();

  bool _isActive = true;
  // bool _isPrescriptionRequired = false; // removed per web parity
  bool _isSubmitting = false;

  // Tambahan state agar mirip web
  String? _selectedCategoryId;
  String _selectedType = '';
  // removed local auto sku flag; handled by OurbitSKUGenerator
  File? _pickedImage;
  final List<Map<String, String>> _productTypes = const [
    {'key': 'goods', 'value': 'Barang'},
    {'key': 'service', 'value': 'Layanan'},
  ];

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
      _rackLocationController.text = widget.item!['rack_location'] ?? '';
      _minStockController.text = (widget.item!['min_stock'] ?? 0).toString();
      _maxStockController.text = widget.item!['max_stock']?.toString() ?? '';
      _shelfLifeController.text =
          widget.item!['shelf_life_days']?.toString() ?? '';
      _isActive = widget.item!['is_active'] ?? true;
      // removed per web parity
      _selectedCategoryId = widget.item!['category_id'];
      _selectedType = widget.item!['type'] ?? '';
    }

    // Load kategori saat sheet dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadCategories());
    });
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
    _rackLocationController.dispose();
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

    // Store context and bloc before async gap
    final currentContext = context;
    final managementBloc = context.read<ManagementBloc>();

    try {
      Logger.debug('FORM_SUBMIT: start');
      // Kumpulkan data form
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

      final Map<String, dynamic> productData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'category_id': _selectedCategoryId,
        'selling_price': _parseDouble(_priceController.text),
        'purchase_price': _parseDouble(_purchasePriceController.text),
        'stock': _parseInt(_stockController.text),
        'description': _descriptionController.text.trim(),
        'type': _selectedType,
        'unit': _unitController.text.trim(),
        'weight_grams': _parseInt(_weightController.text),
        'rack_location': _rackLocationController.text.trim(),
        'min_stock': _parseInt(_minStockController.text),
        'is_active': _isActive,
      };
      Logger.debug('FORM_SUBMIT: payload ${productData.toString()}');

      // Upload gambar ke Supabase Storage jika ada
      if (_pickedImage != null) {
        Logger.debug('FORM_SUBMIT: uploading image ${_pickedImage!.path}');
        final ext = _pickedImage!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
        final filePath = 'users/uploads/products/$fileName';
        final storage =
            Supabase.instance.client.storage.from('merchants-products');
        await storage.upload(filePath, _pickedImage!);
        final publicUrl = storage.getPublicUrl(filePath);
        productData['image_url'] = publicUrl;
        Logger.debug('FORM_SUBMIT: image uploaded url=$publicUrl');
      }

      if (widget.item != null) {
        Logger.debug('FORM_SUBMIT: dispatch UpdateProduct');
        managementBloc.add(UpdateProduct(
          productId: (widget.item!['id'] ?? '').toString(),
          productData: productData,
        ));
      } else {
        Logger.debug('FORM_SUBMIT: dispatch CreateProduct');
        managementBloc.add(CreateProduct(productData: productData));
      }

      // Reload list
      Logger.debug('FORM_SUBMIT: dispatch LoadProducts');
      managementBloc.add(LoadProducts());

      if (currentContext.mounted) {
        Logger.debug('FORM_SUBMIT: close sheet + show toast');
        closeSheet(currentContext);
        showToast(
          context: currentContext,
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
      Logger.error('FORM_SUBMIT_ERROR: ${e.toString()}');
      // Show error toast
      if (currentContext.mounted) {
        showToast(
          context: currentContext,
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

            // Gambar Produk (pakai image_picker)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gambar Produk',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.border,
                      width: 1,
                    ),
                    borderRadius: Theme.of(context).borderRadiusMd,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_pickedImage != null)
                        Image.file(_pickedImage!, fit: BoxFit.cover)
                      else
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                'Pilih gambar (maks 5MB)',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .mutedForeground,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: OurbitButton.outline(
                          onPressed: _isSubmitting
                              ? null
                              : () async {
                                  if (!kIsWeb &&
                                      (Platform.isMacOS ||
                                          Platform.isLinux ||
                                          Platform.isWindows)) {
                                    final result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false,
                                    );
                                    if (result != null &&
                                        result.files.isNotEmpty) {
                                      final path = result.files.single.path;
                                      if (path != null) {
                                        setState(() {
                                          _pickedImage = File(path);
                                        });
                                      }
                                    }
                                  } else {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      maxWidth: 1600,
                                      maxHeight: 1600,
                                      imageQuality: 85,
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _pickedImage = File(picked.path);
                                      });
                                    }
                                  }
                                },
                          label:
                              _pickedImage == null ? 'Pilih Gambar' : 'Ganti',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Nama Produk (sendiri)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Produk',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Masukkan nama produk',
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Kategori & Jenis Produk (baris kedua)
            BlocBuilder<ManagementBloc, ManagementState>(
              builder: (context, state) {
                List<Map<String, dynamic>> categories = [];
                if (state is CategoriesLoaded) {
                  categories = state.categories;
                }

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kategori',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Gap(8),
                          OurbitSelect<String>(
                            value: _selectedCategoryId,
                            items: categories
                                .map((c) => c['id'] as String)
                                .toList(),
                            placeholder: const Text('Tanpa Kategori'),
                            itemBuilder: (context, id) {
                              final name = categories
                                      .firstWhere((c) => c['id'] == id,
                                          orElse: () => {'name': '-'})['name']
                                      ?.toString() ??
                                  '-';
                              return Text(name);
                            },
                            onChanged: (value) {
                              setState(() => _selectedCategoryId = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jenis Produk',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const Gap(8),
                          OurbitSelect<String>(
                            value: _selectedType.isEmpty ? null : _selectedType,
                            items: _productTypes.map((e) => e['key']!).toList(),
                            placeholder: const Text('Pilih Jenis Produk'),
                            itemBuilder: (context, key) {
                              final value = _productTypes
                                  .firstWhere((t) => t['key'] == key)['value'];
                              return Text(value ?? key);
                            },
                            onChanged: (value) {
                              setState(() => _selectedType = value ?? '');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const Gap(16),

            // SKU Generator (setelah kategori/jenis seperti web)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kode Produk (SKU)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitSKUGenerator(
                  productName: _nameController.text,
                  currentSKU: _codeController.text,
                  categoryId: _selectedCategoryId,
                  categoryName: (() {
                    final ctx = context.read<ManagementBloc>().state;
                    if (ctx is CategoriesLoaded) {
                      final found = ctx.categories.firstWhere(
                        (c) => c['id'] == _selectedCategoryId,
                        orElse: () => {'name': null},
                      );
                      return found['name']?.toString();
                    }
                    return null;
                  })(),
                  onSKUChange: (value) {
                    _codeController.text = value;
                  },
                  onValidationChange: (ok, message) {
                    // Could disable submit based on ok if needed
                  },
                ),
              ],
            ),
            const Gap(16),

            // Harga Jual & Harga Beli (baris ketiga)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Harga Jual',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Masukkan harga jual',
                        controller: _priceController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Harga Beli',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'Masukkan harga beli',
                        controller: _purchasePriceController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Stok & Minimum Stok (baris keempat)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stok',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '0',
                        controller: _stockController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Minimum Stok',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '0',
                        controller: _minStockController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Satuan & Berat (baris kelima)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Satuan',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: 'PCS, KG, LITER, dll',
                        controller: _unitController,
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Berat (gram)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Gap(8),
                      OurbitTextInput(
                        placeholder: '0',
                        controller: _weightController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Letak Rak
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Letak Rak',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextInput(
                  placeholder: 'A1, B2, C3, dll',
                  controller: _rackLocationController,
                ),
              ],
            ),
            const Gap(16),

            // Deskripsi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Gap(8),
                OurbitTextArea(
                  controller: _descriptionController,
                  placeholder: 'Deskripsi produk (opsional)',
                  expandableHeight: true,
                  initialHeight: 120,
                ),
              ],
            ),
            const Gap(16),

            // Status Aktif
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

            const Gap(24),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OurbitButton.outline(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            closeSheet(context);
                          },
                    label: 'Batal',
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: OurbitButton.primary(
                    onPressed: _isSubmitting ? null : _submit,
                    label: isEditMode ? 'Perbarui Produk' : 'Simpan',
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
