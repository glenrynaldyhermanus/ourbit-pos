import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';

class CategoryFormSheet extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CategoryFormSheet({super.key, this.category});

  @override
  State<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<CategoryFormSheet> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Nama kategori wajib diisi');
      }
      final payload = {
        'name': name,
      };
      if ((widget.category?['id'] as String?)?.isNotEmpty == true) {
        managementBloc.add(UpdateCategory(
          categoryId: widget.category!['id'].toString(),
          categoryData: payload,
        ));
      } else {
        managementBloc.add(CreateCategory(categoryData: payload));
      }
      managementBloc.add(LoadCategories());

      if (mounted && currentContext.mounted) {
        // Tutup sheet terlebih dahulu, lalu tampilkan toast
        closeSheet(currentContext);
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
              trailing: OurbitButton.primary(
                onPressed: () => overlay.close(),
                label: 'Tutup',
              ),
            ),
          ),
          location: ToastLocation.topCenter,
        );
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
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      widget.category != null
                          ? 'Edit Kategori'
                          : 'Tambah Kategori',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    OurbitButton.ghost(
                      onPressed: () => closeSheet(context),
                      label: 'Tutup',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Body (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Footer (pinned at bottom)
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
                        onPressed: _isLoading ? null : _saveCategory,
                        label: widget.category != null ? 'Simpan' : 'Tambah',
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
