import 'package:flutter_bloc/flutter_bloc.dart';
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
        // Get business and store data after successful login
        try {
          await _getUserBusinessStoreUseCase.execute();
          emit(Authenticated(user));
        } catch (businessError) {
          // Handle specific business/store access errors
          emit(AuthError(businessError.toString()));
        }
      } else {
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
    print('DEBUG: AuthBloc - SignOutRequested event received');
    emit(const AuthLoading(isCheckingAuth: false));
    try {
      print('DEBUG: AuthBloc - Calling signOutUseCase');
      await _signOutUseCase();
      print('DEBUG: AuthBloc - SignOutUseCase completed, emitting Unauthenticated');
      emit(Unauthenticated());
    } catch (e) {
      print('DEBUG: AuthBloc - SignOut error: $e');
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
