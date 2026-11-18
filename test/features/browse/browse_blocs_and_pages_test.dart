import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/area_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/facets_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/listing_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/usecases/get_areas_usecase.dart';
import 'package:ghorbad_clone_app/features/browse/domain/usecases/get_listing_detail_usecase.dart';
import 'package:ghorbad_clone_app/features/browse/domain/usecases/get_listings_usecase.dart';
import 'package:ghorbad_clone_app/features/browse/domain/usecases/search_listings_usecase.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/bloc/home_bloc.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/bloc/listing_detail_bloc.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/bloc/listings_bloc.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/home_page.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/listing_detail_page.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/listings_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGetListingsUseCase extends Mock implements GetListingsUseCase {}

class MockGetListingDetailUseCase extends Mock
    implements GetListingDetailUseCase {}

class MockSearchListingsUseCase extends Mock implements SearchListingsUseCase {}

class MockGetAreasUseCase extends Mock implements GetAreasUseCase {}

void main() {
  late MockGetListingsUseCase mockGetListingsUseCase;
  late MockGetListingDetailUseCase mockGetListingDetailUseCase;
  late MockSearchListingsUseCase mockSearchListingsUseCase;
  late MockGetAreasUseCase mockGetAreasUseCase;

  const testListing = ListingEntity(
    id: 'listing_001',
    title: 'Modern Dhanmondi 3 Bed Apartment',
    slug: 'modern-dhanmondi-3-bed',
    description: 'Beautiful south facing flat in road 8A.',
    propertyType: 'apartment',
    purpose: 'rent',
    areaSlug: 'dhanmondi',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Road 8A, Dhanmondi',
    floor: 4,
    bed: 3,
    bath: 3,
    size: 1600,
    pricePerMonth: 38000,
    verified: true,
    featured: true,
    hasContactPhone: true,
    viewCount: 250,
  );

  const testArea = AreaEntity(
    id: 'area_001',
    slug: 'dhanmondi',
    name: 'ধানমন্ডি',
    nameEn: 'Dhanmondi',
    city: 'dhaka',
    division: 'dhaka',
    popular: true,
    listingCount: 35,
  );

  setUpAll(() {
    registerFallbackValue(const ListingFilterParams());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    mockGetListingsUseCase = MockGetListingsUseCase();
    mockGetListingDetailUseCase = MockGetListingDetailUseCase();
    mockSearchListingsUseCase = MockSearchListingsUseCase();
    mockGetAreasUseCase = MockGetAreasUseCase();

    // Reset and register DI for widgets
    if (sl.isRegistered<GetListingsUseCase>()) {
      sl.unregister<GetListingsUseCase>();
    }
    sl.registerLazySingleton<GetListingsUseCase>(() => mockGetListingsUseCase);

    if (sl.isRegistered<GetListingDetailUseCase>()) {
      sl.unregister<GetListingDetailUseCase>();
    }
    sl.registerLazySingleton<GetListingDetailUseCase>(
      () => mockGetListingDetailUseCase,
    );

    if (sl.isRegistered<SearchListingsUseCase>()) {
      sl.unregister<SearchListingsUseCase>();
    }
    sl.registerLazySingleton<SearchListingsUseCase>(
      () => mockSearchListingsUseCase,
    );

    if (sl.isRegistered<GetAreasUseCase>()) {
      sl.unregister<GetAreasUseCase>();
    }
    sl.registerLazySingleton<GetAreasUseCase>(() => mockGetAreasUseCase);

    if (sl.isRegistered<HomeBloc>()) sl.unregister<HomeBloc>();
    sl.registerFactory<HomeBloc>(
      () => HomeBloc(
        getListingsUseCase: mockGetListingsUseCase,
        getAreasUseCase: mockGetAreasUseCase,
      ),
    );

    if (sl.isRegistered<ListingsBloc>()) sl.unregister<ListingsBloc>();
    sl.registerFactoryParam<ListingsBloc, ListingFilterParams?, void>(
      (params, _) => ListingsBloc(
        searchListingsUseCase: mockSearchListingsUseCase,
        initialParams: params ?? const ListingFilterParams(),
      ),
    );

    if (sl.isRegistered<ListingDetailBloc>()) {
      sl.unregister<ListingDetailBloc>();
    }
    sl.registerFactory<ListingDetailBloc>(
      () => ListingDetailBloc(
        getListingDetailUseCase: mockGetListingDetailUseCase,
      ),
    );
  });

  tearDown(() {
    resetDependencies();
  });

  Widget buildTestableWidget(Widget child) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => child,
        ),
        GoRoute(
          path: '/listings',
          builder: (context, state) =>
              const Scaffold(body: Text('Listings Screen')),
        ),
        GoRoute(
          path: '/listings/:slug',
          builder: (context, state) =>
              const Scaffold(body: Text('Detail Screen')),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const Scaffold(body: Text('Map Screen')),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) =>
              const Scaffold(body: Text('Favorites Screen')),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) =>
              const Scaffold(body: Text('Dashboard Screen')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );

    return MaterialApp.router(
      locale: const Locale('bn'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('bn'),
        Locale('en'),
      ],
      routerConfig: router,
    );
  }

  group('HomeBloc', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] on successful fetch',
      build: () {
        when(() => mockGetListingsUseCase(any())).thenAnswer(
          (_) async => const Right((
            listings: [testListing],
            total: 1,
            totalPages: 1,
            facets: null,
          )),
        );
        when(() => mockGetAreasUseCase(popular: true)).thenAnswer(
          (_) async => const Right([testArea]),
        );
        return HomeBloc(
          getListingsUseCase: mockGetListingsUseCase,
          getAreasUseCase: mockGetAreasUseCase,
        );
      },
      act: (bloc) => bloc.add(const HomeFetchData()),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeLoaded>(),
      ],
    );
  });

  group('ListingsBloc', () {
    blocTest<ListingsBloc, ListingsState>(
      'emits [ListingsLoading, ListingsLoaded] when search returns results',
      build: () {
        when(() => mockSearchListingsUseCase(any())).thenAnswer(
          (_) async => const Right((
            listings: [testListing],
            total: 1,
            totalPages: 1,
            facets: ListingFacetsEntity(),
          )),
        );
        return ListingsBloc(
          searchListingsUseCase: mockSearchListingsUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const ListingsFilterChanged(ListingFilterParams()),
      ),
      expect: () => [
        isA<ListingsLoading>(),
        isA<ListingsLoaded>(),
      ],
    );

    blocTest<ListingsBloc, ListingsState>(
      'emits [ListingsLoading, ListingsEmpty] when search returns 0 results',
      build: () {
        when(() => mockSearchListingsUseCase(any())).thenAnswer(
          (_) async => const Right((
            listings: <ListingEntity>[],
            total: 0,
            totalPages: 0,
            facets: ListingFacetsEntity(),
          )),
        );
        return ListingsBloc(
          searchListingsUseCase: mockSearchListingsUseCase,
        );
      },
      act: (bloc) => bloc.add(
        const ListingsFilterChanged(ListingFilterParams()),
      ),
      expect: () => [
        isA<ListingsLoading>(),
        isA<ListingsEmpty>(),
      ],
    );
  });

  group('ListingDetailBloc', () {
    blocTest<ListingDetailBloc, ListingDetailState>(
      'emits [ListingDetailLoading, ListingDetailLoaded] on success',
      build: () {
        when(() => mockGetListingDetailUseCase('listing_001')).thenAnswer(
          (_) async => const Right((
            listing: testListing,
            similar: <ListingEntity>[],
          )),
        );
        return ListingDetailBloc(
          getListingDetailUseCase: mockGetListingDetailUseCase,
        );
      },
      act: (bloc) => bloc.add(const ListingDetailFetch('listing_001')),
      expect: () => [
        isA<ListingDetailLoading>(),
        isA<ListingDetailLoaded>(),
      ],
    );
  });

  group('HomePage Widget Tests', () {
    testWidgets('renders hero section and category row on loaded state',
        (tester) async {
      when(() => mockGetListingsUseCase(any())).thenAnswer(
        (_) async => const Right((
          listings: [testListing],
          total: 1,
          totalPages: 1,
          facets: null,
        )),
      );
      when(() => mockGetAreasUseCase(popular: true)).thenAnswer(
        (_) async => const Right([testArea]),
      );

      await tester.pumpWidget(buildTestableWidget(const HomePage()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_bar_input')), findsOneWidget);
      expect(find.text('Modern Dhanmondi 3 Bed Apartment'), findsWidgets);
    });

    testWidgets('shows the full website category set including hotel',
        (tester) async {
      when(() => mockGetListingsUseCase(any())).thenAnswer(
        (_) async => const Right((
          listings: [testListing],
          total: 1,
          totalPages: 1,
          facets: null,
        )),
      );
      when(() => mockGetAreasUseCase(popular: true)).thenAnswer(
        (_) async => const Right([testArea]),
      );

      await tester.pumpWidget(buildTestableWidget(const HomePage()));
      await tester.pumpAndSettle();

      // Round 3: 'hotel' is a real backend type and appears in the
      // category grid (bn labels in this harness).
      expect(find.text('হোটেল'), findsOneWidget);
      expect(find.text('অ্যাপার্টমেন্ট'), findsOneWidget);
      // Guests get the login affordance in the header, not a fake photo.
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    });
  });

  group('ListingsPage Widget Tests', () {
    testWidgets('renders listings and filter button', (tester) async {
      when(() => mockSearchListingsUseCase(any())).thenAnswer(
        (_) async => const Right((
          listings: [testListing],
          total: 1,
          totalPages: 1,
          facets: ListingFacetsEntity(),
        )),
      );

      await tester.pumpWidget(buildTestableWidget(const ListingsPage()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('search_bar_filter_button')), findsOneWidget);
      expect(find.text('Modern Dhanmondi 3 Bed Apartment'), findsOneWidget);
    });
  });

  group('ListingDetailPage Widget Tests', () {
    testWidgets('renders listing title, price, and safety notice',
        (tester) async {
      when(() => mockGetListingDetailUseCase('modern-dhanmondi-3-bed'))
          .thenAnswer(
        (_) async => const Right((
          listing: testListing,
          similar: <ListingEntity>[],
        )),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const ListingDetailPage(idOrSlug: 'modern-dhanmondi-3-bed'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Modern Dhanmondi 3 Bed Apartment'), findsOneWidget);
      expect(find.textContaining('অগ্রিম টাকা পাঠানোর আগে বাসাটি সরেজমিনে'), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
    });
  });
}
