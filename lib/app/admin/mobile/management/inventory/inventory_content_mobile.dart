import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InventoryContentMobile extends StatefulWidget {
  const InventoryContentMobile({super.key});

  @override
  State<InventoryContentMobile> createState() => _InventoryContentMobileState();
}

class _InventoryContentMobileState extends State<InventoryContentMobile> {
  String _query = '';
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ManagementBloc>();
    bloc.add(LoadInventory());
    bloc.add(LoadCategories());
  }

  String _formatCurrency(num amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)}.000.000';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}.000';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  String _computeStatus(Product p) {
    if (p.stock <= 0) return 'out_of_stock';
    if (p.stock <= p.minStock) return 'low_stock';
    return 'in_stock';
  }

  Color _getStatusBaseColor(String status) {
    switch (status) {
      case 'out_of_stock':
        return Colors.red;
      case 'low_stock':
        return Colors.orange;
      case 'in_stock':
        return Colors.green;
      default:
        return Colors.gray;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'out_of_stock':
        return 'Habis';
      case 'low_stock':
        return 'Menipis';
      case 'in_stock':
        return 'Tersedia';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateStock(Product product, int newStock) async {
    final confirmed = await OurbitDialog.show(
      context: context,
      title: 'Update Stok',
      content: 'Update stok "${product.name}" menjadi $newStock?',
      confirmText: 'Update',
      cancelText: 'Batal',
    );
    if (confirmed != true) return;

    try {
      // TODO: Implement stock update logic
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Stok berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Gagal update stok'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStockUpdateDialog(Product product) {
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stok'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Produk: ${product.name}'),
            const SizedBox(height: 16),
            OurbitTextInput(
              controller: stockController,
              placeholder: 'Stok Baru',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null) {
                Navigator.of(context).pop();
                _updateStock(product, newStock);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showProductDetail(Product product) {
    final status = _computeStatus(product);
    material.showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                material.CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  child: Icon(
                    Icons.inventory_2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: material.Theme.of(context).brightness ==
                                  material.Brightness.dark
                              ? AppColors.darkPrimaryText
                              : AppColors.primaryText,
                        ),
                      ),
                      Text(
                        product.code ?? '—',
                        style: TextStyle(
                          color: material.Theme.of(context).brightness ==
                                  material.Brightness.dark
                              ? AppColors.darkSecondaryText
                              : AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Kategori', product.categoryName ?? '-'),
            _buildDetailRow('Stok Saat Ini', product.stock.toString()),
            _buildDetailRow('Stok Minimum', product.minStock.toString()),
            _buildDetailRow(
                'Harga Jual', _formatCurrency(product.sellingPrice)),
            _buildDetailRow(
                'Harga Beli', _formatCurrency(product.purchasePrice)),
            _buildDetailRow('Status', _getStatusText(status)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showStockUpdateDialog(product);
                    },
                    label: 'Update Stok',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OurbitButton.primary(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to product detail/edit
                    },
                    label: 'Edit Produk',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: material.Theme.of(context).brightness ==
                        material.Brightness.dark
                    ? AppColors.darkPrimaryText
                    : AppColors.primaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: material.Theme.of(context).brightness ==
                        material.Brightness.dark
                    ? AppColors.darkSecondaryText
                    : AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              OurbitTextInput(
                placeholder: 'Cari produk berdasarkan nama/SKU',
                leading: const Icon(Icons.search, size: 16),
                onChanged: (v) {
                  setState(() {
                    _query = (v ?? '').trim().toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OurbitSelect<String>(
                      value: _selectedCategory,
                      items: const ['all'],
                      itemBuilder: (context, item) => Text(
                        item == 'all' ? 'Semua Kategori' : item,
                      ),
                      placeholder: Text('Kategori'),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value ?? 'all');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OurbitSelect<String>(
                      value: _selectedStatus,
                      items: const [
                        'all',
                        'in_stock',
                        'low_stock',
                        'out_of_stock'
                      ],
                      itemBuilder: (context, item) => Text(
                        item == 'all'
                            ? 'Semua Status'
                            : item == 'in_stock'
                                ? 'Tersedia'
                                : item == 'low_stock'
                                    ? 'Menipis'
                                    : item == 'out_of_stock'
                                        ? 'Habis'
                                        : item,
                      ),
                      placeholder: Text('Status'),
                      onChanged: (value) {
                        setState(() => _selectedStatus = value ?? 'all');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Inventory List
        Expanded(
          child: BlocBuilder<ManagementBloc, ManagementState>(
            builder: (context, state) {
              if (state is ManagementLoading || state is ManagementInitial) {
                return const Center(
                  child: OurbitCircularProgress(),
                );
              }

              List<Product> products = [];
              if (state is InventoryLoaded) {
                products = state.inventory;
              }

              // Apply filters
              final filtered = products.where((p) {
                // Search filter
                if (_query.isNotEmpty) {
                  final name = p.name.toLowerCase();
                  final code = (p.code ?? '').toLowerCase();
                  if (!name.contains(_query) && !code.contains(_query)) {
                    return false;
                  }
                }

                // Category filter
                if (_selectedCategory != 'all') {
                  if (p.categoryName != _selectedCategory) {
                    return false;
                  }
                }

                // Status filter
                if (_selectedStatus != 'all') {
                  final status = _computeStatus(p);
                  if (status != _selectedStatus) {
                    return false;
                  }
                }

                return true;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada produk',
                    style: TextStyle(
                      color: material.Theme.of(context).brightness ==
                              material.Brightness.dark
                          ? AppColors.darkSecondaryText
                          : AppColors.secondaryText,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final status = _computeStatus(product);
                  final base = _getStatusBaseColor(status);

                  return OurbitCard(
                    child: material.ListTile(
                      leading: material.CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(
                          Icons.inventory_2,
                          color: Colors.blue,
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: material.Theme.of(context).brightness ==
                                  material.Brightness.dark
                              ? AppColors.darkPrimaryText
                              : AppColors.primaryText,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKU: ${product.code ?? '—'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: material.Theme.of(context).brightness ==
                                      material.Brightness.dark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kategori: ${product.categoryName ?? '—'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: material.Theme.of(context).brightness ==
                                      material.Brightness.dark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: material.Theme.of(context).brightness ==
                                      material.Brightness.dark
                                  ? AppColors.darkPrimaryText
                                  : AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: base.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: base),
                            ),
                            child: Text(
                              _getStatusText(status),
                              style: TextStyle(
                                fontSize: 12,
                                color: base,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _showProductDetail(product),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: material.Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: OurbitButton.primary(
              onPressed: () {
                // TODO: Implement stock opname
                material.ScaffoldMessenger.of(context).showSnackBar(
                  material.SnackBar(
                    content: Text('Fitur stock opname akan segera tersedia'),
                    backgroundColor:
                        material.Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              label: 'Stock Opname',
            ),
          ),
        ),
      ],
    );
  }
}
