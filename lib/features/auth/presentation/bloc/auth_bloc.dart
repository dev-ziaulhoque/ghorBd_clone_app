import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/security/session_manager.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SessionManager _sessionManager;
  StreamSubscription<SessionStatus>? _sessionSubscription;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SessionManager sessionManager,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _sessionManager = sessionManager,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthSessionExpiredEvent>(_onAuthSessionExpiredEvent);

    // Listen to session status from SessionManager
    _sessionSubscription = _sessionManager.statusStream.listen((status) {
      if (status == SessionStatus.expired) {
        add(const AuthSessionExpiredEvent());
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        // Special case: 403 EMAIL_NOT_VERIFIED requires navigating to OTP screen
        if (failure.code == 'EMAIL_NOT_VERIFIED') {
          emit(AuthOtpRequiredState(email: event.email));
        } else {
          emit(AuthFailure(
            message: failure.message,
            messageKey: failure.messageKey,
            code: failure.code,
          ));
        }
      },
      (session) => emit(Authenticated(session.user)),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logoutUseCase();
    emit(const Unauthenticated());
  }

  void _onAuthSessionExpiredEvent(
    AuthSessionExpiredEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(const Unauthenticated(message: 'session_expired'));
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
