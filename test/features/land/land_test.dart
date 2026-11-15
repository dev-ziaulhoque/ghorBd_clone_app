import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/listing_model.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/facets_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/listing_entity.dart';
import 'package:ghorbad_clone_app/features/land/data/datasources/land_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/land/data/repositories/land_repository_impl.dart';
import 'package:ghorbad_clone_app/features/land/domain/repositories/land_repository.dart';
import 'package:ghorbad_clone_app/features/land/domain/usecases/get_land_listings_usecase.dart';
import 'package:ghorbad_clone_app/features/land/presentation/bloc/land_bloc.dart';
import 'package:ghorbad_clone_app/features/land/presentation/pages/land_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:ghorbad_clone_app/shared/widgets/app_filter_chip.dart';
import 'package:ghorbad_clone_app/shared/widgets/empty_view.dart';
import 'package:ghorbad_clone_app/shared/widgets/error_view.dart';
import 'package:mocktail/mocktail.dart';

class MockLandRemoteDataSource extends Mock implements LandRemoteDataSource {}

class MockLandRepository extends Mock implements LandRepository {}

class MockGetLandListingsUseCase extends Mock
    implements GetLandListingsUseCase {}

void main() {
  const sampleLandListing = ListingEntity(
    id: 'land-123',
    title: 'Purbachal 5 Katha Residential Plot',
    slug: 'purbachal-5-katha-plot',
    description: 'Corner plot with 30ft road',
    propertyType: 'land',
    purpose: 'sale',
    areaSlug: 'purbachal',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Sector 4, Road 12',
    pricePerMonth: 15000000,
    landType: 'residential',
    landAreaValue: 5.0,
    landAreaUnit: 'katha',
    landRoadWidthFt: 30.0,
    landFacing: 'south',
    verified: true,
  );

  const sampleLandModel = ListingModel(
    id: 'land-123',
    title: 'Purbachal 5 Katha Residential Plot',
    slug: 'purbachal-5-katha-plot',
    description: 'Corner plot with 30ft road',
    propertyType: 'land',
    purpose: 'sale',
    areaSlug: 'purbachal',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Sector 4, Road 12',
    pricePerMonth: 15000000,
    landType: 'residential',
    landAreaValue: 5.0,
    landAreaUnit: 'katha',
    landRoadWidthFt: 30.0,
    landFacing: 'south',
    verified: true,
  );

  setUpAll(() {
    registerFallbackValue(const ListingFilterParams());
  });

  group('LandRepositoryImpl', () {
    late MockLandRemoteDataSource mockDataSource;
    late LandRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockLandRemoteDataSource();
      repository = LandRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('getLandListings returns land listings on success', () async {
      when(() => mockDataSource.getLandListings(any())).thenAnswer(
        (_) async => (listings: [sampleLandModel], total: 1, totalPages: 1),
      );

      final result =
          await repository.getLandListings(const ListingFilterParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should succeed'),
        (data) {
          expect(data.listings.length, 1);
          expect(data.listings.first.id, 'land-123');
          expect(data.listings.first.landAreaValue, 5.0);
        },
      );
    });

    test('getLandListings returns Failure on exception', () async {
      when(() => mockDataSource.getLandListings(any()))
          .thenThrow(const ServerException('Server error', 500));

      final result =
          await repository.getLandListings(const ListingFilterParams());

      expect(result.isLeft(), isTrue);
    });
  });

  group('LandBloc', () {
    late MockGetLandListingsUseCase mockUseCase;
    late LandBloc bloc;

    setUp(() {
      mockUseCase = MockGetLandListingsUseCase();
      bloc = LandBloc(getLandListingsUseCase: mockUseCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is LandInitial', () {
      expect(bloc.state, const LandInitial());
    });

    test('FetchLandListingsEvent emits [LandLoading, LandLoaded] on success',
        () async {
      when(() => mockUseCase(any())).thenAnswer(
        (_) async => const Right((
          listings: [sampleLandListing],
          total: 1,
          totalPages: 1,
        )),
      );

      final expectedStates = [
        const LandLoading(),
        const LandLoaded(
          listings: [sampleLandListing],
          total: 1,
          currentParams: ListingFilterParams(propertyType: 'land'),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const FetchLandListingsEvent());
    });

    test('FetchLandListingsEvent emits [LandLoading, LandError] on failure',
        () async {
      when(() => mockUseCase(any())).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'fail', messageKey: 'error_server'),
        ),
      );

      final expectedStates = [
        const LandLoading(),
        const LandError('error_server'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const FetchLandListingsEvent());
    });
  });

  group('LandPage Widget Tests', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        locale: Locale('bn'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('bn'), Locale('en')],
        home: LandPage(),
      );
    }

    setUp(() async {
      await sl.reset();
      SharedPreferences.setMockInitialValues({});
      await configureDependencies();
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('renders land listings and count header on success',
        (tester) async {
      final mockRepo = MockLandRepository();
      when(() => mockRepo.getLandListings(any())).thenAnswer(
        (_) async => const Right((
          listings: [sampleLandListing],
          total: 1,
          totalPages: 1,
        )),
      );

      sl.unregister<LandRepository>();
      sl.registerLazySingleton<LandRepository>(() => mockRepo);
      sl.unregister<GetLandListingsUseCase>();
      sl.registerLazySingleton<GetLandListingsUseCase>(
        () => GetLandListingsUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppFilterChip), findsWidgets);
      expect(find.text('Purbachal 5 Katha Residential Plot'), findsOneWidget);
      expect(find.textContaining('জমির বিজ্ঞাপন পাওয়া গেছে'), findsOneWidget);
    });

    testWidgets('renders empty view when no land listings exist',
        (tester) async {
      final mockRepo = MockLandRepository();
      when(() => mockRepo.getLandListings(any())).thenAnswer(
        (_) async => const Right((
          listings: <ListingEntity>[],
          total: 0,
          totalPages: 0,
        )),
      );

      sl.unregister<LandRepository>();
      sl.registerLazySingleton<LandRepository>(() => mockRepo);
      sl.unregister<GetLandListingsUseCase>();
      sl.registerLazySingleton<GetLandListingsUseCase>(
        () => GetLandListingsUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppEmptyView), findsOneWidget);
    });

    testWidgets('renders error view on failure', (tester) async {
      final mockRepo = MockLandRepository();
      when(() => mockRepo.getLandListings(any())).thenAnswer(
        (_) async => const Left(
          NetworkFailure(message: 'No net', messageKey: 'error_network'),
        ),
      );

      sl.unregister<LandRepository>();
      sl.registerLazySingleton<LandRepository>(() => mockRepo);
      sl.unregister<GetLandListingsUseCase>();
      sl.registerLazySingleton<GetLandListingsUseCase>(
        () => GetLandListingsUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppErrorView), findsOneWidget);
    });
  });
}
