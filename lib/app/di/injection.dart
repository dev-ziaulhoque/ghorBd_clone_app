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
import '../../features/contact/data/datasources/contact_remote_data_source.dart';
import '../../features/contact/data/repositories/contact_repository_impl.dart';
import '../../features/contact/domain/repositories/contact_repository.dart';
import '../../features/contact/domain/usecases/contact_usecases.dart';
import '../../features/contact/presentation/bloc/contact_bloc.dart';
import '../../features/contact/presentation/bloc/report_bloc.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/favorites_usecases.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/land/data/datasources/land_remote_data_source.dart';
import '../../features/land/data/repositories/land_repository_impl.dart';
import '../../features/land/domain/repositories/land_repository.dart';
import '../../features/land/domain/usecases/get_land_listings_usecase.dart';
import '../../features/land/presentation/bloc/land_bloc.dart';
import '../../features/map/data/datasources/map_remote_data_source.dart';
import '../../features/map/data/repositories/map_repository_impl.dart';
import '../../features/map/domain/repositories/map_repository.dart';
import '../../features/map/domain/usecases/map_usecases.dart';
import '../../features/map/presentation/bloc/map_bloc.dart';
import '../../features/owner/data/datasources/owner_remote_data_source.dart';
import '../../features/owner/data/repositories/owner_repository_impl.dart';
import '../../features/owner/domain/repositories/owner_repository.dart';
import '../../features/owner/domain/usecases/owner_usecases.dart';
import '../../features/owner/presentation/bloc/create_listing_bloc.dart';
import '../../features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import '../../features/owner/presentation/bloc/verification_bloc.dart';
import '../../features/content/data/datasources/content_remote_data_source.dart';
import '../../features/content/data/repositories/content_repository_impl.dart';
import '../../features/content/domain/repositories/content_repository.dart';
import '../../features/content/domain/usecases/content_usecases.dart';
import '../../features/content/presentation/bloc/blog_bloc.dart';
import '../../features/content/presentation/bloc/qa_bloc.dart';
import '../../features/content/presentation/bloc/static_content_bloc.dart';

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

  // Favorites Feature
  if (!sl.isRegistered<FavoritesRemoteDataSource>()) {
    sl.registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<FavoritesRepository>()) {
    sl.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl(remoteDataSource: sl<FavoritesRemoteDataSource>()),
    );
  }
  if (!sl.isRegistered<GetFavoritesUseCase>()) {
    sl.registerLazySingleton<GetFavoritesUseCase>(
      () => GetFavoritesUseCase(sl<FavoritesRepository>()),
    );
  }
  if (!sl.isRegistered<AddFavoriteUseCase>()) {
    sl.registerLazySingleton<AddFavoriteUseCase>(
      () => AddFavoriteUseCase(sl<FavoritesRepository>()),
    );
  }
  if (!sl.isRegistered<RemoveFavoriteUseCase>()) {
    sl.registerLazySingleton<RemoveFavoriteUseCase>(
      () => RemoveFavoriteUseCase(sl<FavoritesRepository>()),
    );
  }
  if (!sl.isRegistered<FavoritesBloc>()) {
    sl.registerFactory<FavoritesBloc>(
      () => FavoritesBloc(
        getFavoritesUseCase: sl<GetFavoritesUseCase>(),
        addFavoriteUseCase: sl<AddFavoriteUseCase>(),
        removeFavoriteUseCase: sl<RemoveFavoriteUseCase>(),
      ),
    );
  }

  // Contact & Report Feature
  if (!sl.isRegistered<ContactRemoteDataSource>()) {
    sl.registerLazySingleton<ContactRemoteDataSource>(
      () => ContactRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<ContactRepository>()) {
    sl.registerLazySingleton<ContactRepository>(
      () => ContactRepositoryImpl(remoteDataSource: sl<ContactRemoteDataSource>()),
    );
  }
  if (!sl.isRegistered<GetContactPhoneUseCase>()) {
    sl.registerLazySingleton<GetContactPhoneUseCase>(
      () => GetContactPhoneUseCase(sl<ContactRepository>()),
    );
  }
  if (!sl.isRegistered<SendInquiryUseCase>()) {
    sl.registerLazySingleton<SendInquiryUseCase>(
      () => SendInquiryUseCase(sl<ContactRepository>()),
    );
  }
  if (!sl.isRegistered<ReportListingUseCase>()) {
    sl.registerLazySingleton<ReportListingUseCase>(
      () => ReportListingUseCase(sl<ContactRepository>()),
    );
  }
  if (!sl.isRegistered<ContactBloc>()) {
    sl.registerFactory<ContactBloc>(
      () => ContactBloc(
        getContactPhoneUseCase: sl<GetContactPhoneUseCase>(),
        sendInquiryUseCase: sl<SendInquiryUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<ReportBloc>()) {
    sl.registerFactory<ReportBloc>(
      () => ReportBloc(
        reportListingUseCase: sl<ReportListingUseCase>(),
      ),
    );
  }

  // Map Feature
  if (!sl.isRegistered<MapRemoteDataSource>()) {
    sl.registerLazySingleton<MapRemoteDataSource>(
      () => MapRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<MapRepository>()) {
    sl.registerLazySingleton<MapRepository>(
      () => MapRepositoryImpl(remoteDataSource: sl<MapRemoteDataSource>()),
    );
  }
  if (!sl.isRegistered<SearchPlacesUseCase>()) {
    sl.registerLazySingleton<SearchPlacesUseCase>(
      () => SearchPlacesUseCase(sl<MapRepository>()),
    );
  }
  if (!sl.isRegistered<ReverseGeocodeUseCase>()) {
    sl.registerLazySingleton<ReverseGeocodeUseCase>(
      () => ReverseGeocodeUseCase(sl<MapRepository>()),
    );
  }
  if (!sl.isRegistered<GetMapListingsUseCase>()) {
    sl.registerLazySingleton<GetMapListingsUseCase>(
      () => GetMapListingsUseCase(sl<MapRepository>()),
    );
  }
  if (!sl.isRegistered<MapBloc>()) {
    sl.registerFactory<MapBloc>(
      () => MapBloc(
        searchPlacesUseCase: sl<SearchPlacesUseCase>(),
        reverseGeocodeUseCase: sl<ReverseGeocodeUseCase>(),
        getMapListingsUseCase: sl<GetMapListingsUseCase>(),
      ),
    );
  }

  // Land Feature
  if (!sl.isRegistered<LandRemoteDataSource>()) {
    sl.registerLazySingleton<LandRemoteDataSource>(
      () => LandRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<LandRepository>()) {
    sl.registerLazySingleton<LandRepository>(
      () => LandRepositoryImpl(remoteDataSource: sl<LandRemoteDataSource>()),
    );
  }
  if (!sl.isRegistered<GetLandListingsUseCase>()) {
    sl.registerLazySingleton<GetLandListingsUseCase>(
      () => GetLandListingsUseCase(sl<LandRepository>()),
    );
  }
  if (!sl.isRegistered<LandBloc>()) {
    sl.registerFactory<LandBloc>(
      () => LandBloc(
        getLandListingsUseCase: sl<GetLandListingsUseCase>(),
      ),
    );
  }

  // Owner Feature
  if (!sl.isRegistered<OwnerRemoteDataSource>()) {
    sl.registerLazySingleton<OwnerRemoteDataSource>(
      () => OwnerRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<OwnerRepository>()) {
    sl.registerLazySingleton<OwnerRepository>(
      () => OwnerRepositoryImpl(remoteDataSource: sl<OwnerRemoteDataSource>()),
    );
  }
  if (!sl.isRegistered<GetOwnerDashboardStatsUseCase>()) {
    sl.registerLazySingleton<GetOwnerDashboardStatsUseCase>(
      () => GetOwnerDashboardStatsUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<GetMyListingsUseCase>()) {
    sl.registerLazySingleton<GetMyListingsUseCase>(
      () => GetMyListingsUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<CreateListingUseCase>()) {
    sl.registerLazySingleton<CreateListingUseCase>(
      () => CreateListingUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<UpdateListingUseCase>()) {
    sl.registerLazySingleton<UpdateListingUseCase>(
      () => UpdateListingUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<TransitionListingStatusUseCase>()) {
    sl.registerLazySingleton<TransitionListingStatusUseCase>(
      () => TransitionListingStatusUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<UploadMediaUseCase>()) {
    sl.registerLazySingleton<UploadMediaUseCase>(
      () => UploadMediaUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<GetVerificationDocumentsUseCase>()) {
    sl.registerLazySingleton<GetVerificationDocumentsUseCase>(
      () => GetVerificationDocumentsUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<UploadVerificationDocumentUseCase>()) {
    sl.registerLazySingleton<UploadVerificationDocumentUseCase>(
      () => UploadVerificationDocumentUseCase(sl<OwnerRepository>()),
    );
  }
  if (!sl.isRegistered<OwnerDashboardBloc>()) {
    sl.registerFactory<OwnerDashboardBloc>(
      () => OwnerDashboardBloc(
        getDashboardStatsUseCase: sl<GetOwnerDashboardStatsUseCase>(),
        getMyListingsUseCase: sl<GetMyListingsUseCase>(),
        transitionListingStatusUseCase: sl<TransitionListingStatusUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<CreateListingBloc>()) {
    sl.registerFactory<CreateListingBloc>(
      () => CreateListingBloc(
        createListingUseCase: sl<CreateListingUseCase>(),
        updateListingUseCase: sl<UpdateListingUseCase>(),
        uploadMediaUseCase: sl<UploadMediaUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<VerificationBloc>()) {
    sl.registerFactory<VerificationBloc>(
      () => VerificationBloc(
        getDocumentsUseCase: sl<GetVerificationDocumentsUseCase>(),
        uploadDocumentUseCase: sl<UploadVerificationDocumentUseCase>(),
      ),
    );
  }

  // Content Feature (Guides, Static Pages, Blog, Q&A)
  if (!sl.isRegistered<ContentRemoteDataSource>()) {
    sl.registerLazySingleton<ContentRemoteDataSource>(
      () => ContentRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }
  if (!sl.isRegistered<ContentRepository>()) {
    sl.registerLazySingleton<ContentRepository>(
      () => ContentRepositoryImpl(remoteDataSource: sl<ContentRemoteDataSource>()),
    );
  }
  if (!sl.isRegistered<GetGuidesUseCase>()) {
    sl.registerLazySingleton<GetGuidesUseCase>(
      () => GetGuidesUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetGuideDetailUseCase>()) {
    sl.registerLazySingleton<GetGuideDetailUseCase>(
      () => GetGuideDetailUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetStaticPageUseCase>()) {
    sl.registerLazySingleton<GetStaticPageUseCase>(
      () => GetStaticPageUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetBlogPostsUseCase>()) {
    sl.registerLazySingleton<GetBlogPostsUseCase>(
      () => GetBlogPostsUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetBlogPostDetailUseCase>()) {
    sl.registerLazySingleton<GetBlogPostDetailUseCase>(
      () => GetBlogPostDetailUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetPostCommentsUseCase>()) {
    sl.registerLazySingleton<GetPostCommentsUseCase>(
      () => GetPostCommentsUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<AddPostCommentUseCase>()) {
    sl.registerLazySingleton<AddPostCommentUseCase>(
      () => AddPostCommentUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetQuestionsUseCase>()) {
    sl.registerLazySingleton<GetQuestionsUseCase>(
      () => GetQuestionsUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetQuestionDetailUseCase>()) {
    sl.registerLazySingleton<GetQuestionDetailUseCase>(
      () => GetQuestionDetailUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<AskQuestionUseCase>()) {
    sl.registerLazySingleton<AskQuestionUseCase>(
      () => AskQuestionUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetAnswersUseCase>()) {
    sl.registerLazySingleton<GetAnswersUseCase>(
      () => GetAnswersUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<PostAnswerUseCase>()) {
    sl.registerLazySingleton<PostAnswerUseCase>(
      () => PostAnswerUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<GetMyQuestionsUseCase>()) {
    sl.registerLazySingleton<GetMyQuestionsUseCase>(
      () => GetMyQuestionsUseCase(sl<ContentRepository>()),
    );
  }
  if (!sl.isRegistered<BlogBloc>()) {
    sl.registerFactory<BlogBloc>(
      () => BlogBloc(
        getBlogPostsUseCase: sl<GetBlogPostsUseCase>(),
        getBlogPostDetailUseCase: sl<GetBlogPostDetailUseCase>(),
        getPostCommentsUseCase: sl<GetPostCommentsUseCase>(),
        addPostCommentUseCase: sl<AddPostCommentUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<QaBloc>()) {
    sl.registerFactory<QaBloc>(
      () => QaBloc(
        getQuestionsUseCase: sl<GetQuestionsUseCase>(),
        getQuestionDetailUseCase: sl<GetQuestionDetailUseCase>(),
        askQuestionUseCase: sl<AskQuestionUseCase>(),
        getAnswersUseCase: sl<GetAnswersUseCase>(),
        postAnswerUseCase: sl<PostAnswerUseCase>(),
        getMyQuestionsUseCase: sl<GetMyQuestionsUseCase>(),
      ),
    );
  }
  if (!sl.isRegistered<StaticContentBloc>()) {
    sl.registerFactory<StaticContentBloc>(
      () => StaticContentBloc(
        getGuidesUseCase: sl<GetGuidesUseCase>(),
        getGuideDetailUseCase: sl<GetGuideDetailUseCase>(),
        getStaticPageUseCase: sl<GetStaticPageUseCase>(),
      ),
    );
  }
}

Future<void> resetDependencies() async {
  await sl.reset();
}
