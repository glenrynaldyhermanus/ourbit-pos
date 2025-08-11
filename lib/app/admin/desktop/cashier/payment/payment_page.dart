import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/blocs/payment_bloc.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/core/services/printer_service.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/core/services/receipt_pdf_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String salesDraftNote = '';
  Map<String, dynamic>? selectedPaymentMethod;
  // Snapshot for printing after success
  List<Map<String, dynamic>> _lastCartItems = const [];
  double _lastSubtotal = 0.0;
  double _lastTax = 0.0;
  double _lastTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

  double _calculateTax(double subtotal) => subtotal * 0.11; // 11% tax

  double _calculateTotal(double subtotal, double tax) => subtotal + tax;

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<bool?> _promptSalesDraft() async {
    final controller = TextEditingController(text: salesDraftNote);
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Penjualan (Draft)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                OurbitTextArea(
                  controller: controller,
                  placeholder: 'Tulis catatan penjualan (opsional)',
                  expandableHeight: true,
                  initialHeight: 120,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OurbitButton.outline(
                        onPressed: () => Navigator.of(context).pop(false),
                        label: 'Batal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OurbitButton.primary(
                        onPressed: () {
                          salesDraftNote = controller.text.trim();
                          Navigator.of(context).pop(true);
                        },
                        label: 'Lanjutkan',
                      ),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/pos');
            }
          },
        ),
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoaded) {
            _animationController.forward();
          } else if (state is PaymentSuccess) {
            // Fire and forget printing using last snapshot
            if (_lastCartItems.isNotEmpty && _lastTotal > 0) {
              // On mobile use Bluetooth; else use system print (PDF)
              (() async {
                try {
                  // ignore: avoid_print
                  if (Theme.of(context).platform == TargetPlatform.android ||
                      Theme.of(context).platform == TargetPlatform.iOS) {
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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PaymentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PaymentBloc>().add(LoadPaymentData()),
                      child: const Text('Coba Lagi'),
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

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel: Order Summary
                    Expanded(
                      flex: 3,
                      child: OurbitCard(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long,
                                      color: Colors.orange[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ringkasan Pesanan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ...cartItems.map((item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item['product']['image_url'] ?? '',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.image,
                                                  color: Colors.grey[600]),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['product']['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '${item['quantity']} x ${_formatCurrency(item['price'])}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(
                                              item['price'] * item['quantity']),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                  Text(_formatCurrency(subtotal)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Pajak (11%)',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                  Text(_formatCurrency(tax)),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(total),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right Panel: Payment Methods
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OurbitCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.payment,
                                          color: Colors.orange[600]),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Metode Pembayaran',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  if (storePaymentMethods.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Icon(Icons.payment_outlined,
                                                size: 48,
                                                color: Colors.grey[400]),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Tidak ada metode pembayaran tersedia',
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ...storePaymentMethods.map((method) {
                                      final isSelected =
                                          selectedPaymentMethod?['id'] ==
                                              method['id'];
                                      final methodData =
                                          method['payment_methods'] ?? {};
                                      final typeData =
                                          methodData['payment_types'] ?? {};
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedPaymentMethod = method;
                                            });
                                            context.read<PaymentBloc>().add(
                                                SelectPaymentMethod(method));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.orange[600]!
                                                    : Colors.grey[300]!,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: isSelected
                                                  ? Colors.orange[50]
                                                  : Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isSelected
                                                        ? Colors.orange[600]
                                                        : Colors.grey[300],
                                                  ),
                                                  child: isSelected
                                                      ? const Icon(Icons.check,
                                                          color: Colors.white,
                                                          size: 14)
                                                      : null,
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              methodData[
                                                                      'name'] ??
                                                                  'Tidak diketahui',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                          ),
                                                          if (typeData[
                                                                  'name'] !=
                                                              null)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[200],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            999),
                                                              ),
                                                              child: Text(
                                                                typeData[
                                                                    'name'],
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                      if (methodData[
                                                              'description'] !=
                                                          null)
                                                        Text(
                                                          methodData[
                                                              'description'],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 12),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OurbitButton.primary(
                            onPressed: isProcessing
                                ? null
                                : () async {
                                    final confirmed = await _promptSalesDraft();
                                    if (confirmed == true) {
                                      // snapshot values for printing after success
                                      _lastCartItems =
                                          List<Map<String, dynamic>>.from(
                                              cartItems);
                                      _lastSubtotal = subtotal;
                                      _lastTax = tax;
                                      _lastTotal = total;
                                      _processPayment(
                                          cartItems, subtotal, tax, total);
                                    }
                                  },
                            label: isProcessing
                                ? 'Memproses...'
                                : 'Bayar ${_formatCurrency(total)}',
                            leadingIcon:
                                const Icon(Icons.payment, color: Colors.white),
                          ),
                        ],
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
