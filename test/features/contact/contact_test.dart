import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ghorbad_clone_app/core/error/exceptions.dart';
import 'package:ghorbad_clone_app/features/contact/data/datasources/contact_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/contact/data/models/report_model.dart';
import 'package:ghorbad_clone_app/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:ghorbad_clone_app/features/contact/domain/entities/report_entity.dart';
import 'package:ghorbad_clone_app/features/contact/domain/repositories/contact_repository.dart';
import 'package:ghorbad_clone_app/features/contact/domain/usecases/contact_usecases.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/bloc/contact_bloc.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/bloc/report_bloc.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/widgets/inquiry_bottom_sheet.dart';
import 'package:ghorbad_clone_app/features/contact/presentation/widgets/report_bottom_sheet.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockContactRemoteDataSource extends Mock
    implements ContactRemoteDataSource {}

class MockContactRepository extends Mock implements ContactRepository {}

class MockGetContactPhoneUseCase extends Mock
    implements GetContactPhoneUseCase {}

class MockSendInquiryUseCase extends Mock implements SendInquiryUseCase {}

class MockReportListingUseCase extends Mock implements ReportListingUseCase {}

void main() {
  const sampleReportModel = ReportModel(
    id: 'rep-1',
    listingId: 'list-1',
    reason: 'scam',
    details: 'Fake photos',
    status: 'open',
  );

  const sampleReportEntity = ReportEntity(
    id: 'rep-1',
    listingId: 'list-1',
    reason: 'scam',
    details: 'Fake photos',
    status: 'open',
  );

  group('ContactRepositoryImpl', () {
    late MockContactRemoteDataSource mockDataSource;
    late ContactRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockContactRemoteDataSource();
      repository = ContactRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('getContactPhone returns phone string on success', () async {
      when(() => mockDataSource.getContactPhone('list-1'))
          .thenAnswer((_) async => '+8801711000000');

      final result = await repository.getContactPhone('list-1');

      expect(result, const Right('+8801711000000'));
    });

    test('getContactPhone returns Failure on exception', () async {
      when(() => mockDataSource.getContactPhone('list-1'))
          .thenThrow(const ServerException('Server error', 500));

      final result = await repository.getContactPhone('list-1');

      expect(result.isLeft(), isTrue);
    });

    test('sendInquiry returns true on success', () async {
      when(() => mockDataSource.sendInquiry('list-1', 'Hello'))
          .thenAnswer((_) async => true);

      final result = await repository.sendInquiry('list-1', 'Hello');

      expect(result, const Right(true));
    });

    test('reportListing returns ReportEntity on success', () async {
      when(() => mockDataSource.reportListing('list-1', 'scam', 'Fake photos'))
          .thenAnswer((_) async => sampleReportModel);

      final result = await repository.reportListing('list-1', 'scam', 'Fake photos');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('should succeed'),
        (report) => expect(report.id, 'rep-1'),
      );
    });
  });

  group('ContactBloc', () {
    late MockGetContactPhoneUseCase mockPhone;
    late MockSendInquiryUseCase mockInquiry;
    late ContactBloc bloc;

    setUp(() {
      mockPhone = MockGetContactPhoneUseCase();
      mockInquiry = MockSendInquiryUseCase();
      bloc = ContactBloc(
        getContactPhoneUseCase: mockPhone,
        sendInquiryUseCase: mockInquiry,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is ContactInitial', () {
      expect(bloc.state, const ContactInitial());
    });

    test('RevealContactPhone emits [Loading, PhoneRevealed] on success', () async {
      when(() => mockPhone('list-1'))
          .thenAnswer((_) async => const Right('+8801711000000'));

      final expectedStates = [
        const ContactLoading(),
        const PhoneRevealed('+8801711000000'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const RevealContactPhone('list-1'));
    });

    test('SendContactInquiry emits [Loading, InquirySentSuccess] on success', () async {
      when(() => mockInquiry('list-1', 'I am interested'))
          .thenAnswer((_) async => const Right(true));

      final expectedStates = [
        const ContactLoading(),
        const InquirySentSuccess(),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const SendContactInquiry(
        listingId: 'list-1',
        content: 'I am interested',
      ));
    });

    test('SendContactInquiry emits ContactError on empty content', () async {
      final expectedStates = [
        const ContactError('validation_error'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const SendContactInquiry(
        listingId: 'list-1',
        content: '   ',
      ));
    });
  });

  group('ReportBloc', () {
    late MockReportListingUseCase mockReportUseCase;
    late ReportBloc bloc;

    setUp(() {
      mockReportUseCase = MockReportListingUseCase();
      bloc = ReportBloc(reportListingUseCase: mockReportUseCase);
    });

    tearDown(() {
      bloc.close();
    });

    test('SubmitReportEvent emits [ReportSubmitting, ReportSuccessState] on success', () async {
      when(() => mockReportUseCase(
            listingId: 'list-1',
            reason: 'scam',
            details: 'Fake details',
          )).thenAnswer((_) async => const Right(sampleReportEntity));

      final expectedStates = [
        const ReportSubmitting(),
        const ReportSuccessState(sampleReportEntity),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const SubmitReportEvent(
        listingId: 'list-1',
        reason: 'scam',
        details: 'Fake details',
      ));
    });

    test('SubmitReportEvent emits validation error on empty reason', () async {
      final expectedStates = [
        const ReportErrorState('validation_error'),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(const SubmitReportEvent(
        listingId: 'list-1',
        reason: '',
      ));
    });
  });

  group('Contact and Report Widget Tests', () {
    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('bn'), Locale('en')],
        home: Scaffold(body: child),
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

    testWidgets('InquiryBottomSheet renders input field and sends message', (tester) async {
      final mockContactRepo = MockContactRepository();
      when(() => mockContactRepo.sendInquiry('list-1', 'Is this available?'))
          .thenAnswer((_) async => const Right(true));

      sl.unregister<ContactRepository>();
      sl.registerLazySingleton<ContactRepository>(() => mockContactRepo);
      sl.unregister<SendInquiryUseCase>();
      sl.registerLazySingleton<SendInquiryUseCase>(
        () => SendInquiryUseCase(mockContactRepo),
      );

      await tester.pumpWidget(
        buildTestWidget(const InquiryBottomSheet(listingId: 'list-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Is this available?');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockContactRepo.sendInquiry('list-1', 'Is this available?'))
          .called(1);
    });

    testWidgets('ReportBottomSheet renders reasons and submits report', (tester) async {
      final mockContactRepo = MockContactRepository();
      when(() => mockContactRepo.reportListing('list-1', 'scam', any()))
          .thenAnswer((_) async => const Right(sampleReportEntity));

      sl.unregister<ContactRepository>();
      sl.registerLazySingleton<ContactRepository>(() => mockContactRepo);
      sl.unregister<ReportListingUseCase>();
      sl.registerLazySingleton<ReportListingUseCase>(
        () => ReportListingUseCase(mockContactRepo),
      );

      await tester.pumpWidget(
        buildTestWidget(const ReportBottomSheet(listingId: 'list-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RadioListTile<String>), findsWidgets);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(() => mockContactRepo.reportListing('list-1', 'scam', any()))
          .called(1);
    });
  });
}
