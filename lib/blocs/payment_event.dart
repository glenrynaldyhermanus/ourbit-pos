part of 'payment_bloc.dart';

abstract class PaymentEvent {}

class LoadPaymentData extends PaymentEvent {}

class SelectPaymentMethod extends PaymentEvent {
  final Map<String, dynamic> method;
  SelectPaymentMethod(this.method);
}

class UpdateSalesNote extends PaymentEvent {
  final String note;
  UpdateSalesNote(this.note);
}

class ProcessPayment extends PaymentEvent {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethodId;
  final String? salesNotes;

  ProcessPayment({
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethodId,
    this.salesNotes,
  });
}

class SubmitPayment extends PaymentEvent {}
