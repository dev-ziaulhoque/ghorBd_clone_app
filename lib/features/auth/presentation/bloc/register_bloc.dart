import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_email_otp_usecase.dart';
import '../../domain/usecases/verify_email_otp_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;
  final VerifyEmailOtpUseCase _verifyEmailOtpUseCase;
  final ResendEmailOtpUseCase _resendEmailOtpUseCase;

  RegisterBloc({
    required RegisterUseCase registerUseCase,
    required VerifyEmailOtpUseCase verifyEmailOtpUseCase,
    required ResendEmailOtpUseCase resendEmailOtpUseCase,
  })  : _registerUseCase = registerUseCase,
        _verifyEmailOtpUseCase = verifyEmailOtpUseCase,
        _resendEmailOtpUseCase = resendEmailOtpUseCase,
        super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
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
