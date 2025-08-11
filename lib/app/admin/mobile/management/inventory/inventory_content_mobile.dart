import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';

class InventoryContentMobile extends material.StatefulWidget {
  const InventoryContentMobile({super.key});

  @override
  material.State<InventoryContentMobile> createState() =>
      _InventoryContentMobileState();
}

class _InventoryContentMobileState
    extends material.State<InventoryContentMobile> {
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

  material.Color _getStatusBaseColor(String status) {
    switch (status) {
      case 'out_of_stock':
        return material.Colors.red;
      case 'low_stock':
        return material.Colors.orange;
      case 'in_stock':
        return material.Colors.green;
      default:
        return material.Colors.grey;
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
          content: material.Text('Stok berhasil diupdate'),
          backgroundColor: material.Colors.green,
        ),
      );
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Gagal update stok'),
          backgroundColor: material.Colors.red,
        ),
      );
    }
  }

  void _showStockUpdateDialog(Product product) {
    final stockController = material.TextEditingController(
      text: product.stock.toString(),
    );

    material.showDialog(
      context: context,
      builder: (context) => material.AlertDialog(
        title: material.Text('Update Stok'),
        content: material.Column(
          mainAxisSize: material.MainAxisSize.min,
          children: [
            material.Text('Produk: ${product.name}'),
            const material.SizedBox(height: 16),
            material.TextField(
              controller: stockController,
              decoration: const material.InputDecoration(
                labelText: 'Stok Baru',
                border: material.OutlineInputBorder(),
              ),
              keyboardType: material.TextInputType.number,
            ),
          ],
        ),
        actions: [
          material.TextButton(
            onPressed: () => material.Navigator.of(context).pop(),
            child: const material.Text('Batal'),
          ),
          material.TextButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null) {
                material.Navigator.of(context).pop();
                _updateStock(product, newStock);
              }
            },
            child: const material.Text('Update'),
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
      builder: (context) => material.Container(
        padding: const material.EdgeInsets.all(16),
        child: material.Column(
          mainAxisSize: material.MainAxisSize.min,
          crossAxisAlignment: material.CrossAxisAlignment.start,
          children: [
            material.Row(
              children: [
                material.CircleAvatar(
                  backgroundColor: material.Colors.blue.shade50,
                  child: material.Icon(
                    material.Icons.inventory_2,
                    color: material.Colors.blue,
                  ),
                ),
                const material.SizedBox(width: 12),
                material.Expanded(
                  child: material.Column(
                    crossAxisAlignment: material.CrossAxisAlignment.start,
                    children: [
                      material.Text(
                        product.name,
                        style: const material.TextStyle(
                          fontSize: 18,
                          fontWeight: material.FontWeight.bold,
                        ),
                      ),
                      material.Text(
                        product.code ?? '—',
                        style: material.TextStyle(
                          color: material.Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const material.SizedBox(height: 16),
            _buildDetailRow('Kategori', product.categoryName ?? '-'),
            _buildDetailRow('Stok Saat Ini', product.stock.toString()),
            _buildDetailRow('Stok Minimum', product.minStock.toString()),
            _buildDetailRow(
                'Harga Jual', _formatCurrency(product.sellingPrice)),
            _buildDetailRow(
                'Harga Beli', _formatCurrency(product.purchasePrice)),
            _buildDetailRow('Status', _getStatusText(status)),
            const material.SizedBox(height: 16),
            material.Row(
              children: [
                material.Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      _showStockUpdateDialog(product);
                    },
                    label: 'Update Stok',
                  ),
                ),
                const material.SizedBox(width: 8),
                material.Expanded(
                  child: OurbitButton.primary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
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

  material.Widget _buildDetailRow(String label, String value) {
    return material.Padding(
      padding: const material.EdgeInsets.symmetric(vertical: 4),
      child: material.Row(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          material.SizedBox(
            width: 100,
            child: material.Text(
              label,
              style: const material.TextStyle(
                fontWeight: material.FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          material.Expanded(
            child: material.Text(
              value,
              style: const material.TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.Column(
      children: [
        // Search and Filters
        material.Padding(
          padding: const material.EdgeInsets.all(16),
          child: material.Column(
            children: [
              OurbitTextInput(
                placeholder: 'Cari produk berdasarkan nama/SKU',
                leading: const material.Icon(material.Icons.search, size: 16),
                onChanged: (v) {
                  setState(() {
                    _query = (v ?? '').trim().toLowerCase();
                  });
                },
              ),
              const material.SizedBox(height: 12),
              material.Row(
                children: [
                  material.Expanded(
                    child: material.DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const material.InputDecoration(
                        border: material.OutlineInputBorder(),
                        contentPadding: material.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        labelText: 'Kategori',
                      ),
                      items: const [
                        material.DropdownMenuItem(
                          value: 'all',
                          child: material.Text('Semua Kategori'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value ?? 'all');
                      },
                    ),
                  ),
                  const material.SizedBox(width: 8),
                  material.Expanded(
                    child: material.DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const material.InputDecoration(
                        border: material.OutlineInputBorder(),
                        contentPadding: material.EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        labelText: 'Status',
                      ),
                      items: const [
                        material.DropdownMenuItem(
                          value: 'all',
                          child: material.Text('Semua Status'),
                        ),
                        material.DropdownMenuItem(
                          value: 'in_stock',
                          child: material.Text('Tersedia'),
                        ),
                        material.DropdownMenuItem(
                          value: 'low_stock',
                          child: material.Text('Menipis'),
                        ),
                        material.DropdownMenuItem(
                          value: 'out_of_stock',
                          child: material.Text('Habis'),
                        ),
                      ],
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
        material.Expanded(
          child: BlocBuilder<ManagementBloc, ManagementState>(
            builder: (context, state) {
              if (state is ManagementLoading || state is ManagementInitial) {
                return const material.Center(
                  child: material.CircularProgressIndicator(),
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
                return const material.Center(
                  child: material.Text('Tidak ada produk'),
                );
              }

              return material.ListView.separated(
                padding: const material.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const material.SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = filtered[index];
                  final status = _computeStatus(product);
                  final base = _getStatusBaseColor(status);

                  return material.Card(
                    child: material.ListTile(
                      leading: material.CircleAvatar(
                        backgroundColor: material.Colors.blue.shade50,
                        child: material.Icon(
                          material.Icons.inventory_2,
                          color: material.Colors.blue,
                        ),
                      ),
                      title: material.Text(
                        product.name,
                        style: const material.TextStyle(
                          fontWeight: material.FontWeight.w600,
                        ),
                      ),
                      subtitle: material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          material.Text(
                            'SKU: ${product.code ?? '—'}',
                            style: material.TextStyle(
                              fontSize: 12,
                              color: material.Colors.grey[600],
                            ),
                          ),
                          const material.SizedBox(height: 4),
                          material.Text(
                            'Kategori: ${product.categoryName ?? '—'}',
                            style: material.TextStyle(
                              fontSize: 12,
                              color: material.Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: material.Column(
                        mainAxisAlignment: material.MainAxisAlignment.center,
                        crossAxisAlignment: material.CrossAxisAlignment.end,
                        children: [
                          material.Text(
                            'Stok: ${product.stock}',
                            style: const material.TextStyle(
                              fontWeight: material.FontWeight.bold,
                            ),
                          ),
                          const material.SizedBox(height: 4),
                          material.Container(
                            padding: const material.EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: material.BoxDecoration(
                              color: base.withValues(alpha: 0.08),
                              borderRadius: material.BorderRadius.circular(12),
                              border: material.Border.all(color: base),
                            ),
                            child: material.Text(
                              _getStatusText(status),
                              style: material.TextStyle(
                                fontSize: 12,
                                color: base,
                                fontWeight: material.FontWeight.w500,
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
        material.Container(
          padding: const material.EdgeInsets.all(16),
          decoration: material.BoxDecoration(
            color: material.Colors.white,
            boxShadow: [
              material.BoxShadow(
                color: material.Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const material.Offset(0, -2),
              ),
            ],
          ),
          child: material.SizedBox(
            width: double.infinity,
            child: OurbitButton.primary(
              onPressed: () {
                // TODO: Implement stock opname
                material.ScaffoldMessenger.of(context).showSnackBar(
                  material.SnackBar(
                    content: material.Text(
                        'Fitur stock opname akan segera tersedia'),
                    backgroundColor: material.Colors.blue,
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
