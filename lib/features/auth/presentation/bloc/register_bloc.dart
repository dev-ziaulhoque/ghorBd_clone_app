import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_email_otp_usecase.dart';
import '../../domain/usecases/verify_email_otp_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final ResendEmailOtpUseCase _resendEmailOtpUseCase;
  final LoginWithGoogleUseCase? _loginWithGoogleUseCase;

  RegisterBloc({
    required RegisterUseCase registerUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
    required ResendEmailOtpUseCase resendEmailOtpUseCase,
    LoginWithGoogleUseCase? loginWithGoogleUseCase,
  })  : _registerUseCase = registerUseCase,
        _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
        _resendEmailOtpUseCase = resendEmailOtpUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResendOtpRequested>(_onResendOtpRequested);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    final result = await _registerUseCase(
      name: event.name,
      email: event.email,
      phone: event.phone,
      password: event.password,
      role: event.role,
      listerType: event.listerType,
    );

    result.fold(
      (failure) => emit(RegisterFailure(
        message: failure.message,
        messageKey: failure.messageKey,
        code: failure.code,
      )),
      (regResult) => emit(RegisterOtpSent(
        email: regResult.email,
        devEmailOtp: regResult.devEmailOtp,
      )),
    );
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<RegisterState> emit,
  ) async {
    final useCase = _loginWithGoogleUseCase;
    if (useCase == null) {
      emit(const RegisterFailure(
        message: 'Google sign-in is not available yet',
        messageKey: 'error_google_unavailable',
        code: 'GOOGLE_UNAVAILABLE',
      ));
      return;
    }
    emit(const RegisterLoading());
    final result = await useCase();
    result.fold(
      (failure) => emit(RegisterFailure(
        message: failure.message,
        messageKey: failure.messageKey,
        code: failure.code,
      )),
      (session) => emit(RegisterSuccess(session.user)),
    );
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    final result = await _verifyEmailOtpUseCase(
      email: event.email,
      otp: event.otp,
    );

    result.fold(
      (failure) => emit(OtpVerificationFailure(
        message: failure.message,
        messageKey: failure.messageKey,
        code: failure.code,
        email: event.email,
      )),
      (session) => emit(RegisterSuccess(session.user)),
    );
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<RegisterState> emit,
  ) async {
    final result = await _resendEmailOtpUseCase(email: event.email);
    result.fold(
      (failure) => emit(OtpVerificationFailure(
        message: failure.message,
        messageKey: failure.messageKey,
        code: failure.code,
        email: event.email,
      )),
      (_) => emit(RegisterOtpSent(email: event.email)),
    );
  }
}
