import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/interceptors/auth_interceptor.dart';
import '../../core/security/biometric_service.dart';
import '../../core/security/device_integrity.dart';
import '../../core/security/secure_storage.dart';
import '../../core/security/session_manager.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/resend_email_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/forgot_password_bloc.dart';
import '../../features/auth/presentation/bloc/register_bloc.dart';
import '../../features/auth/presentation/bloc/reset_password_bloc.dart';
import '../../features/browse/data/datasources/browse_remote_data_source.dart';
import '../../features/browse/data/repositories/browse_repository_impl.dart';
import '../../features/browse/domain/entities/facets_entity.dart';
import '../../features/browse/domain/repositories/browse_repository.dart';
import '../../features/browse/domain/usecases/get_areas_usecase.dart';
import '../../features/browse/domain/usecases/get_listing_detail_usecase.dart';
import '../../features/browse/domain/usecases/get_listings_usecase.dart';
import '../../features/browse/domain/usecases/search_listings_usecase.dart';
import '../../features/browse/presentation/bloc/home_bloc.dart';
import '../../features/browse/presentation/bloc/listing_detail_bloc.dart';
import '../../features/browse/presentation/bloc/listings_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Security & Storage
  if (!sl.isRegistered<AppSecureStorage>()) {
    sl.registerLazySingleton<AppSecureStorage>(() => AppSecureStorage());
  }
  if (!sl.isRegistered<SessionManager>()) {
    sl.registerLazySingleton<SessionManager>(
      () => SessionManager(secureStorage: sl<AppSecureStorage>()),
    );
  }
  if (!sl.isRegistered<DeviceIntegrityService>()) {
    sl.registerLazySingleton<DeviceIntegrityService>(() => DeviceIntegrityServiceImpl());
  }
  if (!sl.isRegistered<BiometricService>()) {
    sl.registerLazySingleton<BiometricService>(() => BiometricServiceImpl());
  }

  // Core Networking
  if (!sl.isRegistered<AuthInterceptor>()) {
    sl.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(
        secureStorage: sl<AppSecureStorage>(),
        onLogout: () => sl<SessionManager>().endSession(),
      ),
    );
  }
  if (!sl.isRegistered<DioClient>()) {
    sl.registerLazySingleton<DioClient>(
      () => DioClient(authInterceptor: sl<AuthInterceptor>()),
    );
  }

  // Auth Feature — Data Sources
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(client: sl<DioClient>()),
    );
  }

  // Auth Feature — Repository
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        secureStorage: sl<AppSecureStorage>(),
        sessionManager: sl<SessionManager>(),
      ),
    );
  }

  // Auth Feature — Use Cases
  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<RegisterUseCase>()) {
    sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<VerifyEmailOtpUseCase>()) {
    sl.registerLazySingleton<VerifyEmailOtpUseCase>(() => VerifyEmailOtpUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<ResendEmailOtpUseCase>()) {
    sl.registerLazySingleton<ResendEmailOtpUseCase>(() => ResendEmailOtpUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<LogoutUseCase>()) {
    sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<GetCurrentUserUseCase>()) {
    sl.registerLazySingleton<GetCurrentUserUseCase>(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<ForgotPasswordUseCase>()) {
    sl.registerLazySingleton<ForgotPasswordUseCase>(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  }
  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerLazySingleton<ResetPasswordUseCase>(() => ResetPasswordUseCase(sl<AuthRepository>()));
  }

  // Auth Feature — Blocs
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: sl<LoginUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        sessionManager: sl<SessionManager>(),
      ),
    );
  }
  if (!sl.isRegistered<RegisterBloc>()) {
    sl.registerFactory<RegisterBloc>(
      () => RegisterBloc(
        registerUseCase: sl<RegisterUseCase>(),
        verifyEmailOtpUseCase: sl<VerifyEmailOtpUseCase>(),
        resendEmailOtpUseCase: sl<ResendEmailOtpUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<ForgotPasswordBloc>()) {
    sl.registerFactory<ForgotPasswordBloc>(
      () => ForgotPasswordBloc(
        forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<ResetPasswordBloc>()) {
    sl.registerFactory<ResetPasswordBloc>(
      () => ResetPasswordBloc(
        resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      ),
    );
  }

  // Browse Feature — Data Layer
  if (!sl.isRegistered<BrowseRemoteDataSource>()) {
    sl.registerLazySingleton<BrowseRemoteDataSource>(
      () => BrowseRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<BrowseRepository>()) {
    sl.registerLazySingleton<BrowseRepository>(
      () => BrowseRepositoryImpl(
        remoteDataSource: sl<BrowseRemoteDataSource>(),
      ),
    );
  }

  // Browse Feature — Use Cases
  if (!sl.isRegistered<GetListingsUseCase>()) {
    sl.registerLazySingleton<GetListingsUseCase>(
      () => GetListingsUseCase(sl<BrowseRepository>()),
    );
  }
  if (!sl.isRegistered<GetListingDetailUseCase>()) {
    sl.registerLazySingleton<GetListingDetailUseCase>(
      () => GetListingDetailUseCase(sl<BrowseRepository>()),
    );
  }
  if (!sl.isRegistered<SearchListingsUseCase>()) {
    sl.registerLazySingleton<SearchListingsUseCase>(
      () => SearchListingsUseCase(sl<BrowseRepository>()),
    );
  }
  if (!sl.isRegistered<GetAreasUseCase>()) {
    sl.registerLazySingleton<GetAreasUseCase>(
      () => GetAreasUseCase(sl<BrowseRepository>()),
    );
  }

  // Browse Feature — Blocs
  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory<HomeBloc>(
      () => HomeBloc(
        getListingsUseCase: sl<GetListingsUseCase>(),
        getAreasUseCase: sl<GetAreasUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<ListingsBloc>()) {
    sl.registerFactoryParam<ListingsBloc, ListingFilterParams?, void>(
      (params, _) => ListingsBloc(
        searchListingsUseCase: sl<SearchListingsUseCase>(),
        initialParams: params ?? const ListingFilterParams(),
      ),
    );
  }
  if (!sl.isRegistered<ListingDetailBloc>()) {
    sl.registerFactory<ListingDetailBloc>(
      () => ListingDetailBloc(
        getListingDetailUseCase: sl<GetListingDetailUseCase>(),
      ),
    );
  }
}

Future<void> resetDependencies() async {
  await sl.reset();
}
