import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/src/data/usecases/get_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_store_payment_methods_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/process_checkout_usecase.dart';

part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetCartUseCase _getCartUseCase;
  final GetStorePaymentMethodsUseCase _getStorePaymentMethodsUseCase;
  final ProcessCheckoutUseCase _processCheckoutUseCase;

  PaymentBloc({
    required GetCartUseCase getCartUseCase,
    required GetStorePaymentMethodsUseCase getStorePaymentMethodsUseCase,
    required ProcessCheckoutUseCase processCheckoutUseCase,
  })  : _getCartUseCase = getCartUseCase,
        _getStorePaymentMethodsUseCase = getStorePaymentMethodsUseCase,
        _processCheckoutUseCase = processCheckoutUseCase,
        super(PaymentInitial()) {
    on<LoadPaymentData>(_onLoadPaymentData);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<UpdateSalesNote>(_onUpdateSalesNote);
    on<ProcessPayment>(_onProcessPayment);
    on<SubmitPayment>(_onSubmitPayment);
  }

  Future<void> _onLoadPaymentData(
      LoadPaymentData event, Emitter<PaymentState> emit) async {
    emit(PaymentLoading());
    try {
      final cartItemsObjects = await _getCartUseCase();
      final methods = await _getStorePaymentMethodsUseCase();

      // Convert CartItem objects to Map<String, dynamic>
      final cartItems = cartItemsObjects
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

      emit(PaymentLoaded(
        cartItems: cartItems,
        storePaymentMethods: methods,
        selectedPaymentMethod: null,
        note: '',
      ));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  void _onSelectPaymentMethod(
      SelectPaymentMethod event, Emitter<PaymentState> emit) {
    if (state is PaymentLoaded) {
      final s = state as PaymentLoaded;
      emit(s.copyWith(selectedPaymentMethod: event.method));
    }
  }

  void _onUpdateSalesNote(UpdateSalesNote event, Emitter<PaymentState> emit) {
    if (state is PaymentLoaded) {
      final s = state as PaymentLoaded;
      emit(s.copyWith(note: event.note));
    }
  }

  Future<void> _onProcessPayment(
      ProcessPayment event, Emitter<PaymentState> emit) async {
    if (state is! PaymentLoaded) return;
    final s = state as PaymentLoaded;

    emit(PaymentProcessing(
      cartItems: s.cartItems,
      storePaymentMethods: s.storePaymentMethods,
      selectedPaymentMethod: s.selectedPaymentMethod,
      note: event.salesNotes ?? '',
    ));

    try {
      await _processCheckoutUseCase(
        cartItems: event.cartItems,
        subtotal: event.subtotal,
        tax: event.tax,
        total: event.total,
        paymentMethodId: event.paymentMethodId,
        salesNotes: event.salesNotes,
      );
      emit(PaymentSuccess(saleId: ''));
    } catch (e) {
      emit(PaymentError(e.toString()));
      emit(s);
    }
  }

  Future<void> _onSubmitPayment(
      SubmitPayment event, Emitter<PaymentState> emit) async {
    if (state is! PaymentLoaded) return;
    final s = state as PaymentLoaded;
    if (s.selectedPaymentMethod == null) {
      emit(PaymentError('Pilih metode pembayaran terlebih dahulu'));
      emit(s); // revert back
      return;
    }

    emit(PaymentProcessing(
      cartItems: s.cartItems,
      storePaymentMethods: s.storePaymentMethods,
      selectedPaymentMethod: s.selectedPaymentMethod,
      note: s.note,
    ));

    try {
      final subtotal = s.subtotal;
      final tax = s.tax;
      final total = s.total;

      final saleId = await _processCheckoutUseCase(
        cartItems: s.cartItems,
        subtotal: subtotal,
        tax: tax,
        total: total,
        paymentMethodId: s.selectedPaymentMethod!['payment_method_id'],
        salesNotes: s.note,
      );
      emit(PaymentSuccess(saleId: saleId ?? ''));
    } catch (e) {
      emit(PaymentError(e.toString()));
      emit(s);
    }
  }
}
