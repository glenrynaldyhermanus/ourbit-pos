import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/blocs/payment_bloc.dart';
import 'package:ourbit_pos/src/core/services/printer_service.dart';
import 'package:ourbit_pos/src/core/services/receipt_pdf_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class PaymentPageMobile extends StatefulWidget {
  const PaymentPageMobile({super.key});

  @override
  State<PaymentPageMobile> createState() => _PaymentPageMobileState();
}

class _PaymentPageMobileState extends State<PaymentPageMobile>
    with material.TickerProviderStateMixin {
  late material.AnimationController _animationController;
  late material.Animation<double> _fadeAnimation;
  String salesDraftNote = '';
  Map<String, dynamic>? selectedPaymentMethod;
  List<Map<String, dynamic>> _lastCartItems = const [];
  double _lastSubtotal = 0.0;
  double _lastTax = 0.0;
  double _lastTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = material.AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = material.Tween<double>(begin: 0.0, end: 1.0).animate(
      material.CurvedAnimation(parent: _animationController, curve: material.Curves.easeInOut),
    );
    context.read<PaymentBloc>().add(LoadPaymentData());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double _calculateSubtotal(List<Map<String, dynamic>> cartItems) {
    return cartItems.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double _calculateTax(double subtotal) => subtotal * 0.11;

  double _calculateTotal(double subtotal, double tax) => subtotal + tax;

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }



  void _processPayment(List<Map<String, dynamic>> cartItems, double subtotal,
      double tax, double total) {
    if (selectedPaymentMethod == null) {
      OurbitToast.warning(
        context: context,
        title: 'Perhatian',
        content: 'Pilih metode pembayaran terlebih dahulu',
      );
      return;
    }

    context.read<PaymentBloc>().add(ProcessPayment(
          cartItems: cartItems,
          subtotal: subtotal,
          tax: tax,
          total: total,
          paymentMethodId: selectedPaymentMethod!['payment_method_id'],
          salesNotes: salesDraftNote,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor: material.Colors.grey[50],
      appBar: material.AppBar(
        title: const material.Text('Pembayaran'),
        backgroundColor: material.Colors.white,
        elevation: 0,
        leading: material.IconButton(
          icon: const material.Icon(material.Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoaded) {
            _animationController.forward();
          } else if (state is PaymentSuccess) {
            if (_lastCartItems.isNotEmpty && _lastTotal > 0) {
              (() async {
                try {
                  if (material.Theme.of(context).platform == material.TargetPlatform.android ||
                      material.Theme.of(context).platform == material.TargetPlatform.iOS) {
                    await PrinterService.instance.printReceipt(
                      title: 'Struk Pembelian',
                      items: _lastCartItems,
                      subtotal: _lastSubtotal,
                      tax: _lastTax,
                      total: _lastTotal,
                      footerNote: 'ID Transaksi: ${state.saleId}',
                    );
                  } else {
                    await ReceiptPdfService.instance.printReceipt(
                      title: 'Struk Pembelian',
                      items: _lastCartItems,
                      subtotal: _lastSubtotal,
                      tax: _lastTax,
                      total: _lastTotal,
                      footerNote: 'ID Transaksi: ${state.saleId}',
                    );
                  }
                } catch (e) {
                  OurbitToast.error(
                    context: context,
                    title: 'Gagal',
                    content: 'Cetak gagal: $e',
                  );
                }
              })();
            }
            context.go('/success');
          } else if (state is PaymentError) {
            OurbitToast.error(
              context: context,
              title: 'Gagal',
              content: 'Error: ${state.message}',
            );
          }
        },
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading || state is PaymentInitial) {
              return const material.Center(child: material.CircularProgressIndicator());
            }

            if (state is PaymentError) {
              return material.Center(
                child: material.Column(
                  mainAxisAlignment: material.MainAxisAlignment.center,
                  children: [
                    material.Icon(material.Icons.error_outline, size: 64, color: material.Colors.red[400]),
                    const material.SizedBox(height: 16),
                    material.Text('Error: ${state.message}'),
                    const material.SizedBox(height: 16),
                    material.ElevatedButton(
                      onPressed: () =>
                          context.read<PaymentBloc>().add(LoadPaymentData()),
                      child: const material.Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final cartItems = state is PaymentLoaded
                ? state.cartItems
                : <Map<String, dynamic>>[];
            final storePaymentMethods = state is PaymentLoaded
                ? state.storePaymentMethods
                : <Map<String, dynamic>>[];
            final isProcessing = state is PaymentProcessing;

            final subtotal = _calculateSubtotal(cartItems);
            final tax = _calculateTax(subtotal);
            final total = _calculateTotal(subtotal, tax);

            // Store snapshot for printing
            _lastCartItems = cartItems;
            _lastSubtotal = subtotal;
            _lastTax = tax;
            _lastTotal = total;

            return material.FadeTransition(
              opacity: _fadeAnimation,
              child: material.SingleChildScrollView(
                padding: const material.EdgeInsets.all(16),
                child: material.Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    OurbitCard(
                      child: material.Padding(
                        padding: const material.EdgeInsets.all(16),
                        child: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            material.Row(
                              children: [
                                material.Icon(material.Icons.receipt_long,
                                    color: material.Colors.orange[600]),
                                const material.SizedBox(width: 12),
                                const material.Text(
                                  'Ringkasan Pesanan',
                                  style: material.TextStyle(
                                    fontSize: 18,
                                    fontWeight: material.FontWeight.bold,
                                    color: material.Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const material.SizedBox(height: 16),
                            ...cartItems.map((item) => material.Padding(
                                  padding: const material.EdgeInsets.symmetric(vertical: 8),
                                  child: material.Row(
                                    children: [
                                      material.ClipRRect(
                                        borderRadius: material.BorderRadius.circular(8),
                                        child: material.Image.network(
                                          item['product']['image_url'] ?? '',
                                          width: 50,
                                          height: 50,
                                          fit: material.BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              material.Container(
                                            width: 50,
                                            height: 50,
                                            decoration: material.BoxDecoration(
                                              color: material.Colors.grey[300],
                                              borderRadius: material.BorderRadius.circular(8),
                                            ),
                                            child: material.Icon(material.Icons.image,
                                                color: material.Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                      const material.SizedBox(width: 12),
                                      material.Expanded(
                                        child: material.Column(
                                          crossAxisAlignment: material.CrossAxisAlignment.start,
                                          children: [
                                            material.Text(
                                              item['product']['name'] ?? '',
                                              style: const material.TextStyle(
                                                fontWeight: material.FontWeight.w600,
                                              ),
                                            ),
                                            material.Text(
                                              'Qty: ${item['quantity']}',
                                              style: material.TextStyle(
                                                color: material.Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      material.Text(
                                        _formatCurrency(item['price'] * item['quantity']),
                                        style: const material.TextStyle(
                                          fontWeight: material.FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const material.Divider(),
                            material.Row(
                              mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                              children: [
                                const material.Text('Subtotal:'),
                                material.Text(_formatCurrency(subtotal)),
                              ],
                            ),
                            const material.SizedBox(height: 8),
                            material.Row(
                              mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                              children: [
                                const material.Text('Pajak (11%):'),
                                material.Text(_formatCurrency(tax)),
                              ],
                            ),
                            const material.Divider(),
                            material.Row(
                              mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                              children: [
                                const material.Text(
                                  'Total:',
                                  style: material.TextStyle(
                                    fontWeight: material.FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                material.Text(
                                  _formatCurrency(total),
                                  style: const material.TextStyle(
                                    fontWeight: material.FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const material.SizedBox(height: 16),
                    
                    // Payment Methods
                    OurbitCard(
                      child: material.Padding(
                        padding: const material.EdgeInsets.all(16),
                        child: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            const material.Text(
                              'Metode Pembayaran',
                              style: material.TextStyle(
                                fontSize: 18,
                                fontWeight: material.FontWeight.bold,
                              ),
                            ),
                            const material.SizedBox(height: 16),
                            ...storePaymentMethods.map((method) => material.RadioListTile<String>(
                                  title: material.Text(method['payment_method']['name'] ?? ''),
                                  subtitle: material.Text(method['payment_method']['description'] ?? ''),
                                  value: method['payment_method_id'],
                                  groupValue: selectedPaymentMethod?['payment_method_id'],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedPaymentMethod = method;
                                    });
                                  },
                                )),
                          ],
                        ),
                      ),
                    ),
                    
                    const material.SizedBox(height: 16),
                    
                    // Notes Section
                    OurbitCard(
                      child: material.Padding(
                        padding: const material.EdgeInsets.all(16),
                        child: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            const material.Text(
                              'Catatan Penjualan',
                              style: material.TextStyle(
                                fontSize: 18,
                                fontWeight: material.FontWeight.bold,
                              ),
                            ),
                            const material.SizedBox(height: 12),
                            OurbitTextArea(
                              placeholder: 'Tulis catatan penjualan (opsional)',
                              onChanged: (value) {
                                salesDraftNote = value ?? '';
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const material.SizedBox(height: 24),
                    
                    // Process Payment Button
                    material.SizedBox(
                      width: double.infinity,
                      child: OurbitButton.primary(
                        onPressed: isProcessing ? null : () => _processPayment(cartItems, subtotal, tax, total),
                        label: isProcessing ? 'Memproses...' : 'Proses Pembayaran',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
