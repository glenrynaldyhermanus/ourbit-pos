import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';

class CategoryFormSheet extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryFormSheet({super.key, this.category});

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'item';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _descriptionController.text = widget.category!['description'] ?? '';
      _selectedType = widget.category!['type'] ?? 'item';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    setState(() {
      _isLoading = true;
    });

    // Store context and bloc before async gap
    final currentContext = context;
    final managementBloc = context.read<ManagementBloc>();

    try {
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      // Reload categories using BLoC
      managementBloc.add(LoadCategories());

      if (mounted && currentContext.mounted) {
        // Show success toast first
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Berhasil'),
              content: Text(
                widget.category != null
                    ? 'Kategori berhasil diperbarui'
                    : 'Kategori berhasil ditambahkan',
              ),
              trailing: Button.primary(
                onPressed: () => overlay.close(),
                child: const Text('Tutup'),
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
        closeSheet(currentContext);
      }

      // Close sheet after showing toast
    } catch (e) {
      // Show error toast
      if (mounted && currentContext.mounted) {
        showToast(
          context: currentContext,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error'),
              content: Text('Gagal menyimpan kategori: ${e.toString()}'),
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
      width: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.category_outlined,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.category != null ? 'Edit Kategori' : 'Tambah Kategori',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Button.ghost(
                onPressed: () => closeSheet(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nama Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              OurbitTextInput(
                placeholder: 'Masukkan nama kategori',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tipe Kategori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              OurbitSelect<String>(
                items: const ['item', 'service'],
                itemBuilder: (context, item) => Text(
                  item == 'item' ? 'Produk' : 'Jasa',
                ),
                placeholder: const Text('Pilih tipe kategori'),
                value: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value ?? 'item';
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Deskripsi (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              OurbitTextInput(
                placeholder: 'Masukkan deskripsi kategori',
                controller: _descriptionController,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Button.outline(
                  onPressed: () => closeSheet(context),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Button.primary(
                  onPressed: _isLoading ? null : _saveCategory,
                  child: Text(widget.category != null ? 'Simpan' : 'Tambah'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
