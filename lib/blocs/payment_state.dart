part of 'payment_bloc.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<Map<String, dynamic>> cartItems;
  final List<Map<String, dynamic>> storePaymentMethods;
  final Map<String, dynamic>? selectedPaymentMethod;
  final String note;

  PaymentLoaded({
    required this.cartItems,
    required this.storePaymentMethods,
    required this.selectedPaymentMethod,
    required this.note,
  });

  double get subtotal =>
      cartItems.fold(0.0, (s, i) => s + (i['price'] * i['quantity']));
  double get tax => subtotal * 0.11; // 11% tax
  double get total => subtotal + tax;

  PaymentLoaded copyWith({
    List<Map<String, dynamic>>? cartItems,
    List<Map<String, dynamic>>? storePaymentMethods,
    Map<String, dynamic>? selectedPaymentMethod,
    String? note,
  }) {
    return PaymentLoaded(
      cartItems: cartItems ?? this.cartItems,
      storePaymentMethods: storePaymentMethods ?? this.storePaymentMethods,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      note: note ?? this.note,
    );
  }
}

class PaymentProcessing extends PaymentLoaded {
  PaymentProcessing({
    required super.cartItems,
    required super.storePaymentMethods,
    required super.selectedPaymentMethod,
    required super.note,
  });
}

class PaymentSuccess extends PaymentState {
  final String saleId;
  PaymentSuccess({required this.saleId});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}
