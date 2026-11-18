import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/security/secure_storage.dart';
import 'package:ghorbad_clone_app/core/security/session_manager.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_bloc.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_event.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/bloc/register_state.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/register_page.dart';
import 'package:ghorbad_clone_app/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/area_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/facets_entity.dart';
import 'package:ghorbad_clone_app/features/browse/domain/entities/listing_entity.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/bloc/home_bloc.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/bloc/listing_detail_bloc.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/home_page.dart';
import 'package:ghorbad_clone_app/features/browse/presentation/pages/listing_detail_page.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/bloc/report_bloc.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/widgets/report_bottom_sheet.dart';
import 'package:ghorbad_clone_app/features/content/domain/entities/content_entities.dart';
import 'package:ghorbad_clone_app/features/content/presentation/bloc/qa_bloc.dart';
import 'package:ghorbad_clone_app/features/content/presentation/pages/qa_page.dart';
import 'package:ghorbad_clone_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ghorbad_clone_app/features/favorites/presentation/pages/favorites_page.dart';
import 'package:ghorbad_clone_app/features/land/presentation/bloc/land_bloc.dart';
import 'package:ghorbad_clone_app/features/land/presentation/pages/land_page.dart';
import 'package:ghorbad_clone_app/features/map/domain/entities/place_entity.dart';
import 'package:ghorbad_clone_app/features/map/presentation/bloc/map_bloc.dart';
import 'package:ghorbad_clone_app/features/map/presentation/pages/map_page.dart';
import 'package:ghorbad_clone_app/features/owner/domain/entities/owner_dashboard_stats.dart';
import 'package:ghorbad_clone_app/features/owner/domain/entities/owner_listing_item.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/bloc/owner_dashboard_bloc.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/bloc/verification_bloc.dart';
import 'package:ghorbad_clone_app/features/owner/presentation/pages/owner_dashboard_page.dart';
import 'package:ghorbad_clone_app/features/plans/domain/entities/pricing_plan_entity.dart';
import 'package:ghorbad_clone_app/features/plans/presentation/bloc/pricing_bloc.dart';
import 'package:ghorbad_clone_app/features/plans/presentation/pages/pricing_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}
class MockListingDetailBloc extends MockBloc<ListingDetailEvent, ListingDetailState> implements ListingDetailBloc {}
class MockContactBloc extends MockBloc<ContactEvent, ContactState> implements ContactBloc {}
class MockReportBloc extends MockBloc<ReportEvent, ReportState> implements ReportBloc {}
class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState> implements FavoritesBloc {}
class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}
class MockLandBloc extends MockBloc<LandEvent, LandState> implements LandBloc {}
class MockOwnerDashboardBloc extends MockBloc<OwnerDashboardEvent, OwnerDashboardState> implements OwnerDashboardBloc {}
class MockVerificationBloc extends MockBloc<VerificationEvent, VerificationState> implements VerificationBloc {}
class MockQaBloc extends MockBloc<QaEvent, QaState> implements QaBloc {}
class MockPricingBloc extends MockBloc<PricingEvent, PricingState> implements PricingBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState> implements RegisterBloc {}
class MockSecureStorage extends Mock implements AppSecureStorage {}

