import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/src/data/usecases/get_all_products_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_categories_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_customers_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_suppliers_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_discounts_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_expenses_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_loyalty_programs_usecase.dart';
import 'management_event.dart';
import 'management_state.dart';

class ManagementBloc extends Bloc<ManagementEvent, ManagementState> {
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetSuppliersUseCase _getSuppliersUseCase;
  final GetDiscountsUseCase _getDiscountsUseCase;
  final GetExpensesUseCase _getExpensesUseCase;
  final GetLoyaltyProgramsUseCase _getLoyaltyProgramsUseCase;

  ManagementBloc({
    required GetAllProductsUseCase getAllProductsUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required GetSuppliersUseCase getSuppliersUseCase,
    required GetDiscountsUseCase getDiscountsUseCase,
    required GetExpensesUseCase getExpensesUseCase,
    required GetLoyaltyProgramsUseCase getLoyaltyProgramsUseCase,
  })  : _getAllProductsUseCase = getAllProductsUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _getCustomersUseCase = getCustomersUseCase,
        _getSuppliersUseCase = getSuppliersUseCase,
        _getDiscountsUseCase = getDiscountsUseCase,
        _getExpensesUseCase = getExpensesUseCase,
        _getLoyaltyProgramsUseCase = getLoyaltyProgramsUseCase,
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
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ManagementState> emit) async {
    emit(ManagementLoading());
    try {
      final products = await _getAllProductsUseCase.execute();
      emit(ProductsLoaded(products));
    } catch (e) {
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
      final inventory = await _getAllProductsUseCase.execute();
      emit(InventoryLoaded(inventory));
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
      final programs = await _getLoyaltyProgramsUseCase.execute();
      emit(LoyaltyProgramsLoaded(programs));
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update product usecase
      add(LoadProducts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
      CreateProduct event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create product usecase
      add(LoadProducts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
      DeleteProduct event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete product usecase
      add(LoadProducts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
      CreateCategory event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create category usecase
      add(LoadCategories());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update category usecase
      add(LoadCategories());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete category usecase
      add(LoadCategories());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateCustomer(
      CreateCustomer event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create customer usecase
      add(LoadCustomers());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update customer usecase
      add(LoadCustomers());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete customer usecase
      add(LoadCustomers());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateSupplier(
      CreateSupplier event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create supplier usecase
      add(LoadSuppliers());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplier event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update supplier usecase
      add(LoadSuppliers());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteSupplier(
      DeleteSupplier event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete supplier usecase
      add(LoadSuppliers());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateDiscount(
      CreateDiscount event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create discount usecase
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateDiscount(
      UpdateDiscount event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update discount usecase
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteDiscount(
      DeleteDiscount event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete discount usecase
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onToggleDiscountStatus(
      ToggleDiscountStatus event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement toggle discount status usecase
      add(LoadDiscounts());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateExpense(
      CreateExpense event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create expense usecase
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpense event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update expense usecase
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpense event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete expense usecase
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onMarkExpenseAsPaid(
      MarkExpenseAsPaid event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement mark expense as paid usecase
      add(LoadExpenses());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onCreateLoyaltyProgram(
      CreateLoyaltyProgram event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement create loyalty program usecase
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateLoyaltyProgram(
      UpdateLoyaltyProgram event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement update loyalty program usecase
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onDeleteLoyaltyProgram(
      DeleteLoyaltyProgram event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement delete loyalty program usecase
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }

  Future<void> _onToggleLoyaltyProgramStatus(
      ToggleLoyaltyProgramStatus event, Emitter<ManagementState> emit) async {
    try {
      // TODO: Implement toggle loyalty program status usecase
      add(LoadLoyaltyPrograms());
    } catch (e) {
      emit(ManagementError(e.toString()));
    }
  }
}
