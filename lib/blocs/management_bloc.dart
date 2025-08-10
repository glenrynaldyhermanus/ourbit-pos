import 'package:flutter_bloc/flutter_bloc.dart';
import 'management_event.dart';
import 'management_state.dart';
import '../src/data/usecases/get_all_products_usecase.dart';
import '../src/data/usecases/get_categories_usecase.dart';
import '../src/data/usecases/get_customers_usecase.dart';
import '../src/data/usecases/get_suppliers_usecase.dart';
import '../src/data/usecases/get_discounts_usecase.dart';
import '../src/data/usecases/get_expenses_usecase.dart';
import '../src/data/usecases/get_loyalty_programs_usecase.dart';
import '../src/data/repositories/management_repository.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';

class ManagementBloc extends Bloc<ManagementEvent, ManagementState> {
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetSuppliersUseCase _getSuppliersUseCase;
  final GetDiscountsUseCase _getDiscountsUseCase;
  final GetExpensesUseCase _getExpensesUseCase;
  final GetLoyaltyProgramsUseCase _getLoyaltyProgramsUseCase;
  final ManagementRepository _managementRepository;

  ManagementBloc({
    required GetAllProductsUseCase getAllProductsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required GetSuppliersUseCase getSuppliersUseCase,
    required GetDiscountsUseCase getDiscountsUseCase,
    required GetExpensesUseCase getExpensesUseCase,
    required GetLoyaltyProgramsUseCase getLoyaltyProgramsUseCase,
    required ManagementRepository managementRepository,
  })  : _getAllProductsUseCase = getAllProductsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getCustomersUseCase = getCustomersUseCase,
        _getSuppliersUseCase = getSuppliersUseCase,
        _getDiscountsUseCase = getDiscountsUseCase,
        _getExpensesUseCase = getExpensesUseCase,
        _getLoyaltyProgramsUseCase = getLoyaltyProgramsUseCase,
        _managementRepository = managementRepository,
        super(ManagementInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadCategories>(_onLoadCategories);
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadSuppliers>(_onLoadSuppliers);
    on<LoadInventory>(_onLoadInventory);
    on<LoadDiscounts>(_onLoadDiscounts);
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadLoyaltyPrograms>(_onLoadLoyaltyPrograms);
    on<UpdateProduct>(_onUpdateProduct);
    on<CreateProduct>(_onCreateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<CreateSupplier>(_onCreateSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
    on<CreateDiscount>(_onCreateDiscount);
    on<UpdateDiscount>(_onUpdateDiscount);
    on<DeleteDiscount>(_onDeleteDiscount);
    on<ToggleDiscountStatus>(_onToggleDiscountStatus);
    on<CreateExpense>(_onCreateExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<MarkExpenseAsPaid>(_onMarkExpenseAsPaid);
    on<CreateLoyaltyProgram>(_onCreateLoyaltyProgram);
    on<UpdateLoyaltyProgram>(_onUpdateLoyaltyProgram);
    on<DeleteLoyaltyProgram>(_onDeleteLoyaltyProgram);
    on<ToggleLoyaltyProgramStatus>(_onToggleLoyaltyProgramStatus);
    on<SelectManagementMenu>(_onSelectManagementMenu);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ManagementState> emit) async {
    Logger.debug('BLOC: LoadProducts start');
    emit(ManagementLoading());
    try {
      final products = await _getAllProductsUseCase.execute();
      Logger.debug('BLOC: LoadProducts success count=${products.length}');
      emit(ProductsLoaded(products));
    } catch (e) {
      Logger.error('BLOC: LoadProducts error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final categories = await _getCategoriesUseCase.execute();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final customers = await _getCustomersUseCase.execute();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadSuppliers(
      LoadSuppliers event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final suppliers = await _getSuppliersUseCase.execute();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadInventory(
      LoadInventory event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      emit(const InventoryLoaded([]));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadDiscounts(
      LoadDiscounts event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final discounts = await _getDiscountsUseCase.execute();
      emit(DiscountsLoaded(discounts));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadExpenses(
      LoadExpenses event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final expenses = await _getExpensesUseCase.execute();
      emit(ExpensesLoaded(expenses));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onLoadLoyaltyPrograms(
      LoadLoyaltyPrograms event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final loyaltyPrograms = await _getLoyaltyProgramsUseCase.execute();
      emit(LoyaltyProgramsLoaded(loyaltyPrograms));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: UpdateProduct id=${event.productId}');
      await _managementRepository.updateProduct(
          event.productId, event.productData);
      Logger.debug('BLOC: UpdateProduct success');
      add(LoadProducts());
    } catch (e) {
      Logger.error('BLOC: UpdateProduct error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
      CreateProduct event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: CreateProduct payload=${event.productData}');
      await _managementRepository.createProduct(event.productData);
      Logger.debug('BLOC: CreateProduct success');
      add(LoadProducts());
    } catch (e) {
      Logger.error('BLOC: CreateProduct error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: DeleteProduct id=${event.productId}');
      await _managementRepository.deleteProduct(event.productId);
      Logger.debug('BLOC: DeleteProduct success');
      add(LoadProducts());
    } catch (e) {
      Logger.error('BLOC: DeleteProduct error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
      CreateCategory event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: CreateCategory payload=${event.categoryData}');
      await _managementRepository.createCategory(event.categoryData);
      Logger.debug('BLOC: CreateCategory success');
      add(LoadCategories());
    } catch (e) {
      Logger.error('BLOC: CreateCategory error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: UpdateCategory id=${event.categoryId}');
      await _managementRepository.updateCategory(
          event.categoryId, event.categoryData);
      Logger.debug('BLOC: UpdateCategory success');
      add(LoadCategories());
    } catch (e) {
      Logger.error('BLOC: UpdateCategory error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: DeleteCategory id=${event.categoryId}');
      await _managementRepository.deleteCategory(event.categoryId);
      Logger.debug('BLOC: DeleteCategory success');
      add(LoadCategories());
    } catch (e) {
      Logger.error('BLOC: DeleteCategory error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateCustomer(
      CreateCustomer event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: CreateCustomer payload=${event.customerData}');
      await _managementRepository.createCustomer(event.customerData);
      Logger.debug('BLOC: CreateCustomer success');
      add(LoadCustomers());
    } catch (e) {
      Logger.error('BLOC: CreateCustomer error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: UpdateCustomer id=${event.customerId}');
      await _managementRepository.updateCustomer(
          event.customerId, event.customerData);
      Logger.debug('BLOC: UpdateCustomer success');
      add(LoadCustomers());
    } catch (e) {
      Logger.error('BLOC: UpdateCustomer error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: DeleteCustomer id=${event.customerId}');
      await _managementRepository.deleteCustomer(event.customerId);
      Logger.debug('BLOC: DeleteCustomer success');
      add(LoadCustomers());
    } catch (e) {
      Logger.error('BLOC: DeleteCustomer error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateSupplier(
      CreateSupplier event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: CreateSupplier payload=${event.supplierData}');
      await _managementRepository.createSupplier(event.supplierData);
      Logger.debug('BLOC: CreateSupplier success');
      add(LoadSuppliers());
    } catch (e) {
      Logger.error('BLOC: CreateSupplier error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplier event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: UpdateSupplier id=${event.supplierId}');
      await _managementRepository.updateSupplier(
          event.supplierId, event.supplierData);
      Logger.debug('BLOC: UpdateSupplier success');
      add(LoadSuppliers());
    } catch (e) {
      Logger.error('BLOC: UpdateSupplier error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteSupplier(
      DeleteSupplier event, Emitter<ManagementState> emit) async {
    try {
      Logger.debug('BLOC: DeleteSupplier id=${event.supplierId}');
      await _managementRepository.deleteSupplier(event.supplierId);
      Logger.debug('BLOC: DeleteSupplier success');
      add(LoadSuppliers());
    } catch (e) {
      Logger.error('BLOC: DeleteSupplier error ${e.toString()}');
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateDiscount(
      CreateDiscount event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateDiscount(
      UpdateDiscount event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteDiscount(
      DeleteDiscount event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onToggleDiscountStatus(
      ToggleDiscountStatus event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateExpense(
      CreateExpense event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpense event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onMarkExpenseAsPaid(
      MarkExpenseAsPaid event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateLoyaltyProgram(
      CreateLoyaltyProgram event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateLoyaltyProgram(
      UpdateLoyaltyProgram event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteLoyaltyProgram(
      DeleteLoyaltyProgram event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onToggleLoyaltyProgramStatus(
      ToggleLoyaltyProgramStatus event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  void _onSelectManagementMenu(
      SelectManagementMenu event, Emitter<ManagementState> emit) {
    emit(ManagementMenuSelected(event.menuId));
  }
}
