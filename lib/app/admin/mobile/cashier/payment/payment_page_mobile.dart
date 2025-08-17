import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/blocs/payment_bloc.dart';
import 'package:ourbit_pos/src/core/services/printer_service.dart';
import 'package:ourbit_pos/src/core/services/receipt_pdf_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _summaryController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  String salesDraftNote = '';
  Map<String, dynamic>? selectedPaymentMethod;
  List<Map<String, dynamic>> _lastCartItems = const [];
  double _lastSubtotal = 0.0;
  double _lastTax = 0.0;
  double _lastTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    context.read<PaymentBloc>().add(LoadPaymentData());
  }

  void _initAnimationControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _summaryController.dispose();
    _buttonController.dispose();
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

  String? _getPaymentMethodId(Map<String, dynamic> method) {
    final dynamic pmPlural = method['payment_methods'];
    final dynamic pm = method['payment_method'];
    final dynamic id = method['payment_method_id'] ??
        (pmPlural is Map ? pmPlural['id'] : null) ??
        (pm is Map ? pm['id'] : null) ??
        method['id'];
    return id?.toString();
  }

  String _getPaymentMethodName(Map<String, dynamic> method) {
    final dynamic pmPlural = method['payment_methods'];
    final dynamic pm = method['payment_method'];
    final dynamic name = (pmPlural is Map ? pmPlural['name'] : null) ??
        (pm is Map ? pm['name'] : null) ??
        method['name'];
    final String nameStr = name?.toString() ?? '';
    return nameStr.trim().isNotEmpty ? nameStr : 'Metode Pembayaran';
  }

  String _getPaymentMethodDescription(Map<String, dynamic> method) {
    final dynamic pmPlural = method['payment_methods'];
    final dynamic pm = method['payment_method'];
    final dynamic desc = (pmPlural is Map ? pmPlural['description'] : null) ??
        (pm is Map ? pm['description'] : null) ??
        method['description'];
    return desc?.toString() ?? '';
  }

  void _processPayment(List<Map<String, dynamic>> cartItems, double subtotal,
      double tax, double total) {
    if (selectedPaymentMethod == null) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content:
              const material.Text('Pilih metode pembayaran terlebih dahulu'),
          backgroundColor: AppColors.warning,
          behavior: material.SnackBarBehavior.floating,
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    final String? methodId = _getPaymentMethodId(selectedPaymentMethod!);
    if (methodId == null || methodId.isEmpty) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: const material.Text('Metode pembayaran tidak valid'),
          backgroundColor: AppColors.error,
          behavior: material.SnackBarBehavior.floating,
          shape: material.RoundedRectangleBorder(
            borderRadius: material.BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    _buttonController.forward();
    context.read<PaymentBloc>().add(ProcessPayment(
          cartItems: cartItems,
          subtotal: subtotal,
          tax: tax,
          total: total,
          paymentMethodId: methodId,
          salesNotes: salesDraftNote,
        ));
  }

  Widget _buildOrderSummaryItem(Map<String, dynamic> item, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - progress)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['product']['image_url'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.gray[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.image, color: Colors.gray[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['product']['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Qty: ${item['quantity']}',
                          style: TextStyle(
                            color: Colors.gray[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(item['price'] * item['quantity']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    final String? methodId = _getPaymentMethodId(method);
    final String name = _getPaymentMethodName(method);
    final String desc = _getPaymentMethodDescription(method);
    final String? selectedId = selectedPaymentMethod == null
        ? null
        : _getPaymentMethodId(selectedPaymentMethod!);
    final bool isSelected = methodId == selectedId;

    if (methodId == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border:
            isSelected ? Border.all(color: AppColors.primary, width: 1) : null,
      ),
      child: material.RadioListTile<String>(
        title: Text(name),
        subtitle: desc.isEmpty ? null : Text(desc),
        value: methodId,
        groupValue: selectedId,
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            selectedPaymentMethod = method;
          });
        },
      ),
    );
  }

  Widget _buildProcessButton(bool isProcessing) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState:
          isProcessing ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
              SizedBox(width: 12),
              Text(
                'Memproses...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      secondChild: SizedBox(
        width: double.infinity,
        child: OurbitButton.primary(
          onPressed: () => _processPayment(
              _lastCartItems, _lastSubtotal, _lastTax, _lastTotal),
          label: 'Proses Pembayaran',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == material.Brightness.dark;
    return material.Scaffold(
      backgroundColor: isDark
          ? AppColors.darkSurfaceBackground
          : AppColors.surfaceBackground,
      appBar: material.AppBar(
        title: const Text('Pembayaran'),
        elevation: 0,
        backgroundColor: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.surfaceBackground,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
        ),
        leading: material.IconButton(
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
      body: material.Container(
        color: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.surfaceBackground,
        child: BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentLoaded) {
              _animationController.forward();
              _summaryController.forward();
            } else if (state is PaymentSuccess) {
              if (_lastCartItems.isNotEmpty && _lastTotal > 0) {
                (() async {
                  try {
                    if (material.Theme.of(context).platform ==
                            material.TargetPlatform.android ||
                        material.Theme.of(context).platform ==
                            material.TargetPlatform.iOS) {
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
                    material.ScaffoldMessenger.of(context).showSnackBar(
                      material.SnackBar(
                        content: material.Text('Cetak gagal: $e'),
                        backgroundColor: AppColors.error,
                        behavior: material.SnackBarBehavior.floating,
                        shape: material.RoundedRectangleBorder(
                          borderRadius: material.BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }
                })();
              }
              context.go('/success');
            } else if (state is PaymentError) {
              _buttonController.reverse();
              material.ScaffoldMessenger.of(context).showSnackBar(
                material.SnackBar(
                  content: material.Text('Error: ${state.message}'),
                  backgroundColor: AppColors.error,
                  behavior: material.SnackBarBehavior.floating,
                  shape: material.RoundedRectangleBorder(
                    borderRadius: material.BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              if (state is PaymentLoading || state is PaymentInitial) {
                return const material.Center(
                    child: material.CircularProgressIndicator());
              }

              if (state is PaymentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}'),
                      const SizedBox(height: 16),
                      OurbitButton(
                        onPressed: () =>
                            context.read<PaymentBloc>().add(LoadPaymentData()),
                        label: "Coba lagi",
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

              return FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary Card
                      OurbitCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.receipt_long,
                                      color: Colors.orange[600]),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Ringkasan Pesanan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.gray,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              FadeTransition(
                                opacity: _summaryController,
                                child: Column(
                                  children: [
                                    ...cartItems.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return _buildOrderSummaryItem(
                                          item, index);
                                    }),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal:'),
                                  Text(_formatCurrency(subtotal)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Pajak (11%):'),
                                  Text(_formatCurrency(tax)),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
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

                      const SizedBox(height: 16),

                      // Payment Methods
                      OurbitCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Metode Pembayaran',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...storePaymentMethods.map(
                                  (method) => _buildPaymentMethodTile(method)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notes Section
                      OurbitCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Catatan Penjualan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OurbitTextArea(
                                placeholder:
                                    'Tulis catatan penjualan (opsional)',
                                onChanged: (value) {
                                  salesDraftNote = value ?? '';
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Process Payment Button
                      _buildProcessButton(isProcessing),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
