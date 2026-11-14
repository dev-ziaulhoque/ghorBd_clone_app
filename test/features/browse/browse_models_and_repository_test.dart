import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/browse/data/datasources/browse_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/area_model.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/facets_model.dart';
import 'package:ghorbad_clone_app/features/browse/data/models/listing_model.dart';
import 'package:ghorbad_clone_app/features/browse/data/repositories/browse_repository_impl.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/facets_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockBrowseRemoteDataSource extends Mock
    implements BrowseRemoteDataSource {}

void main() {
  late MockBrowseRemoteDataSource mockRemoteDataSource;
  late BrowseRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const ListingFilterParams());
  });

  setUp(() {
    mockRemoteDataSource = MockBrowseRemoteDataSource();
    repository =
        BrowseRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const sampleListingJson = {
    'id': '6671a0b2c3d4e5f601234567',
    'ownerId': '665f1c2e9b1d4a0012ab34cd',
    'listerType': 'owner',
    'title': 'Uttara Sector 7 — 3 bed family flat',
    'slug': 'uttara-sector-7-3-bed-family-flat',
    'description':
        'South-facing, lift and generator, 5 minutes to the metro station.',
    'propertyType': 'apartment',
    'purpose': 'rent',
    'areaSlug': 'uttara',
    'city': 'dhaka',
    'division': 'dhaka',
    'address': 'Road 12, Sector 7, Uttara',
    'floor': 5,
    'unitNumber': '5B',
    'rooms': {
      'bed': 3,
      'bath': 2,
    },
    'size': 1350,
    'pricePerMonth': 25000,
    'currency': 'BDT',
    'images': [
      'https://ghorbd.com/uploads/flat-1.webp',
      'https://ghorbd.com/uploads/flat-2.webp',
    ],
    'amenities': ['lift', 'generator', 'parking', 'cctv'],
    'verified': true,
    'verifiedAt': '2026-10-01T08:00:00.000Z',
    'featured': true,
    'hasContactPhone': true,
    'viewCount': 142,
  };

  group('Browse Models', () {
    test('ListingModel.fromJson correctly parses real API JSON format', () {
      final model = ListingModel.fromJson(sampleListingJson);

      expect(model.id, '6671a0b2c3d4e5f601234567');
      expect(model.title, 'Uttara Sector 7 — 3 bed family flat');
      expect(model.bed, 3);
      expect(model.bath, 2);
      expect(model.size, 1350);
      expect(model.pricePerMonth, 25000);
      expect(model.verified, true);
      expect(model.featured, true);
      expect(model.images.length, 2);
      expect(model.viewCount, 142);

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.title, model.title);
      expect(entity.pricePerMonth, 25000);
    });

    test('AreaModel.fromJson parses API-048 curated area format', () {
      final areaJson = {
        'id': '66d0112233445566778899cc',
        'slug': 'uttara',
        'name': 'উত্তরা',
        'nameEn': 'Uttara',
        'city': 'dhaka',
        'division': 'dhaka',
        'popular': true,
        'listingCount': 42,
      };

      final model = AreaModel.fromJson(areaJson);
      expect(model.slug, 'uttara');
      expect(model.name, 'উত্তরা');
      expect(model.nameEn, 'Uttara');
      expect(model.popular, true);
      expect(model.listingCount, 42);

      final entity = model.toEntity();
      expect(entity.slug, 'uttara');
      expect(entity.name, 'উত্তরা');
    });

    test('FacetsModel.fromJson parses search facets properly', () {
      final facetsJson = {
        'propertyType': [
          {'value': 'apartment', 'count': 25},
          {'value': 'room', 'count': 10},
        ],
        'division': [
          {'value': 'dhaka', 'count': 35},
        ],
        'area': [
          {'value': 'uttara', 'label': 'উত্তরা', 'count': 18},
        ],
        'bedrooms': [
          {'value': 2, 'count': 16},
          {'value': 3, 'count': 18},
        ],
        'verified': [
          {'value': true, 'count': 30},
        ],
        'price': {
          'min': 8000,
          'max': 65000,
        },
      };

      final model = FacetsModel.fromJson(facetsJson);
      expect(model.propertyTypes.length, 2);
      expect(model.propertyTypes.first.value, 'apartment');
      expect(model.propertyTypes.first.count, 25);
      expect(model.minPrice, 8000);
      expect(model.maxPrice, 65000);
    });

    test('ListingFilterParams.toQueryParameters maps all active filters', () {
      const params = ListingFilterParams(
        page: 2,
        perPage: 15,
        sort: 'price_asc',
        purpose: 'rent',
        propertyType: 'apartment',
        division: 'dhaka',
        bedrooms: 3,
        minPrice: 15000,
        maxPrice: 30000,
        verified: true,
        search: 'Dhanmondi',
      );

      final query = params.toQueryParameters();
      expect(query['page'], 2);
      expect(query['perPage'], 15);
      expect(query['sort'], 'price_asc');
      expect(query['purpose'], 'rent');
      expect(query['propertyType'], 'apartment');
      expect(query['bedrooms'], 3);
      expect(query['minPrice'], 15000);
      expect(query['maxPrice'], 30000);
      expect(query['verified'], true);
      expect(query['search'], 'Dhanmondi');
    });
  });

  group('BrowseRepositoryImpl', () {
    test('getListings returns entity list and pagination metadata on success',
        () async {
      when(() => mockRemoteDataSource.getListings(any())).thenAnswer(
        (_) async => (
          listings: [ListingModel.fromJson(sampleListingJson)],
          total: 1,
          totalPages: 1,
          facets: null,
        ),
      );

      final result =
          await repository.getListings(const ListingFilterParams());

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.listings.length, 1);
          expect(data.listings.first.id, '6671a0b2c3d4e5f601234567');
          expect(data.total, 1);
        },
      );
    });

    test('getListingDetail returns listing and similar items on success',
        () async {
      when(() => mockRemoteDataSource.getListingDetail('sample-slug'))
          .thenAnswer(
        (_) async => (
          listing: ListingModel.fromJson(sampleListingJson),
          similar: <ListingModel>[],
        ),
      );

      final result = await repository.getListingDetail('sample-slug');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (data) {
          expect(data.listing.id, '6671a0b2c3d4e5f601234567');
          expect(data.similar, isEmpty);
        },
      );
    });

    test('getListingDetail returns NotFoundFailure on NotFoundException',
        () async {
      when(() => mockRemoteDataSource.getListingDetail('missing-slug'))
          .thenThrow(
        const ApiException(
          message: 'Listing not found',
          code: 'NOT_FOUND',
          statusCode: 404,
        ),
      );

      final result = await repository.getListingDetail('missing-slug');

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('getAreas returns area list on success', () async {
      when(() => mockRemoteDataSource.getAreas(popular: true)).thenAnswer(
        (_) async => [
          const AreaModel(
            id: '1',
            slug: 'uttara',
            name: 'উত্তরা',
            nameEn: 'Uttara',
            city: 'dhaka',
            division: 'dhaka',
            popular: true,
          ),
        ],
      );

      final result = await repository.getAreas(popular: true);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (areas) {
          expect(areas.length, 1);
          expect(areas.first.name, 'উত্তরা');
        },
      );
    });
  });
}
