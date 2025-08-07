import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ourbit_pos/blocs/cashier_bloc.dart';
import 'package:ourbit_pos/blocs/cashier_state.dart';
import 'package:ourbit_pos/src/core/services/supabase_service.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> paymentTypes = [];
  List<Map<String, dynamic>> paymentMethods = [];
  List<Map<String, dynamic>> storePaymentMethods = [];
  Map<String, dynamic>? selectedPaymentMethod;
  bool isLoading = true;
  bool isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // === Loading Payment Data ===

      // Load cart items
      final cashierState = context.read<CashierBloc>().state;
      // CashierState type: ${cashierState.runtimeType}

      if (cashierState is CashierLoaded) {
        // Cart items count: ${cashierState.cartItems.length}
        cartItems = cashierState.cartItems
            .map((item) => {
                  'id': item.id,
                  'product_id': item.product.id,
                  'quantity': item.quantity,
                  'price': item.product.sellingPrice,
                  'product': {
                    'name': item.product.name,
                    'image_url': item.product.imageUrl,
                  }
                })
            .toList();
        // Processed cart items: ${cartItems.length}
      } else {
        // CashierState is not CashierLoaded: ${cashierState.runtimeType}
        // Fallback: try to load cart from database directly
        final storeId = await SupabaseService.getStoreId();
        if (storeId != null) {
          final cartResponse = await SupabaseService.client
              .from('store_carts')
              .select('*, products(*)')
              .eq('store_id', storeId);

          cartItems = List<Map<String, dynamic>>.from(cartResponse)
              .map((item) => {
                    'id': item['id'],
                    'product_id': item['product_id'],
                    'quantity': item['quantity'],
                    'price': item['products']['selling_price'],
                    'product': {
                      'name': item['products']['name'],
                      'image_url': item['products']['image_url'],
                    }
                  })
              .toList();
          // Loaded cart from database: ${cartItems.length} items
        }
      }

      // Load payment types
      final paymentTypesResponse =
          await SupabaseService.client.from('payment_types').select('*');
      paymentTypes = List<Map<String, dynamic>>.from(paymentTypesResponse);
      // Payment types loaded: ${paymentTypes.length}

      // Load payment methods
      final paymentMethodsResponse =
          await SupabaseService.client.from('payment_methods').select('*');
      paymentMethods = List<Map<String, dynamic>>.from(paymentMethodsResponse);
      // Payment methods loaded: ${paymentMethods.length}

      // Load store payment methods
      final storeId = await SupabaseService.getStoreId();
      // Store ID: $storeId
      if (storeId != null) {
        final storePaymentMethodsResponse = await SupabaseService.client
            .from('store_payment_methods')
            .select('*, payment_methods(*)')
            .eq('store_id', storeId);
        storePaymentMethods =
            List<Map<String, dynamic>>.from(storePaymentMethodsResponse);
        // Store payment methods loaded: ${storePaymentMethods.length}
        if (storePaymentMethods.isNotEmpty) {
          // First payment method: ${storePaymentMethods.first}
        }
      } else {
        // Store ID is null!
      }

      // If no store payment methods, use all payment methods as fallback
      if (storePaymentMethods.isEmpty && paymentMethods.isNotEmpty) {
        // No store payment methods found, using all payment methods as fallback
        storePaymentMethods = paymentMethods
            .map((method) => {
                  'id': method['id'],
                  'payment_method_id': method['id'],
                  'payment_methods': method,
                })
            .toList();
        // Fallback payment methods: ${storePaymentMethods.length}
      }

      setState(() {
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      // Error loading payment data: $e
      setState(() {
        isLoading = false;
      });
    }
  }

  double get subtotal => cartItems.fold(
      0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get tax => subtotal * 0.11; // 11% tax
  double get total => subtotal + tax;

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<void> _processPayment() async {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih metode pembayaran terlebih dahulu')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final storeId = await SupabaseService.getStoreId();
      final userId = SupabaseService.client.auth.currentUser?.id;

      // Generate sale number
      final now = DateTime.now();
      final saleNumber =
          'POS-${now.year}${(now.month).toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

      // Create sale record
      final saleResponse = await SupabaseService.client
          .from('sales')
          .insert({
            'store_id': storeId,
            'sale_number': saleNumber,
            'sale_date': now.toIso8601String(),
            'subtotal': subtotal,
            'discount_amount': 0,
            'tax_amount': tax,
            'total_amount': total,
            'payment_method_id': selectedPaymentMethod!['payment_method_id'],
            'status': 'completed',
            'cashier_id': userId,
          })
          .select()
          .single();

      final saleId = saleResponse['id'];

      // Create sale items
      for (final item in cartItems) {
        await SupabaseService.client.from('sales_items').insert({
          'sale_id': saleId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['price'],
          'discount_amount': 0,
          'tax_amount': 0,
          'total_amount': item['price'] * item['quantity'],
        });
      }

      // Create financial transaction
      await SupabaseService.client.from('financial_transactions').insert({
        'store_id': storeId,
        'transaction_date': now.toIso8601String(),
        'transaction_type': 'income',
        'category': 'sales',
        'description': 'POS Sale #$saleNumber',
        'amount': total,
        'payment_method_id': selectedPaymentMethod!['payment_method_id'],
        'status': 'completed',
      });

      // Update stock and create inventory transactions
      for (final item in cartItems) {
        // Get current stock
        final productResponse = await SupabaseService.client
            .from('products')
            .select('stock')
            .eq('id', item['product_id'])
            .single();

        final currentStock = productResponse['stock'];
        final newStock = currentStock - item['quantity'];

        // Update stock
        await SupabaseService.client
            .from('products')
            .update({'stock': newStock}).eq('id', item['product_id']);

        // Create inventory transaction
        await SupabaseService.client.from('inventory_transactions').insert({
          'product_id': item['product_id'],
          'store_id': storeId,
          'type': 2, // Sale/outbound
          'quantity': -item['quantity'],
          'reference': 'POS-$saleNumber',
          'note': 'POS Sale',
          'previous_qty': currentStock,
          'new_qty': newStock,
          'unit_cost': item['price'],
          'total_cost': item['price'] * item['quantity'],
        });
      }

      // Clear cart
      if (storeId != null) {
        await SupabaseService.client
            .from('store_carts')
            .delete()
            .eq('store_id', storeId);
      }

      // Navigate to success page
      if (mounted) {
        context.go('/success');
      }
    } catch (e) {
      // Error processing payment: $e
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
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
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Debug Info (temporary)
                    if (cartItems.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Info:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Cart Items: ${cartItems.length}'),
                            Text(
                                'Payment Methods: ${storePaymentMethods.length}'),
                            Text('Payment Types: ${paymentTypes.length}'),
                          ],
                        ),
                      ),
                    // Order Summary Section
                    OurbitCard(
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
                                        borderRadius: BorderRadius.circular(8),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal',
                                    style: TextStyle(color: Colors.grey[600])),
                                Text(_formatCurrency(subtotal)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pajak (11%)',
                                    style: TextStyle(color: Colors.grey[600])),
                                Text(_formatCurrency(tax)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(height: 24),

                    // Payment Method Selection
                    OurbitCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.payment, color: Colors.orange[600]),
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
                                          size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tidak ada metode pembayaran tersedia',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
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
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedPaymentMethod = method;
                                      });
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
                                        borderRadius: BorderRadius.circular(12),
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
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  method['payment_methods']
                                                          ['name'] ??
                                                      'Unknown',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (method['payment_methods']
                                                        ['description'] !=
                                                    null)
                                                  Text(
                                                    method['payment_methods']
                                                        ['description'],
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                    ),
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
                    const SizedBox(height: 32),

                    // Process Payment Button
                    SizedBox(
                      width: double.infinity,
                      child: OurbitButton.primary(
                        onPressed: isProcessing ? null : _processPayment,
                        label: 'Bayar ${_formatCurrency(total)}',
                        leadingIcon: const Icon(Icons.payment, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