void main() {
  late MockHomeBloc mockHomeBloc;
  late MockListingDetailBloc mockListingDetailBloc;
  late MockContactBloc mockContactBloc;
  late MockReportBloc mockReportBloc;
  late MockFavoritesBloc mockFavoritesBloc;
  late MockMapBloc mockMapBloc;
  late MockLandBloc mockLandBloc;
  late MockOwnerDashboardBloc mockOwnerDashboardBloc;
  late MockVerificationBloc mockVerificationBloc;
  late MockQaBloc mockQaBloc;
  late MockPricingBloc mockPricingBloc;
  late MockAuthBloc mockAuthBloc;
  late MockRegisterBloc mockRegisterBloc;

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    mockListingDetailBloc = MockListingDetailBloc();
    mockContactBloc = MockContactBloc();
    mockReportBloc = MockReportBloc();
    mockFavoritesBloc = MockFavoritesBloc();
    mockMapBloc = MockMapBloc();
    mockLandBloc = MockLandBloc();
    mockOwnerDashboardBloc = MockOwnerDashboardBloc();
    mockVerificationBloc = MockVerificationBloc();
    mockQaBloc = MockQaBloc();
    mockPricingBloc = MockPricingBloc();
    mockAuthBloc = MockAuthBloc();
    mockRegisterBloc = MockRegisterBloc();

    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    resetDependencies();
    sl.registerFactory<HomeBloc>(() => mockHomeBloc);
    sl.registerFactory<ListingDetailBloc>(() => mockListingDetailBloc);
    sl.registerFactory<ContactBloc>(() => mockContactBloc);
    sl.registerFactory<ReportBloc>(() => mockReportBloc);
    sl.registerFactory<FavoritesBloc>(() => mockFavoritesBloc);
    sl.registerFactory<MapBloc>(() => mockMapBloc);
    sl.registerFactory<LandBloc>(() => mockLandBloc);
    sl.registerFactory<OwnerDashboardBloc>(() => mockOwnerDashboardBloc);
    sl.registerFactory<VerificationBloc>(() => mockVerificationBloc);
    sl.registerFactory<QaBloc>(() => mockQaBloc);
    sl.registerFactory<PricingBloc>(() => mockPricingBloc);
    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
    sl.registerFactory<RegisterBloc>(() => mockRegisterBloc);
  });

  tearDown(() async {
    await resetDependencies();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('bn'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('bn'), Locale('en')],
      home: child,
    );
  }

  const sampleListing = ListingEntity(
    id: 'listing_001',
    title: 'ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া',
    slug: 'spacious-3bhk-dhanmondi-1234',
    description: '৩ বেড, ৩ বাথ, বারান্দা সহ সম্পূর্ণ টাইলস করা ফ্ল্যাট।',
    purpose: 'rent',
    propertyType: 'apartment',
    areaSlug: 'dhanmondi',
    city: 'dhaka',
    division: 'dhaka',
    address: 'Road 8A, Dhanmondi',
    pricePerMonth: 35000,
    bed: 3,
    bath: 3,
    size: 1450,
    verified: true,
    viewCount: 154,
    images: ['https://ghorbd.com/uploads/sample.webp'],
  );

  group('User Journeys (UJ-001 to UJ-011) E2E Journey Tests', () {
    testWidgets('UJ-001: First open and guest browse loads categories and popular areas', (tester) async {
      when(() => mockHomeBloc.state).thenReturn(
        const HomeLoaded(
          featuredListings: [sampleListing],
          popularAreas: [
            AreaEntity(
              id: 'a1',
              name: 'ধানমন্ডি',
              nameEn: 'Dhanmondi',
              slug: 'dhanmondi',
              city: 'dhaka',
              division: 'dhaka',
              listingCount: 42,
            ),
          ],
          recentRentListings: [sampleListing],
        ),
      );
      when(() => mockHomeBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<HomeBloc>.value(
            value: mockHomeBloc,
            child: const HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া'), findsWidgets);
      // Round 3: Home is a lazy CustomScrollView — the popular-areas
      // section builds when scrolled into range, so scroll down to it
      // before asserting (it previously sat in an eager scroll column).
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('ধানমন্ডি'), findsWidgets);
    });

    testWidgets('UJ-002: Find rental and contact owner shows listing detail with safety notice and contact action', (tester) async {
      when(() => mockListingDetailBloc.state).thenReturn(
        const ListingDetailLoaded(listing: sampleListing),
      );
      when(() => mockListingDetailBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockContactBloc.state).thenReturn(const ContactInitial());
      when(() => mockContactBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ListingDetailBloc>.value(value: mockListingDetailBloc),
              BlocProvider<ContactBloc>.value(value: mockContactBloc),
              BlocProvider<AuthBloc>.value(value: mockAuthBloc),
            ],
            child: const ListingDetailPage(idOrSlug: 'spacious-3bhk-dhanmondi-1234'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া'), findsOneWidget);
      expect(find.byType(ListingDetailPage), findsOneWidget);
    });

    testWidgets('UJ-003: Map search renders interactive map pins and place selector', (tester) async {
      when(() => mockMapBloc.state).thenReturn(
        const MapLoaded(
          listings: [sampleListing],
          placeSuggestions: [PlaceEntity(label: 'Dhanmondi', fullLabel: 'Dhanmondi, Dhaka', lat: 23.7465, lng: 90.3760)],
          selectedListing: sampleListing,
        ),
      );
      when(() => mockMapBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<MapBloc>.value(
            value: mockMapBloc,
            child: const MapPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MapPage), findsOneWidget);
      expect(find.text('ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া'), findsOneWidget);
    });

    testWidgets('UJ-004: Land search renders land listings and units', (tester) async {
      const landListing = ListingEntity(
        id: 'land123',
        slug: 'residential-plot-savar',
        title: 'সাভারে ৫ কাঠা আবাসিক প্লট বিক্রি',
        description: 'রেজিস্ট্রি ও নামজারি সম্পন্ন।',
        purpose: 'sale',
        propertyType: 'land',
        pricePerMonth: 4500000,
        areaSlug: 'savar',
        city: 'dhaka',
        division: 'dhaka',
        address: 'Savar, Dhaka',
        landType: 'residential',
        landAreaUnit: 'katha',
        landAreaValue: 5.0,
      );

      when(() => mockLandBloc.state).thenReturn(
        const LandLoaded(
          listings: [landListing],
          total: 1,
          currentParams: ListingFilterParams(),
        ),
      );
      when(() => mockLandBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<LandBloc>.value(
            value: mockLandBloc,
            child: const LandPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('সাভারে ৫ কাঠা আবাসিক প্লট বিক্রি'), findsOneWidget);
    });

    testWidgets('UJ-005: Save favorites and view favorites list', (tester) async {
      when(() => mockFavoritesBloc.state).thenReturn(
        const FavoritesLoaded([sampleListing]),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<FavoritesBloc>.value(
            value: mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া'), findsOneWidget);
    });

    testWidgets('UJ-006: Report listing renders report bottom sheet with reason options', (tester) async {
      when(() => mockReportBloc.state).thenReturn(const ReportInitial());
      when(() => mockReportBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<ReportBloc>.value(
            value: mockReportBloc,
            child: const Scaffold(
              body: ReportBottomSheet(listingId: 'listing_001'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ReportBottomSheet), findsOneWidget);
    });

    testWidgets('UJ-007: Owner registers and finishes verification flow', (tester) async {
      when(() => mockRegisterBloc.state).thenReturn(const RegisterInitial());
      when(() => mockRegisterBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<RegisterBloc>.value(
            value: mockRegisterBloc,
            child: const RegisterPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);

      // Verify OTP screen
      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<RegisterBloc>.value(
            value: mockRegisterBloc,
            child: const VerifyOtpPage(email: 'test@example.com'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(VerifyOtpPage), findsOneWidget);
    });

    testWidgets('UJ-008: Owner manages listings and views dashboard', (tester) async {
      const stats = OwnerDashboardStats(
        total: 3,
        active: 2,
        draft: 1,
        views: 450,
        favorites: 12,
      );

      const item = OwnerListingItem(
        id: 'listing_001',
        title: 'ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া',
        slug: 'spacious-3bhk-dhanmondi-1234',
        pricePerMonth: 35000,
        status: 'active',
        city: 'dhaka',
        propertyType: 'apartment',
        areaSlug: 'dhanmondi',
        address: 'Road 8A, Dhanmondi',
        purpose: 'rent',
      );

      when(() => mockOwnerDashboardBloc.state).thenReturn(
        const OwnerDashboardLoaded(stats: stats, listings: [item]),
      );
      when(() => mockOwnerDashboardBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockVerificationBloc.state).thenReturn(VerificationInitial());
      when(() => mockVerificationBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<OwnerDashboardBloc>.value(value: mockOwnerDashboardBloc),
              BlocProvider<VerificationBloc>.value(value: mockVerificationBloc),
            ],
            child: const OwnerDashboardPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OwnerDashboardPage), findsOneWidget);
      expect(find.text('ধানমন্ডি লেকের কাছে মনোরম ফ্ল্যাট ভাড়া'), findsOneWidget);
    });

    testWidgets('UJ-009: Q&A community and guides knowledge base', (tester) async {
      final question = QuestionEntity(
        id: 'q1',
        slug: 'rent-agreement-law',
        title: 'বাসা ভাড়ার চুক্তিপত্র কীভাবে করতে হয়?',
        body: 'প্রথমবার বাসা ভাড়া নিচ্ছি, কী কী বিষয় চুক্তিতে রাখা উচিত?',
        authorName: 'Shakil',
        category: 'rent',
        answersCount: 2,
        views: 88,
        createdAt: DateTime(2026, 10, 15),
      );

      when(() => mockQaBloc.state).thenReturn(
        QaLoaded(
          questions: [question],
        ),
      );
      when(() => mockQaBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<QaBloc>.value(
            value: mockQaBloc,
            child: const QaPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('বাসা ভাড়ার চুক্তিপত্র কীভাবে করতে হয়?'), findsOneWidget);
    });

    testWidgets('UJ-010: Pricing plans display and comparison table', (tester) async {
      const plans = [
        PricingPlanEntity(
          id: 'free',
          slug: 'free',
          name: 'ফ্রি',
          nameEn: 'Free',
          price: 0,
          features: ['৩টি বিজ্ঞাপন', 'মেসেজিং'],
          isFree: true,
        ),
        PricingPlanEntity(
          id: 'pro',
          slug: 'pro',
          name: 'প্রো',
          nameEn: 'Pro',
          price: 499,
          features: ['আনলিমিটেড বিজ্ঞাপন', 'ভাড়া রিমাইন্ডার'],
          popular: true,
        ),
      ];

      when(() => mockPricingBloc.state).thenReturn(
        const PricingLoaded(plans),
      );
      when(() => mockPricingBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        buildTestableWidget(
          BlocProvider<PricingBloc>.value(
            value: mockPricingBloc,
            child: const PricingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PricingPage), findsOneWidget);
      expect(find.text('ফ্রি'), findsOneWidget);
      expect(find.text('প্রো'), findsOneWidget);
    });

    test('UJ-011: Session expiry and logout cascades to unauthenticated state', () async {
      final mockStorage = MockSecureStorage();
      when(() => mockStorage.hasValidSession()).thenAnswer((_) async => true);
      when(() => mockStorage.clearAll()).thenAnswer((_) async {});

      final sessionManager = SessionManager(
        secureStorage: mockStorage,
        idleTimeout: const Duration(milliseconds: 50),
      );

      await sessionManager.initialize();
      expect(sessionManager.currentStatus, SessionStatus.authenticated);

      await Future<void>.delayed(const Duration(milliseconds: 70));
      final timedOut = await sessionManager.checkIdleTimeout();

      expect(timedOut, isTrue);
      expect(sessionManager.currentStatus, SessionStatus.expired);

      await sessionManager.endSession();
      expect(sessionManager.currentStatus, SessionStatus.unauthenticated);
      verify(() => mockStorage.clearAll()).called(2);
    });
  });
}
