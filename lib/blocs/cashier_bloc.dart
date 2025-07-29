import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/src/core/config/app_config.dart';
import 'package:ourbit_pos/src/data/objects/cart_item.dart';
import 'package:ourbit_pos/src/data/usecases/add_to_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/clear_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_cart_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_products_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/update_cart_quantity_usecase.dart';

import 'cashier_event.dart';
import 'cashier_state.dart';

class CashierBloc extends Bloc<CashierEvent, CashierState> {
  final GetProductsUseCase _getProductsUseCase;
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartQuantityUseCase _updateCartQuantityUseCase;
  final ClearCartUseCase _clearCartUseCase;

  CashierBloc({
    required GetProductsUseCase getProductsUseCase,
    required GetCartUseCase getCartUseCase,
    required AddToCartUseCase addToCartUseCase,
    required UpdateCartQuantityUseCase updateCartQuantityUseCase,
    required ClearCartUseCase clearCartUseCase,
  })  : _getProductsUseCase = getProductsUseCase,
        _getCartUseCase = getCartUseCase,
        _addToCartUseCase = addToCartUseCase,
        _updateCartQuantityUseCase = updateCartQuantityUseCase,
        _clearCartUseCase = clearCartUseCase,
        super(CashierInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<ClearCart>(_onClearCart);
    on<SearchProducts>(_onSearchProducts);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<CashierState> emit,
  ) async {
    print('Loading products...');
    emit(CashierLoading());
    try {
      final products = await _getProductsUseCase();
      print('Products loaded: ${products.length}');
      final cartItems = await _getCartUseCase();
      print('Cart items loaded: ${cartItems.length}');
      final sortedCartItems = _sortCartItems(cartItems);
      final totals = _calculateTotals(sortedCartItems);

      emit(CashierLoaded(
        products: products,
        cartItems: sortedCartItems,
        total: totals['total']!,
        tax: totals['tax']!,
        discount: totals['discount']!,
        finalTotal: totals['finalTotal']!,
      ));
      print('CashierLoaded state emitted with ${products.length} products');
    } catch (e) {
      print('Error in _onLoadProducts: $e');
      emit(CashierError(e.toString()));
    }
  }

  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CashierState> emit,
  ) async {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      try {
        final cartItems = await _getCartUseCase();
        final sortedCartItems = _sortCartItems(cartItems);
        final totals = _calculateTotals(sortedCartItems);

        emit(currentState.copyWith(
          cartItems: sortedCartItems,
          total: totals['total']!,
          tax: totals['tax']!,
          discount: totals['discount']!,
          finalTotal: totals['finalTotal']!,
        ));
      } catch (e) {
        emit(CashierError(e.toString()));
      }
    }
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<CashierState> emit,
  ) async {
    print(
        '_onAddToCart called with productId: ${event.productId}, quantity: ${event.quantity}');
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      try {
        print('Calling addToCartUseCase...');
        await _addToCartUseCase(event.productId, event.quantity);
        print('addToCartUseCase completed');

        print('Calling getCartUseCase...');
        final cartItems = await _getCartUseCase();
        print('getCartUseCase completed, cart items: ${cartItems.length}');
        final sortedCartItems = _sortCartItems(cartItems);

        final totals = _calculateTotals(sortedCartItems);
        print('Calculated totals: $totals');

        emit(currentState.copyWith(
          cartItems: sortedCartItems,
          total: totals['total']!,
          tax: totals['tax']!,
          discount: totals['discount']!,
          finalTotal: totals['finalTotal']!,
        ));
        print('State updated with new cart items');
      } catch (e) {
        print('Error in _onAddToCart: $e');
        emit(CashierError(e.toString()));
      }
    } else {
      print('State is not CashierLoaded, current state: ${state.runtimeType}');
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CashierState> emit,
  ) async {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      try {
        await _updateCartQuantityUseCase(event.productId, event.quantity);
        final cartItems = await _getCartUseCase();
        final sortedCartItems = _sortCartItems(cartItems);
        final totals = _calculateTotals(sortedCartItems);

        emit(currentState.copyWith(
          cartItems: sortedCartItems,
          total: totals['total']!,
          tax: totals['tax']!,
          discount: totals['discount']!,
          finalTotal: totals['finalTotal']!,
        ));
      } catch (e) {
        emit(CashierError(e.toString()));
      }
    }
  }

  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CashierState> emit,
  ) async {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      try {
        await _clearCartUseCase();
        final cartItems = await _getCartUseCase();
        final sortedCartItems = _sortCartItems(cartItems);
        final totals = _calculateTotals(sortedCartItems);

        emit(currentState.copyWith(
          cartItems: sortedCartItems,
          total: totals['total']!,
          tax: totals['tax']!,
          discount: totals['discount']!,
          finalTotal: totals['finalTotal']!,
        ));
      } catch (e) {
        emit(CashierError(e.toString()));
      }
    }
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      emit(currentState.copyWith(searchTerm: event.searchTerm));
    }
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<CashierState> emit,
  ) {
    if (state is CashierLoaded) {
      final currentState = state as CashierLoaded;
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  List<CartItem> _sortCartItems(List<CartItem> cartItems) {
    // Sort by created_at in ascending order (oldest first)
    cartItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return cartItems;
  }

  Map<String, double> _calculateTotals(List<CartItem> cartItems) {
    final total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = total * AppConfig.taxRate;
    final discount = 0.0; // Can be implemented later
    final finalTotal = total + tax - discount;

    return {
      'total': total,
      'tax': tax,
      'discount': discount,
      'finalTotal': finalTotal,
    };
  }
}
