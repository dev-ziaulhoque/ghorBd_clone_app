import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/listing_model.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/facets_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/listing_entity.dart';
import 'package:ghorbad_clone_app/features/map/data/datasources/map_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/map/data/models/place_model.dart';
import 'package:ghorbad_clone_app/features/map/data/repositories/map_repository_impl.dart';
import 'package:ghorbad_clone_app/features/map/domain/entities/place_entity.dart';
import 'package:ghorbad_clone_app/features/map/domain/repositories/map_repository.dart';
import 'package:ghorbad_clone_app/features/map/domain/usecases/map_usecases.dart';
import 'package:ghorbad_clone_app/features/map/presentation/bloc/map_bloc.dart';
import 'package:ghorbad_clone_app/features/map/presentation/pages/map_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:ghorbad_clone_app/shared/widgets/empty_view.dart';
import 'package:ghorbad_clone_app/shared/widgets/error_view.dart';
import 'package:mocktail/mocktail.dart';

class MockMapRemoteDataSource extends Mock implements MapRemoteDataSource {}

class MockMapRepository extends Mock implements MapRepository {}

class MockSearchPlacesUseCase extends Mock implements SearchPlacesUseCase {}

class MockReverseGeocodeUseCase extends Mock implements ReverseGeocodeUseCase {}

class MockGetMapListingsUseCase extends Mock implements GetMapListingsUseCase {}

