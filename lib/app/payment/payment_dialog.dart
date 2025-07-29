import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

import 'package:ourbit_pos/src/widgets/ourbit_button.dart';

class PaymentDialog extends StatefulWidget {
  final double total;
  final Function(String) onPaymentMethodSelected;
  final VoidCallback onProcessPayment;

  const PaymentDialog({
    super.key,
    required this.total,
    required this.onPaymentMethodSelected,
    required this.onProcessPayment,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedMethod = 'Cash';
  final _amountController = TextEditingController();

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      name: 'Cash',
      icon: Icons.money,
      description: 'Cash payment',
    ),
    PaymentMethod(
      name: 'Credit Card',
      icon: Icons.credit_card,
      description: 'Credit card payment',
    ),
    PaymentMethod(
      name: 'Debit Card',
      icon: Icons.credit_card_outlined,
      description: 'Debit card payment',
    ),
    PaymentMethod(
      name: 'Digital Wallet',
      icon: Icons.account_balance_wallet,
      description: 'Digital wallet payment',
    ),
    PaymentMethod(
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      description: 'Bank transfer payment',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.payment,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Payment Details',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Total amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkPrimaryText
                          : AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '\$${widget.total.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment methods
            Text(
              'Select Payment Method',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),

            // Payment method grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedMethod == method.name;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMethod = method.name;
                    });
                    widget.onPaymentMethodSelected(method.name);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : (isDark ? AppColors.darkMuted : AppColors.muted),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          method.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.secondaryText,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                method.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.darkPrimaryText
                                          : AppColors.primaryText),
                                ),
                              ),
                              Text(
                                method.description,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Amount received (for cash payments)
            if (_selectedMethod == 'Cash') ...[
              Text(
                'Amount Received',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkPrimaryText
                      : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount received',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (double.tryParse(_amountController.text) != null &&
                  double.parse(_amountController.text) > widget.total)
                Text(
                  'Change: \$${(double.parse(_amountController.text) - widget.total).toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OurbitOutlineButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OurbitPrimaryButton(
                    text: 'Process Payment',
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onProcessPayment();
                    },
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

class PaymentMethod {
  final String name;
  final IconData icon;
  final String description;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.description,
  });
}
