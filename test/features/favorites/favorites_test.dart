import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/listing_model.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/listing_entity.dart';
import 'package:ghorbad_clone_app/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:ghorbad_clone_app/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:ghorbad_clone_app/features/favorites/domain/usecases/favorites_usecases.dart';
import 'package:ghorbad_clone_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ghorbad_clone_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:ghorbad_clone_app/shared/widgets/empty_view.dart';
import 'package:ghorbad_clone_app/shared/widgets/error_view.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRemoteDataSource extends Mock
    implements FavoritesRemoteDataSource {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockGetFavoritesUseCase extends Mock implements GetFavoritesUseCase {}

class MockAddFavoriteUseCase extends Mock implements AddFavoriteUseCase {}

class MockRemoveFavoriteUseCase extends Mock implements RemoveFavoriteUseCase {}

class MockFavoritesBloc extends Mock implements FavoritesBloc {}

void main() {
  const sampleListing = ListingEntity(
    id: 'fav-123',
    ownerId: 'owner-1',
    listerType: 'owner',
    title: 'Gulshan 2 Luxury Flat',
    slug: 'gulshan-2-luxury-flat',
    description: 'Near park',
    propertyType: 'apartment',
    purpose: 'rent',
    areaSlug: 'gulshan',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Road 11',
    pricePerMonth: 85000,
    images: ['https://example.com/img1.jpg'],
    amenities: ['lift', 'generator'],
    verified: true,
  );

  const sampleListingModel = ListingModel(
    id: 'fav-123',
    ownerId: 'owner-1',
    listerType: 'owner',
    title: 'Gulshan 2 Luxury Flat',
    slug: 'gulshan-2-luxury-flat',
    description: 'Near park',
    propertyType: 'apartment',
    purpose: 'rent',
    areaSlug: 'gulshan',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Road 11',
    pricePerMonth: 85000,
    images: ['https://example.com/img1.jpg'],
    amenities: ['lift', 'generator'],
    verified: true,
  );

  group('FavoritesRepositoryImpl', () {
    late MockFavoritesRemoteDataSource mockDataSource;
    late FavoritesRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockFavoritesRemoteDataSource();
      repository = FavoritesRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('getFavorites returns List<ListingEntity> on success', () async {
      when(() => mockDataSource.getFavorites())
          .thenAnswer((_) async => [sampleListingModel]);

      final result = await repository.getFavorites();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should succeed'),
        (items) {
          expect(items.length, 1);
          expect(items.first.id, 'fav-123');
        },
      );
    });

    test('getFavorites returns Failure on exception', () async {
      when(() => mockDataSource.getFavorites())
          .thenThrow(const ServerException('Server error', 500));

      final result = await repository.getFavorites();

      expect(result.isLeft(), isTrue);
    });

    test('addFavorite returns true on success', () async {
      when(() => mockDataSource.addFavorite('fav-123'))
          .thenAnswer((_) async => true);

      final result = await repository.addFavorite('fav-123');

      expect(result, const Right(true));
    });

    test('removeFavorite returns true on success', () async {
      when(() => mockDataSource.removeFavorite('fav-123'))
          .thenAnswer((_) async => true);

      final result = await repository.removeFavorite('fav-123');

      expect(result, const Right(true));
    });
  });

  group('FavoritesBloc', () {
    late MockGetFavoritesUseCase mockGet;
    late MockAddFavoriteUseCase mockAdd;
    late MockRemoveFavoriteUseCase mockRemove;
    late FavoritesBloc bloc;

    setUp(() {
      mockGet = MockGetFavoritesUseCase();
      mockAdd = MockAddFavoriteUseCase();
      mockRemove = MockRemoveFavoriteUseCase();
      bloc = FavoritesBloc(
        getFavoritesUseCase: mockGet,
        addFavoriteUseCase: mockAdd,
        removeFavoriteUseCase: mockRemove,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is FavoritesInitial', () {
      expect(bloc.state, const FavoritesInitial());
    });

    test('FetchFavorites emits [Loading, Loaded] on success', () async {
      when(() => mockGet()).thenAnswer((_) async => const Right([sampleListing]));

      final expectedStates = [
        const FavoritesLoading(),
        const FavoritesLoaded([sampleListing]),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const FetchFavorites());
    });

    test('FetchFavorites emits [Loading, Error] on failure', () async {
      when(() => mockGet()).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'fail', messageKey: 'error_server')),
      );

      final expectedStates = [
        const FavoritesLoading(),
        const FavoritesError('error_server'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const FetchFavorites());
    });

    test('ToggleFavorite removes if already favorite', () async {
      when(() => mockGet()).thenAnswer((_) async => const Right([sampleListing]));
      when(() => mockRemove(sampleListing.id)).thenAnswer((_) async => const Right(true));

      bloc.add(const FetchFavorites());
      await pumpEventQueue();

      bloc.add(const ToggleFavorite(sampleListing));
      await pumpEventQueue();

      expect(bloc.state, const FavoritesLoaded([]));
    });

    test('ToggleFavorite adds if not in favorites', () async {
      when(() => mockGet()).thenAnswer((_) async => const Right([]));
      when(() => mockAdd(sampleListing.id)).thenAnswer((_) async => const Right(true));

      bloc.add(const FetchFavorites());
      await pumpEventQueue();

      bloc.add(const ToggleFavorite(sampleListing));
      await pumpEventQueue();

      expect((bloc.state as FavoritesLoaded).favorites.length, 1);
    });

    test('RemoveFavorite removes listing from list', () async {
      when(() => mockGet()).thenAnswer((_) async => const Right([sampleListing]));
      when(() => mockRemove('fav-123')).thenAnswer((_) async => const Right(true));

      bloc.add(const FetchFavorites());
      await pumpEventQueue();

      bloc.add(const RemoveFavorite('fav-123'));
      await pumpEventQueue();

      expect(bloc.state, const FavoritesLoaded([]));
    });
  });

  group('FavoritesPage Widget Tests', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('bn'), Locale('en')],
        home: FavoritesPage(),
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

    testWidgets('renders empty view when favorites list is empty', (tester) async {
      final mockRepo = MockFavoritesRepository();
      when(() => mockRepo.getFavorites())
          .thenAnswer((_) async => const Right([]));

      sl.unregister<FavoritesRepository>();
      sl.registerLazySingleton<FavoritesRepository>(() => mockRepo);
      sl.unregister<GetFavoritesUseCase>();
      sl.registerLazySingleton<GetFavoritesUseCase>(
        () => GetFavoritesUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppEmptyView), findsOneWidget);
    });

    testWidgets('renders list with ListingCard when favorites are loaded', (tester) async {
      final mockRepo = MockFavoritesRepository();
      when(() => mockRepo.getFavorites())
          .thenAnswer((_) async => const Right([sampleListing]));

      sl.unregister<FavoritesRepository>();
      sl.registerLazySingleton<FavoritesRepository>(() => mockRepo);
      sl.unregister<GetFavoritesUseCase>();
      sl.registerLazySingleton<GetFavoritesUseCase>(
        () => GetFavoritesUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Gulshan 2 Luxury Flat'), findsOneWidget);
    });

    testWidgets('renders error view on failure and allows retry', (tester) async {
      final mockRepo = MockFavoritesRepository();
      when(() => mockRepo.getFavorites()).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'No internet', messageKey: 'error_network')),
      );

      sl.unregister<FavoritesRepository>();
      sl.registerLazySingleton<FavoritesRepository>(() => mockRepo);
      sl.unregister<GetFavoritesUseCase>();
      sl.registerLazySingleton<GetFavoritesUseCase>(
        () => GetFavoritesUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppErrorView), findsOneWidget);
    });
  });
}
