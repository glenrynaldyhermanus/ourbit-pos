import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/cashier_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';

class PosCart extends StatelessWidget {
  final CashierLoaded state;
  final VoidCallback onClearCart;
  final void Function(int index, int newQuantity) onUpdateQuantity;
  final VoidCallback onProcessPayment;

  const PosCart({
    super.key,
    required this.state,
    required this.onClearCart,
    required this.onUpdateQuantity,
    required this.onProcessPayment,
  });

  // Helper function untuk menggunakan system font
  TextStyle _getSystemFont({
    required double fontSize,
    material.FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == material.Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xff292524) : const Color(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Cart Header (Keranjang Belanja + Delete All)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondaryBackground
                  : AppColors.secondaryBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.shoppingCart,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Keranjang Belanja',
                      style: _getSystemFont(
                        fontSize: 18,
                        fontWeight: material.FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (state.cartItems.isNotEmpty)
                  OurbitButton.outline(
                    onPressed: onClearCart,
                    label: 'Hapus Semua',
                    height: 32,
                    leadingIcon: const Icon(
                      Icons.delete_outline,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Cart Items List (Expanded)
          Expanded(
            child: state.cartItems.isEmpty
                ? _buildEmptyCart(isDark)
                : _buildCartItems(isDark),
          ),
          // Cart Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondaryBackground
                  : AppColors.secondaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // Total row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: _getSystemFont(
                        fontSize: 16,
                        fontWeight: material.FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatCurrency(state.finalTotal),
                      style: _getSystemFont(
                        fontSize: 18,
                        fontWeight: material.FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Pay Button
                SizedBox(
                  width: double.infinity,
                  child: OurbitButton.primary(
                    onPressed:
                        state.cartItems.isNotEmpty ? onProcessPayment : null,
                    label: 'Bayar',
                    height: 48,
                    leadingIcon: const Icon(
                      Icons.payment,
                      size: 20,
                      color: AppColors.secondaryBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.shoppingCart,
            size: 64,
            color:
                isDark ? AppColors.darkSecondaryText : AppColors.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: _getSystemFont(
              fontSize: 18,
              fontWeight: material.FontWeight.w600,
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih produk untuk menambahkan ke keranjang',
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
    );
  }

  Widget _buildCartItems(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.cartItems.length,
      itemBuilder: (context, index) {
        final item = state.cartItems[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondaryBackground
                  : AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Product image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkMuted.withValues(alpha: 0.2)
                        : AppColors.muted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: item.product.imageUrl != null &&
                          item.product.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            item.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildProductIcon(isDark);
                            },
                          ),
                        )
                      : _buildProductIcon(isDark),
                ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: _getSystemFont(
                          fontSize: 14,
                          fontWeight: material.FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(item.product.sellingPrice),
                        style: _getSystemFont(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: material.FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Quantity controls
                Row(
                  children: [
                    OurbitIconButton.destructive(
                      onPressed: () =>
                          onUpdateQuantity(index, item.quantity - 1),
                      icon: const Icon(
                        Icons.remove,
                        size: 16,
                      ),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    // Quantity display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceBackground
                            : AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xff292524)
                              : const Color(0xFFE5E7EB),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: _getSystemFont(
                          fontSize: 12,
                          fontWeight: material.FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OurbitIconButton.primary(
                      onPressed: () =>
                          onUpdateQuantity(index, item.quantity + 1),
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                      ),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductIcon(bool isDark) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 20,
        color: AppColors.primary,
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(0)}.000.000';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}.000';
    } else {
      return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
}
