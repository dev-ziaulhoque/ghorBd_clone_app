import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghorbad_clone_app/features/owner/data/datasources/owner_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/owner/data/models/owner_dashboard_stats_model.dart';
import 'package:ghorbad_clone_app/features/owner/data/models/owner_listing_item_model.dart';
import 'package:ghorbad_clone_app/features/owner/data/models/verification_document_model.dart';
import 'package:ghorbad_clone_app/features/owner/data/repositories/owner_repository_impl.dart';
import 'package:ghorbad_clone_app/features/owner/domain/entities/create_listing_params.dart';
import 'package:ghorbad_clone_app/features/owner/domain/entities/owner_dashboard_stats.dart';
import 'package:ghorbad_clone_app/features/owner/domain/repositories/owner_repository.dart';
import 'package:ghorbad_clone_app/features/owner/domain/usecases/owner_usecases.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/bloc/create_listing_bloc.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/bloc/verification_bloc.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/pages/create_edit_listing_page.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/pages/owner_dashboard_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockOwnerRemoteDataSource extends Mock implements OwnerRemoteDataSource {}
class MockOwnerRepository extends Mock implements OwnerRepository {}

void main() {
  late MockOwnerRemoteDataSource mockRemoteDataSource;
  late OwnerRepositoryImpl repository;

  const tStatsModel = OwnerDashboardStatsModel(
    total: 6,
    active: 4,
    draft: 1,
    views: 1820,
    favorites: 37,
  );

  const tListingItemModel = OwnerListingItemModel(
    id: 'listing-123',
    ownerId: 'owner-1',
    title: 'উত্তরা সেক্টর ৭ ফ্ল্যাট',
    slug: 'uttara-sector-7-flat',
    description: 'দক্ষিণমুখী ৩ বেডের আধুনিক ফ্ল্যাট',
    propertyType: 'apartment',
    purpose: 'rent',
    areaSlug: 'uttara',
    city: 'dhaka',
    address: 'রোড ১২, সেক্টর ৭, উত্তরা',
    floor: 5,
    unitNumber: '5B',
    bed: 3,
    bath: 2,
    size: 1350,
    pricePerMonth: 25000,
    status: 'active',
    views: 420,
    availableTransitions: ['withdraw', 'archive'],
  );

  final tDocModel = VerificationDocumentModel(
    id: 'doc-1',
    userId: 'user-1',
    originalName: 'nid.jpg',
    mimeType: 'image/jpeg',
    size: 512000,
    createdAt: DateTime(2026, 10, 1),
  );

  setUpAll(() {
    registerFallbackValue(const CreateListingParams(
      title: 'Fallback',
      description: 'Desc',
      propertyType: 'apartment',
      areaSlug: 'uttara',
      address: 'Address',
      pricePerMonth: 10000,
    ));
  });

  setUp(() {
    mockRemoteDataSource = MockOwnerRemoteDataSource();
    repository = OwnerRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('bn'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('Owner Models & Data Tests', () {
    test('OwnerDashboardStatsModel parses fromJson correctly', () {
      final json = {
        'listings': {
          'total': 10,
          'active': 7,
          'draft': 2,
          'views': 2500,
          'favorites': 45,
        }
      };
      final model = OwnerDashboardStatsModel.fromJson(json);
      expect(model.total, 10);
      expect(model.active, 7);
      expect(model.views, 2500);

      final entity = model.toEntity();
      expect(entity.total, 10);
      expect(entity.active, 7);
    });

    test('OwnerListingItemModel parses fromJson correctly', () {
      final json = {
        'id': 'l-1',
        'title': 'Test Flat',
        'slug': 'test-flat',
        'propertyType': 'apartment',
        'purpose': 'rent',
        'areaSlug': 'mirpur',
        'city': 'dhaka',
        'address': 'Mirpur 10',
        'pricePerMonth': 18000,
        'status': 'active',
        'available': ['withdraw'],
        'rooms': {'bed': 2, 'bath': 2},
      };
      final model = OwnerListingItemModel.fromJson(json);
      expect(model.id, 'l-1');
      expect(model.bed, 2);
      expect(model.pricePerMonth, 18000);
      expect(model.availableTransitions, contains('withdraw'));

      final entity = model.toEntity();
      expect(entity.title, 'Test Flat');
      expect(entity.status, 'active');
    });

    test('VerificationDocumentModel parses fromJson correctly', () {
      final json = {
        'id': 'doc-1',
        'userId': 'user-1',
        'originalName': 'holding-tax.pdf',
        'mimeType': 'application/pdf',
        'size': 204800,
        'createdAt': '2026-10-01T08:00:00.000Z',
      };
      final model = VerificationDocumentModel.fromJson(json);
      expect(model.id, 'doc-1');
      expect(model.originalName, 'holding-tax.pdf');
      expect(model.size, 204800);
      expect(model.createdAt, isNotNull);
    });
  });

  group('OwnerRepositoryImpl Tests', () {
    test('getDashboardStats returns stats entity on success', () async {
      when(() => mockRemoteDataSource.getDashboardStats())
          .thenAnswer((_) async => tStatsModel);

      final result = await repository.getDashboardStats();
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('should not fail'), (stats) {
        expect(stats.total, 6);
        expect(stats.active, 4);
      });
    });

    test('getMyListings returns listings on success', () async {
      when(() => mockRemoteDataSource.getMyListings(status: any(named: 'status')))
          .thenAnswer((_) async => [tListingItemModel]);

      final result = await repository.getMyListings(status: 'active');
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('should not fail'), (list) {
        expect(list.length, 1);
        expect(list.first.id, 'listing-123');
      });
    });

    test('createListing returns created item on success', () async {
      const params = CreateListingParams(
        title: 'উত্তরা ফ্ল্যাট',
        description: 'বিবরণ',
        propertyType: 'apartment',
        areaSlug: 'uttara',
        address: 'রোড ১২',
        pricePerMonth: 25000,
      );

      when(() => mockRemoteDataSource.createListing(any()))
          .thenAnswer((_) async => tListingItemModel);

      final result = await repository.createListing(params);
      expect(result.isRight(), isTrue);
    });

    test('transitionListingStatus returns true on success', () async {
      when(() => mockRemoteDataSource.transitionListingStatus(
            id: 'listing-123',
            action: 'withdraw',
          )).thenAnswer((_) async => true);

      final result = await repository.transitionListingStatus(
        id: 'listing-123',
        action: 'withdraw',
      );
      expect(result, const Right(true));
    });
  });

  group('Owner BLoC Tests', () {
    late MockOwnerRepository mockRepo;

    setUp(() {
      mockRepo = MockOwnerRepository();
    });

    test('OwnerDashboardBloc fetches stats and listings on FetchOwnerDashboardData', () async {
      when(() => mockRepo.getDashboardStats())
          .thenAnswer((_) async => const Right(OwnerDashboardStats(total: 5, active: 3)));
      when(() => mockRepo.getMyListings(status: any(named: 'status')))
          .thenAnswer((_) async => Right([tListingItemModel.toEntity()]));

      final bloc = OwnerDashboardBloc(
        getDashboardStatsUseCase: GetOwnerDashboardStatsUseCase(mockRepo),
        getMyListingsUseCase: GetMyListingsUseCase(mockRepo),
        transitionListingStatusUseCase: TransitionListingStatusUseCase(mockRepo),
      );

      expect(bloc.state, isA<OwnerDashboardInitial>());

      bloc.add(const FetchOwnerDashboardData());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OwnerDashboardLoading>(),
          isA<OwnerDashboardLoaded>()
              .having((s) => s.stats.total, 'total stats', 5)
              .having((s) => s.listings.length, 'listings count', 1),
        ]),
      );
    });

    test('CreateListingBloc emits loading and success on SubmitCreateListingEvent', () async {
      when(() => mockRepo.createListing(any()))
          .thenAnswer((_) async => Right(tListingItemModel.toEntity()));

      final bloc = CreateListingBloc(
        createListingUseCase: CreateListingUseCase(mockRepo),
        updateListingUseCase: UpdateListingUseCase(mockRepo),
        uploadMediaUseCase: UploadMediaUseCase(mockRepo),
      );

      bloc.add(const SubmitCreateListingEvent(CreateListingParams(
        title: 'New Listing',
        description: 'Nice flat',
        propertyType: 'apartment',
        areaSlug: 'dhanmondi',
        address: 'Road 5',
        pricePerMonth: 30000,
      )));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CreateListingLoading>(),
          isA<CreateListingSuccess>()
              .having((s) => s.listing.id, 'id', 'listing-123'),
        ]),
      );
    });

    test('VerificationBloc emits loaded on FetchVerificationDocumentsEvent', () async {
      when(() => mockRepo.getDocuments())
          .thenAnswer((_) async => Right([tDocModel.toEntity()]));

      final bloc = VerificationBloc(
        getDocumentsUseCase: GetVerificationDocumentsUseCase(mockRepo),
        uploadDocumentUseCase: UploadVerificationDocumentUseCase(mockRepo),
      );

      bloc.add(const FetchVerificationDocumentsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<VerificationLoading>(),
          isA<VerificationLoaded>()
              .having((s) => s.documents.length, 'documents count', 1),
        ]),
      );
    });
  });

  group('Owner Pages Widget Tests', () {
    setUp(() async {
      await resetDependencies();
      SharedPreferences.setMockInitialValues({});
      await configureDependencies();

      final mockRepo = MockOwnerRepository();
      when(() => mockRepo.getDashboardStats())
          .thenAnswer((_) async => const Right(OwnerDashboardStats(total: 3, active: 2, views: 150)));
      when(() => mockRepo.getMyListings(status: any(named: 'status')))
          .thenAnswer((_) async => Right([tListingItemModel.toEntity()]));
      when(() => mockRepo.getDocuments())
          .thenAnswer((_) async => Right([tDocModel.toEntity()]));

      // Override repository with mock
      if (sl.isRegistered<OwnerRepository>()) {
        sl.unregister<OwnerRepository>();
      }
      sl.registerLazySingleton<OwnerRepository>(() => mockRepo);
    });

    tearDown(() async {
      await resetDependencies();
    });

    testWidgets('OwnerDashboardPage renders dashboard stats, verification banner, and listing item', (tester) async {
      await tester.pumpWidget(buildTestWidget(const OwnerDashboardPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ড্যাশবোর্ড'), findsWidgets);
      expect(find.text('উত্তরা সেক্টর ৭ ফ্ল্যাট'), findsOneWidget);
      expect(find.text('মোট বিজ্ঞাপন'), findsOneWidget);
      expect(find.text('বিজ্ঞাপন দিন'), findsWidgets);
    });

    testWidgets('CreateEditListingPage renders input fields and submit button', (tester) async {
      tester.view.physicalSize = const Size(800, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget(const CreateEditListingPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('নতুন বিজ্ঞাপন দিন'), findsOneWidget);
      expect(find.text('বিজ্ঞাপন পোস্ট করুন'), findsOneWidget);
      expect(find.text('ভাড়া'), findsOneWidget);
      expect(find.text('বিক্রি'), findsOneWidget);
    });
  });
}
