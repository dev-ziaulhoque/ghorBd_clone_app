import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/core/error/failures.dart';
import 'package:ghorbad_clone_app/features/plans/data/datasources/pricing_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/plans/data/models/pricing_plan_model.dart';
import 'package:ghorbad_clone_app/features/plans/data/repositories/pricing_repository_impl.dart';
import 'package:ghorbad_clone_app/features/plans/domain/repositories/pricing_repository.dart';
import 'package:ghorbad_clone_app/features/plans/domain/usecases/get_pricing_plans_usecase.dart';
import 'package:ghorbad_clone_app/features/plans/presentation/bloc/pricing_bloc.dart';
import 'package:ghorbad_clone_app/features/plans/presentation/pages/pricing_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockPricingRemoteDataSource extends Mock implements PricingRemoteDataSource {}
class MockPricingRepository extends Mock implements PricingRepository {}

void main() {
  late MockPricingRemoteDataSource mockRemoteDataSource;
  late PricingRepositoryImpl repository;

  const tFreePlanModel = PricingPlanModel(
    id: 'plan-free',
    slug: 'free',
    name: 'ফ্রি',
    nameEn: 'Free',
    description: 'Post a listing at no cost.',
    price: 0,
    priceMinor: 0,
    interval: 'one_time',
    features: ['1 listing', 'Admin review'],
    popular: false,
    isFree: true,
  );

  const tProPlanModel = PricingPlanModel(
    id: 'plan-pro',
    slug: 'pro',
    name: 'প্রো',
    nameEn: 'Pro',
    description: 'For active property owners.',
    price: 499,
    priceMinor: 49900,
    interval: 'monthly',
    features: [
      'Unlimited listings',
      'Priority badge',
      'Analytics dashboard',
    ],
    popular: true,
    isFree: false,
  );

  const tBusinessPlanModel = PricingPlanModel(
    id: 'plan-biz',
    slug: 'business',
    name: 'বিজনেস',
    nameEn: 'Business',
    description: 'For agencies and large landlords.',
    price: 1499,
    priceMinor: 149900,
    interval: 'monthly',
    features: [
      'Multi-unit management',
      'Dedicated account manager',
      'API access',
    ],
    popular: false,
    isFree: false,
  );

  final tPlansList = [tFreePlanModel, tProPlanModel, tBusinessPlanModel];

  setUp(() {
    mockRemoteDataSource = MockPricingRemoteDataSource();
    repository = PricingRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('PricingPlanModel & Repository', () {
    test('fromJson parses API-061 response correctly', () {
      final json = {
        'id': '66d0112233445566778899cc',
        'slug': 'free',
        'name': 'ফ্রি',
        'nameEn': 'Free',
        'description': 'Post a listing at no cost.',
        'priceMinor': 0,
        'price': 0,
        'currency': 'BDT',
        'interval': 'one_time',
        'features': ['1 listing', 'Admin review'],
        'popular': false,
        'ctaLabel': null,
        'published': true,
        'order': 0,
        'isFree': true,
      };

      final model = PricingPlanModel.fromJson(json);
      expect(model.id, '66d0112233445566778899cc');
      expect(model.name, 'ফ্রি');
      expect(model.price, 0);
      expect(model.isFree, true);
      expect(model.features.length, 2);
    });

    test('getPricingPlans returns list of PricingPlanEntity on success', () async {
      when(() => mockRemoteDataSource.getPricingPlans())
          .thenAnswer((_) async => tPlansList);

      final result = await repository.getPricingPlans();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (plans) {
          expect(plans.length, 3);
          expect(plans[0].slug, 'free');
          expect(plans[1].slug, 'pro');
          expect(plans[2].slug, 'business');
        },
      );
    });

    test('getPricingPlans returns ServerFailure on error', () async {
      when(() => mockRemoteDataSource.getPricingPlans())
          .thenThrow(Exception('Network error'));

      final result = await repository.getPricingPlans();

      expect(result.isLeft(), true);
    });
  });

  group('PricingBloc', () {
    late MockPricingRepository mockRepo;
    late GetPricingPlansUseCase useCase;
    late PricingBloc bloc;

    setUp(() {
      mockRepo = MockPricingRepository();
      useCase = GetPricingPlansUseCase(mockRepo);
      bloc = PricingBloc(getPricingPlansUseCase: useCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('FetchPricingPlansEvent emits [PricingLoading, PricingLoaded] on success', () async {
      when(() => mockRepo.getPricingPlans())
          .thenAnswer((_) async => Right(tPlansList.map((m) => m.toEntity()).toList()));

      bloc.add(const FetchPricingPlansEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PricingLoading>(),
          isA<PricingLoaded>().having((s) => s.plans.length, 'plans length', 3),
        ]),
      );
    });

    test('FetchPricingPlansEvent emits [PricingLoading, PricingError] on failure', () async {
      when(() => mockRepo.getPricingPlans())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      bloc.add(const FetchPricingPlansEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PricingLoading>(),
          isA<PricingError>().having((s) => s.message, 'error message', 'Server error'),
        ]),
      );
    });
  });

  group('PricingPage Widget Tests', () {
    late MockPricingRepository mockRepo;

    setUp(() {
      mockRepo = MockPricingRepository();

      if (sl.isRegistered<PricingRepository>()) {
        sl.unregister<PricingRepository>();
      }
      sl.registerSingleton<PricingRepository>(mockRepo);

      if (sl.isRegistered<GetPricingPlansUseCase>()) {
        sl.unregister<GetPricingPlansUseCase>();
      }
      sl.registerSingleton<GetPricingPlansUseCase>(GetPricingPlansUseCase(mockRepo));

      if (sl.isRegistered<PricingBloc>()) {
        sl.unregister<PricingBloc>();
      }
      sl.registerFactory<PricingBloc>(
        () => PricingBloc(getPricingPlansUseCase: sl<GetPricingPlansUseCase>()),
      );
    });

    testWidgets('renders all pricing tiers (Free, Pro, Business) and VAT notice', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 2400);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      when(() => mockRepo.getPricingPlans())
          .thenAnswer((_) async => Right(tPlansList.map((m) => m.toEntity()).toList()));

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('bn'),
          home: PricingPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header and VAT notice
      expect(find.text('সাবস্ক্রিপশন প্ল্যান'), findsOneWidget);
      expect(find.text('ℹ সকল দাম ভ্যাট ছাড়া'), findsOneWidget);

      // Verify Plan names
      expect(find.text('ফ্রি'), findsOneWidget);
      expect(find.text('প্রো'), findsOneWidget);
      expect(find.text('বিজনেস'), findsOneWidget);

      // Verify popular badge on Pro
      expect(find.text('জনপ্রিয়'), findsOneWidget);

      // Verify features
      expect(find.text('1 listing'), findsOneWidget);
      expect(find.text('Unlimited listings'), findsOneWidget);
      expect(find.text('Multi-unit management'), findsOneWidget);
    });
  });
}
