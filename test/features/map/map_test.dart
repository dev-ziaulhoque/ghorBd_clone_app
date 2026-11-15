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
import 'package:ghorbad_clone_app/features/map/data/datasources/map_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/map/data/models/place_model.dart';
import 'package:ghorbad_clone_app/features/map/data/repositories/map_repository_impl.dart';
import 'package:ghorbad_clone_app/features/map/domain/entities/place_entity.dart';
import 'package:ghorbad_clone_app/features/map/domain/repositories/map_repository.dart';
import 'package:ghorbad_clone_app/features/map/domain/usecases/map_usecases.dart';
import 'package:ghorbad_clone_app/features/map/presentation/bloc/map_bloc.dart';
import 'package:ghorbad_clone_app/features/map/presentation/pages/map_page.dart';
import 'package:ghorbad_clone_app/features/map/presentation/utils/dhaka_coordinates.dart';
import 'package:ghorbad_clone_app/features/map/presentation/widgets/dhaka_map_painter.dart';
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
    Widget buildTestWidget({Locale locale = const Locale('bn')}) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('bn'), Locale('en')],
        home: const MapPage(),
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

    testWidgets('interacts with area chips, map controls, and card dismiss', (tester) async {
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

      // Area chips exist
      expect(find.text('উত্তরা'), findsOneWidget);
      await tester.tap(find.text('উত্তরা'));
      await tester.pump(const Duration(milliseconds: 100));

      // Map controls exist
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pump(const Duration(milliseconds: 100));

      // View List button is visible
      expect(find.text('তালিকা দেখুন'), findsOneWidget);

      // Selected card close button dismisses card
      expect(find.byKey(const Key('map_selected_listing_card')), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 100));

      // Card is dismissed
      expect(find.byKey(const Key('map_selected_listing_card')), findsNothing);

      // Tapping the pin reopens card
      await tester.tap(find.byKey(const ValueKey('map_pin_map-list-1')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('map_selected_listing_card')), findsOneWidget);
    });
  });

  group('DhakaCoordinates and DhakaMapPainter', () {
    test('projects coordinates into valid canvas bounds', () {
      final uttara = DhakaCoordinates.project(23.8759, 90.3795);
      expect(uttara.dx, greaterThan(0));
      expect(uttara.dx, lessThan(DhakaCoordinates.canvasWidth));
      expect(uttara.dy, greaterThan(0));
      expect(uttara.dy, lessThan(DhakaCoordinates.canvasHeight));

      final motijheel = DhakaCoordinates.project(23.7330, 90.4172);
      expect(motijheel.dy, greaterThan(uttara.dy)); // Motijheel is south of Uttara
    });

    test('getListingOffset computes deterministic dispersion', () {
      final offset1 = DhakaCoordinates.getListingOffset(sampleListing, 0, 3);
      final offset2 = DhakaCoordinates.getListingOffset(sampleListing, 1, 3);
      expect(offset1, isNot(equals(offset2)));
    });

    test('DhakaMapPainter repaints on style or dark change', () {
      final p1 = DhakaMapPainter(isDark: true, style: MapThemeStyle.modern);
      final p2 = DhakaMapPainter(isDark: false, style: MapThemeStyle.modern);
      final p3 = DhakaMapPainter(isDark: true, style: MapThemeStyle.blueprint);

      expect(p1.shouldRepaint(p2), isTrue);
      expect(p1.shouldRepaint(p3), isTrue);
      expect(
        p1.shouldRepaint(DhakaMapPainter(isDark: true, style: MapThemeStyle.modern)),
        isFalse,
      );
    });
  });
}
