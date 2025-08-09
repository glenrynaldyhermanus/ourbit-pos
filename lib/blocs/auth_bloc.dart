import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:ourbit_pos/src/data/usecases/sign_in_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/sign_out_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_current_user_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/is_authenticated_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/authenticate_with_token_usecase.dart';
import 'package:ourbit_pos/src/data/usecases/get_user_business_store_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsAuthenticatedUseCase _isAuthenticatedUseCase;
  final AuthenticateWithTokenUseCase _authenticateWithTokenUseCase;
  final GetUserBusinessStoreUseCase _getUserBusinessStoreUseCase;

  AuthBloc({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required IsAuthenticatedUseCase isAuthenticatedUseCase,
    required AuthenticateWithTokenUseCase authenticateWithTokenUseCase,
    required GetUserBusinessStoreUseCase getUserBusinessStoreUseCase,
  })  : _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _isAuthenticatedUseCase = isAuthenticatedUseCase,
        _authenticateWithTokenUseCase = authenticateWithTokenUseCase,
        _getUserBusinessStoreUseCase = getUserBusinessStoreUseCase,
        super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<AuthenticateWithToken>(_onAuthenticateWithToken);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(isCheckingAuth: false));
    try {
      final user = await _signInUseCase(event.email, event.password);
      if (user != null) {
        Logger.auth('User authenticated successfully: ${user.email}');
        // Get business and store data after successful login
        try {
          Logger.auth('Getting business and store data');
          await _getUserBusinessStoreUseCase.execute();
          Logger.auth('Business and store data loaded successfully');

          // Reset CashierBloc to clear previous user's data
          Logger.auth('Resetting CashierBloc for new user');

          emit(Authenticated(user));
          Logger.auth('Emitting Authenticated state');
        } catch (businessError) {
          Logger.auth('Error getting business/store data: $businessError');
          // Handle specific business/store access errors
          emit(AuthError(businessError.toString()));
        }
      } else {
        Logger.auth('User authentication failed');
        emit(const AuthError('Email atau password salah'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    Logger.auth('SignOutRequested event received');
    emit(const AuthLoading(isCheckingAuth: false));
    try {
      Logger.auth('Calling signOutUseCase');
      await _signOutUseCase();
      Logger.auth('SignOutUseCase completed, emitting Unauthenticated');
      emit(Unauthenticated());
    } catch (e) {
      Logger.auth('SignOut error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(isCheckingAuth: true));
    try {
      final isAuthenticated = await _isAuthenticatedUseCase();
      if (isAuthenticated) {
        final user = await _getCurrentUserUseCase();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthenticateWithToken(
    AuthenticateWithToken event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(isCheckingAuth: false));
    try {
      final user = await _authenticateWithTokenUseCase.execute(event.token);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Invalid token'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