void main() {
  const samplePlaceModel = PlaceModel(
    label: 'Uttara Sector 7, Dhaka',
    fullLabel: 'Sector 7, Uttara, Dhaka, 1230, Bangladesh',
    lat: 23.8759,
    lng: 90.3795,
  );

  const samplePlaceEntity = PlaceEntity(
    label: 'Uttara Sector 7, Dhaka',
    fullLabel: 'Sector 7, Uttara, Dhaka, 1230, Bangladesh',
    lat: 23.8759,
    lng: 90.3795,
  );

  const sampleListing = ListingEntity(
    id: 'map-list-1',
    title: 'Uttara 3 Bed Apartment',
    slug: 'uttara-3-bed-apartment',
    description: 'Near metro station',
    propertyType: 'apartment',
    purpose: 'rent',
    areaSlug: 'uttara',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Sector 7',
    pricePerMonth: 28000,
    verified: true,
  );

  const sampleListingModel = ListingModel(
    id: 'map-list-1',
    title: 'Uttara 3 Bed Apartment',
    slug: 'uttara-3-bed-apartment',
    description: 'Near metro station',
    propertyType: 'apartment',
    purpose: 'rent',
    areaSlug: 'uttara',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Sector 7',
    pricePerMonth: 28000,
    verified: true,
  );

  setUpAll(() {
    registerFallbackValue(const ListingFilterParams());
  });

  group('PlaceModel', () {
    test('fromJson and toJson maintain data consistency', () {
      final json = {
        'label': 'Uttara Sector 7, Dhaka',
        'fullLabel': 'Sector 7, Uttara, Dhaka, 1230, Bangladesh',
        'lat': 23.8759,
        'lng': 90.3795,
      };

      final model = PlaceModel.fromJson(json);

      expect(model.label, 'Uttara Sector 7, Dhaka');
      expect(model.lat, 23.8759);
      expect(model.toJson(), json);
    });
  });

  group('MapRepositoryImpl', () {
    late MockMapRemoteDataSource mockDataSource;
    late MapRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockMapRemoteDataSource();
      repository = MapRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('searchPlaces returns List<PlaceEntity> on success', () async {
      when(() => mockDataSource.searchPlaces('Uttara'))
          .thenAnswer((_) async => [samplePlaceModel]);

      final result = await repository.searchPlaces('Uttara');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should succeed'),
        (places) => expect(places.first.label, 'Uttara Sector 7, Dhaka'),
      );
    });

    test('searchPlaces returns Failure on exception', () async {
      when(() => mockDataSource.searchPlaces('Uttara'))
          .thenThrow(const ServerException('Server error', 500));

      final result = await repository.searchPlaces('Uttara');

      expect(result.isLeft(), isTrue);
    });

    test('reverseGeocode returns PlaceEntity on success', () async {
      when(() => mockDataSource.reverseGeocode(23.8759, 90.3795))
          .thenAnswer((_) async => samplePlaceModel);

      final result = await repository.reverseGeocode(23.8759, 90.3795);

      expect(result, const Right(samplePlaceModel));
    });

    test('getMapListings returns List<ListingEntity> on success', () async {
      when(() => mockDataSource.getMapListings(any()))
          .thenAnswer((_) async => [sampleListingModel]);

      final result = await repository.getMapListings(const ListingFilterParams());

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should succeed'),
        (listings) => expect(listings.first.id, 'map-list-1'),
      );
    });
  });

  group('MapBloc', () {
    late MockSearchPlacesUseCase mockSearch;
    late MockReverseGeocodeUseCase mockReverse;
    late MockGetMapListingsUseCase mockListings;
    late MapBloc bloc;

    setUp(() {
      mockSearch = MockSearchPlacesUseCase();
      mockReverse = MockReverseGeocodeUseCase();
      mockListings = MockGetMapListingsUseCase();
      bloc = MapBloc(
        searchPlacesUseCase: mockSearch,
        reverseGeocodeUseCase: mockReverse,
        getMapListingsUseCase: mockListings,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is MapInitial', () {
      expect(bloc.state, const MapInitial());
    });

    test('LoadMapDataEvent emits [MapLoading, MapLoaded] on success', () async {
      when(() => mockListings(any()))
          .thenAnswer((_) async => const Right([sampleListing]));

      final expectedStates = [
        const MapLoading(),
        const MapLoaded(
          listings: [sampleListing],
          selectedListing: sampleListing,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadMapDataEvent());
    });

    test('LoadMapDataEvent emits [MapLoading, MapError] on failure', () async {
      when(() => mockListings(any())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'fail', messageKey: 'error_server')),
      );

      final expectedStates = [
        const MapLoading(),
        const MapError('error_server'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const LoadMapDataEvent());
    });

    test('SearchPlacesEvent updates placeSuggestions on success', () async {
      when(() => mockListings(any()))
          .thenAnswer((_) async => const Right([sampleListing]));
      when(() => mockSearch('Uttara'))
          .thenAnswer((_) async => const Right([samplePlaceEntity]));

      bloc.add(const LoadMapDataEvent());
      await pumpEventQueue();

      bloc.add(const SearchPlacesEvent('Uttara'));
      await pumpEventQueue();

      expect((bloc.state as MapLoaded).placeSuggestions.length, 1);
    });

    test('SelectListingPinEvent updates selectedListing', () async {
      when(() => mockListings(any()))
          .thenAnswer((_) async => const Right([sampleListing]));

      bloc.add(const LoadMapDataEvent());
      await pumpEventQueue();

      bloc.add(const SelectListingPinEvent(sampleListing));
      await pumpEventQueue();

      expect((bloc.state as MapLoaded).selectedListing, sampleListing);
    });
  });

  group('MapPage Widget Tests', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('bn'), Locale('en')],
        home: MapPage(),
      );
    }

    setUp(() async {
      await sl.reset();
      await configureDependencies();
    });

    tearDown(() async {
      await sl.reset();
    });

    testWidgets('renders map pins and selected listing card on success', (tester) async {
      final mockRepo = MockMapRepository();
      when(() => mockRepo.getMapListings(any()))
          .thenAnswer((_) async => const Right([sampleListing]));
      when(() => mockRepo.searchPlaces(any()))
          .thenAnswer((_) async => const Right([]));

      sl.unregister<MapRepository>();
      sl.registerLazySingleton<MapRepository>(() => mockRepo);
      sl.unregister<GetMapListingsUseCase>();
      sl.registerLazySingleton<GetMapListingsUseCase>(
        () => GetMapListingsUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('map_place_search_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('map_pin_map-list-1')), findsOneWidget);
      expect(find.byKey(const Key('map_selected_listing_card')), findsOneWidget);
    });

    testWidgets('renders empty view when no map listings found', (tester) async {
      final mockRepo = MockMapRepository();
      when(() => mockRepo.getMapListings(any()))
          .thenAnswer((_) async => const Right([]));

      sl.unregister<MapRepository>();
      sl.registerLazySingleton<MapRepository>(() => mockRepo);
      sl.unregister<GetMapListingsUseCase>();
      sl.registerLazySingleton<GetMapListingsUseCase>(
        () => GetMapListingsUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppEmptyView), findsOneWidget);
    });

    testWidgets('renders error view on failure', (tester) async {
      final mockRepo = MockMapRepository();
      when(() => mockRepo.getMapListings(any())).thenAnswer(
        (_) async => const Left(NetworkFailure(message: 'Offline', messageKey: 'error_network')),
      );

      sl.unregister<MapRepository>();
      sl.registerLazySingleton<MapRepository>(() => mockRepo);
      sl.unregister<GetMapListingsUseCase>();
      sl.registerLazySingleton<GetMapListingsUseCase>(
        () => GetMapListingsUseCase(mockRepo),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppErrorView), findsOneWidget);
    });
  });
}
