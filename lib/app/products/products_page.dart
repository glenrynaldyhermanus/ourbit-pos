import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_event.dart';
import 'package:ourbit_pos/blocs/cashier_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/widgets/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ourbit_input.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  Product? _editingProduct;
  final _formKey = GlobalKey<FormState>();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Helper function untuk menggunakan system font
  TextStyle _getSystemFont({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  void dispose() {
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startEditing(Product product) {
    setState(() {
      _editingProduct = product;
      _sellingPriceController.text = product.sellingPrice.toString();
      _stockController.text = product.stock.toString();
      _minStockController.text = product.minStock.toString();
      _descriptionController.text = product.description ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingProduct = null;
      _sellingPriceController.clear();
      _stockController.clear();
      _minStockController.clear();
      _descriptionController.clear();
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate() && _editingProduct != null) {
      try {
        // TODO: Implement update product use case
        // await _updateProductUseCase(
        //   productId: _editingProduct!.id,
        //   sellingPrice: double.parse(_sellingPriceController.text),
        //   stock: int.parse(_stockController.text),
        //   minStock: int.parse(_minStockController.text),
        //   description: _descriptionController.text,
        // );

        // Reload products
        context.read<CashierBloc>().add(LoadProducts());

        _cancelEditing();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating product: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Products Management',
          style: _getSystemFont(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkPrimaryBackground
            : AppColors.primaryBackground,
        elevation: 0,
      ),
      body: Container(
        color: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.surfaceBackground,
        child: BlocBuilder<CashierBloc, CashierState>(
          builder: (context, state) {
            if (state is CashierLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CashierError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading products',
                      style: _getSystemFont(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: _getSystemFont(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OurbitButton(
                      text: 'Retry',
                      onPressed: () =>
                          context.read<CashierBloc>().add(LoadProducts()),
                    ),
                  ],
                ),
              );
            }

            if (state is CashierLoaded) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Products List
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Products (${state.products.length})',
                            style: _getSystemFont(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.products.length,
                              itemBuilder: (context, index) {
                                final product = state.products[index];
                                final isEditing =
                                    _editingProduct?.id == product.id;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: OurbitCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Product Image
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? AppColors.darkMuted
                                                      .withValues(alpha: 0.2)
                                                  : AppColors.muted
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: product.imageUrl != null &&
                                                    product.imageUrl!.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      product.imageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Icon(
                                                          Icons
                                                              .inventory_2_outlined,
                                                          size: 24,
                                                          color:
                                                              AppColors.primary,
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.inventory_2_outlined,
                                                    size: 24,
                                                    color: AppColors.primary,
                                                  ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Product Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: _getSystemFont(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  product.categoryName ??
                                                      'Uncategorized',
                                                  style: _getSystemFont(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? AppColors
                                                            .darkSecondaryText
                                                        : AppColors
                                                            .secondaryText,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Rp ${_formatCurrency(product.sellingPrice)}',
                                                      style: _getSystemFont(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(
                                                      'Stock: ${product.stock}',
                                                      style: _getSystemFont(
                                                        fontSize: 12,
                                                        color: isDark
                                                            ? AppColors
                                                                .darkSecondaryText
                                                            : AppColors
                                                                .secondaryText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Edit Button
                                          OurbitButton(
                                            text: isEditing ? 'Cancel' : 'Edit',
                                            variant: isEditing
                                                ? OurbitButtonVariant.secondary
                                                : OurbitButtonVariant.outline,
                                            size: OurbitButtonSize.small,
                                            onPressed: () {
                                              if (isEditing) {
                                                _cancelEditing();
                                              } else {
                                                _startEditing(product);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Edit Form
                    Expanded(
                      flex: 1,
                      child: _editingProduct != null
                          ? _buildEditForm(isDark)
                          : _buildEmptyEditForm(isDark),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildEditForm(bool isDark) {
    return OurbitCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Product',
                style: _getSystemFont(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _editingProduct!.name,
                style: _getSystemFont(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              // Selling Price
              OurbitInput(
                label: 'Selling Price',
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter selling price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Stock
              OurbitInput(
                label: 'Stock',
                controller: _stockController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.inventory),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) < 0) {
                    return 'Stock cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Min Stock
              OurbitInput(
                label: 'Min Stock',
                controller: _minStockController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.warning),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter min stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) < 0) {
                    return 'Min stock cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Description
              OurbitInput(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.description),
              ),
              const Spacer(),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: OurbitButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyEditForm(bool isDark) {
    return OurbitCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 64,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a product to edit',
              style: _getSystemFont(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click the Edit button on any product to modify its details',
              style: _getSystemFont(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkSecondaryText
                    : AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}.000.000';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}.000';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
