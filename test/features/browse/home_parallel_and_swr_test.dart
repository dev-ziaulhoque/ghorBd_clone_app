import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/core/cache/response_cache.dart';
import 'package:ghorbad_clone_app/features/browse/data/datasources/browse_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/area_model.dart';
import 'package:ghorbad_clone_app/features/browse/data/repositories/browse_repository_impl.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/area_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/facets_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/listing_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/usecases/get_areas_usecase.dart';
import 'package:ghorbad_clone_app/features/browse/domain/usecases/get_listings_usecase.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/bloc/home_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetListingsUseCase extends Mock implements GetListingsUseCase {}

class MockGetAreasUseCase extends Mock implements GetAreasUseCase {}

class MockBrowseRemoteDataSource extends Mock
    implements BrowseRemoteDataSource {}

const _listing = ListingEntity(
  id: 'l1',
  title: 'Flat',
  slug: 'flat',
  description: 'd',
  propertyType: 'apartment',
  purpose: 'rent',
  areaSlug: 'uttara',
  city: 'dhaka',
  division: 'dhaka',
  address: 'Uttara',
  pricePerMonth: 20000,
);

const _areaA = AreaEntity(
  id: 'a1',
  slug: 'uttara',
  name: 'উত্তরা',
  nameEn: 'Uttara',
  city: 'dhaka',
  division: 'dhaka',
  popular: true,
);

const _areaB = AreaEntity(
  id: 'a2',
  slug: 'mirpur',
  name: 'মিরপুর',
  nameEn: 'Mirpur',
  city: 'dhaka',
  division: 'dhaka',
  popular: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerFallbackValue(const ListingFilterParams());

  group('HomeBloc parallel fetch (Round 2)', () {
    test('all four section loads are in flight concurrently', () async {
      final listings = MockGetListingsUseCase();
      final areas = MockGetAreasUseCase();

      var inFlight = 0;
      var maxInFlight = 0;
      Future<T> tracked<T>(T value) async {
        inFlight++;
        if (inFlight > maxInFlight) maxInFlight = inFlight;
        await Future<void>.delayed(const Duration(milliseconds: 120));
        inFlight--;
        return value;
      }

      when(() => listings(any())).thenAnswer(
        (_) => tracked(
          const Right((
            listings: [_listing],
            total: 1,
            totalPages: 1,
            facets: null,
          )),
        ),
      );
      when(() => areas(popular: true)).thenAnswer(
        (_) => tracked(const Right([_areaA])),
      );

      final bloc = HomeBloc(
        getListingsUseCase: listings,
        getAreasUseCase: areas,
      );
      addTearDown(bloc.close);

      bloc.add(const HomeFetchData());
      final loaded = await bloc.stream
          .firstWhere((s) => s is HomeLoaded)
          .timeout(const Duration(seconds: 5));

      expect(loaded, isA<HomeLoaded>());
      // Sequential code would peak at 1; parallel peaks at 4
      // (featured + areas + rent + sale).
      expect(maxInFlight, 4);
    });
  });

  group('HomeBloc SWR areas update (Round 2)', () {
    test('re-emits HomeLoaded with fresh areas when the cache updates',
        () async {
      final listings = MockGetListingsUseCase();
      final areas = MockGetAreasUseCase();
      final cache = ResponseCache();

      when(() => listings(any())).thenAnswer(
        (_) async => const Right((
          listings: [_listing],
          total: 1,
          totalPages: 1,
          facets: null,
        )),
      );
      // First read serves area A; after revalidation the use case
      // serves the fresh area B (as the repository would from cache).
      var areasCalls = 0;
      when(() => areas(popular: true)).thenAnswer((_) async {
        areasCalls++;
        return Right(areasCalls == 1 ? [_areaA] : [_areaB]);
      });

      final bloc = HomeBloc(
        getListingsUseCase: listings,
        getAreasUseCase: areas,
        cache: cache,
      );
      addTearDown(bloc.close);

      bloc.add(const HomeFetchData());
      final first = await bloc.stream
          .firstWhere((s) => s is HomeLoaded)
          .timeout(const Duration(seconds: 5)) as HomeLoaded;
      expect(first.popularAreas, [_areaA]);

      // Simulate the repository's background revalidation landing.
      await cache.write(
        BrowseRepositoryImpl.areasCacheKey(popular: true),
        const [],
      );

      final updated = await bloc.stream
          .firstWhere(
            (s) => s is HomeLoaded && s.popularAreas.contains(_areaB),
          )
          .timeout(const Duration(seconds: 5));
      expect(updated, isA<HomeLoaded>());
    });
  });

  group('BrowseRepositoryImpl areas SWR (Round 2)', () {
    late MockBrowseRemoteDataSource ds;
    late SharedPreferences prefs;

    const freshModel = AreaModel(
      id: 'a9',
      slug: 'banani',
      name: 'বনানী',
      nameEn: 'Banani',
      city: 'dhaka',
      division: 'dhaka',
      popular: true,
    );

    setUp(() async {
      ds = MockBrowseRemoteDataSource();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Map<String, dynamic> areaJson(String id, String slug) => {
          'id': id,
          'slug': slug,
          'name': slug,
          'nameEn': slug,
          'city': 'dhaka',
          'division': 'dhaka',
          'popular': true,
          'listingCount': 3,
        };

    test('fresh cache hit is served without any network call', () async {
      await prefs.setString(
        'ghorbd_cache_areas_popular',
        jsonEncode({
          't': DateTime.now().millisecondsSinceEpoch,
          'd': [areaJson('cached1', 'uttara')],
        }),
      );
      final repo = BrowseRepositoryImpl(
        remoteDataSource: ds,
        cache: ResponseCache(prefs),
      );

      final result = await repo.getAreas(popular: true);
      final areas = result.getOrElse((_) => throw StateError('left'));
      expect(areas.single.id, 'cached1');
      verifyNever(() => ds.getAreas(popular: any(named: 'popular')));
    });

    test('stale cache is served instantly and revalidated in background',
        () async {
      await prefs.setString(
        'ghorbd_cache_areas_popular',
        jsonEncode({
          't': DateTime.now()
              .subtract(const Duration(hours: 13))
              .millisecondsSinceEpoch,
          'd': [areaJson('stale1', 'uttara')],
        }),
      );
      when(() => ds.getAreas(popular: true))
          .thenAnswer((_) async => [freshModel]);
      final cache = ResponseCache(prefs);
      final repo = BrowseRepositoryImpl(remoteDataSource: ds, cache: cache);

      final result = await repo.getAreas(popular: true);
      final areas = result.getOrElse((_) => throw StateError('left'));
      expect(areas.single.id, 'stale1'); // stale served instantly

      // Background revalidation updates the cache…
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final entry = await cache.read('areas_popular');
      expect((entry!.data as List).single['id'], 'a9');

      // …and the next read serves the fresh copy with no extra call.
      final second = await repo.getAreas(popular: true);
      expect(second.getOrElse((_) => throw StateError('left')).single.id,
          'a9');
      verify(() => ds.getAreas(popular: true)).called(1);
    });

    test('cache miss fetches network and populates the cache', () async {
      when(() => ds.getAreas(popular: true))
          .thenAnswer((_) async => [freshModel]);
      final cache = ResponseCache(prefs);
      final repo = BrowseRepositoryImpl(remoteDataSource: ds, cache: cache);

      final result = await repo.getAreas(popular: true);
      expect(result.getOrElse((_) => throw StateError('left')).single.id,
          'a9');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final entry = await cache.read('areas_popular');
      expect(entry, isNotNull);
    });
  });
}
