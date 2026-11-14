import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ghorbad_clone_app/app/di/injection.dart';
import 'package:ghorbad_clone_app/features/content/data/datasources/content_remote_data_source.dart';
import 'package:ghorbad_clone_app/features/content/data/models/content_models.dart';
import 'package:ghorbad_clone_app/features/content/data/repositories/content_repository_impl.dart';
import 'package:ghorbad_clone_app/features/content/domain/repositories/content_repository.dart';
import 'package:ghorbad_clone_app/features/content/domain/usecases/content_usecases.dart';
import 'package:ghorbad_clone_app/features/content/presentation/bloc/blog_bloc.dart';
import 'package:ghorbad_clone_app/features/content/presentation/bloc/qa_bloc.dart';
import 'package:ghorbad_clone_app/features/content/presentation/bloc/static_content_bloc.dart';
import 'package:ghorbad_clone_app/features/content/presentation/pages/blog_page.dart';
import 'package:ghorbad_clone_app/features/content/presentation/pages/qa_page.dart';
import 'package:ghorbad_clone_app/features/content/presentation/pages/static_content_page.dart';
import 'package:ghorbad_clone_app/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class MockContentRemoteDataSource extends Mock implements ContentRemoteDataSource {}
class MockContentRepository extends Mock implements ContentRepository {}

void main() {
  late MockContentRemoteDataSource mockRemoteDataSource;
  late ContentRepositoryImpl repository;

  const tGuideModel = GuideModel(
    id: 'g-1',
    slug: 'rent-agreement-guide',
    title: 'ভাড়া চুক্তি নির্দেশিকা',
    titleEn: 'Rent Agreement Guide',
    excerpt: 'বাড়ি ভাড়ার চুক্তির গুরুত্বপূর্ণ নিয়মাবলী।',
    body: 'চুক্তি করার আগে প্রয়োজনীয় কাগজপত্র যাচাই করুন।',
  );

  const tStaticPageModel = StaticPageModel(
    id: 'sp-1',
    slug: 'about',
    title: 'আমাদের সম্পর্কে',
    titleEn: 'About Us',
    body: 'ঘরবিডি একটি বিশ্বস্ত রিয়েল এস্টেট প্ল্যাটফর্ম।',
  );

  final tBlogPostModel = BlogPostModel(
    id: 'bp-1',
    slug: 'dhaka-rent-tips',
    title: 'ঢাকায় বাড়ি খোঁজার সেরা ৫টি টিপস',
    excerpt: 'বাজেট এবং লোকেশন ঠিক রাখার সহজ উপায়।',
    body: 'প্রথমেই আপনার অফিস বা স্কুল এর কাছাকাছি এলাকা বেছে নিন।',
    categories: ['tips', 'rent'],
    readingMinutes: 4,
    publishedAt: DateTime(2025, 1, 15),
  );

  final tBlogCommentModel = BlogCommentModel(
    id: 'c-1',
    postId: 'bp-1',
    body: 'খুবই তথ্যবহুল পোস্ট!',
    authorName: 'রহিম চৌধুরী',
    createdAt: DateTime(2025, 1, 16),
  );

  final tQuestionModel = QuestionModel(
    id: 'q-1',
    slug: 'advance-rent-law',
    title: 'অগ্রিম ভাড়ার আইনগত নিয়ম কী?',
    body: 'বাড়িওয়ালা কত মাসের অগ্রিম ভাড়া দাবি করতে পারেন?',
    category: 'rent',
    tags: ['rent', 'legal'],
    views: 120,
    answersCount: 2,
    authorName: 'তানভীর',
    createdAt: DateTime(2025, 2, 1),
  );

  final tAnswerModel = AnswerModel(
    id: 'ans-1',
    questionId: 'q-1',
    body: 'আইন অনুযায়ী সর্বোচ্চ এক মাসের অগ্রিম ভাড়া নেওয়ার বিধান রয়েছে।',
    authorName: 'অ্যাডভোকেট কামাল',
    createdAt: DateTime(2025, 2, 2),
  );

  setUp(() {
    mockRemoteDataSource = MockContentRemoteDataSource();
    repository = ContentRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('ContentRepositoryImpl', () {
    test('getGuides returns list of GuideEntity on success', () async {
      when(() => mockRemoteDataSource.getGuides(page: 1, perPage: 12))
          .thenAnswer((_) async => [tGuideModel]);

      final result = await repository.getGuides();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (guides) {
          expect(guides.length, 1);
          expect(guides.first.title, 'ভাড়া চুক্তি নির্দেশিকা');
        },
      );
    });

    test('getBlogPosts returns list of BlogPostEntity on success', () async {
      when(() => mockRemoteDataSource.getBlogPosts(
            category: any(named: 'category'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => [tBlogPostModel]);

      final result = await repository.getBlogPosts();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (posts) {
          expect(posts.length, 1);
          expect(posts.first.slug, 'dhaka-rent-tips');
        },
      );
    });

    test('getQuestions returns list of QuestionEntity on success', () async {
      when(() => mockRemoteDataSource.getQuestions(
            category: any(named: 'category'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => [tQuestionModel]);

      final result = await repository.getQuestions();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (questions) {
          expect(questions.length, 1);
          expect(questions.first.title, 'অগ্রিম ভাড়ার আইনগত নিয়ম কী?');
        },
      );
    });

    test('getStaticPage returns StaticPageEntity on success', () async {
      when(() => mockRemoteDataSource.getStaticPage('about'))
          .thenAnswer((_) async => tStaticPageModel);

      final result = await repository.getStaticPage('about');

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Expected Right'),
        (page) {
          expect(page.title, 'আমাদের সম্পর্কে');
        },
      );
    });
  });

  group('BlogBloc', () {
    late MockContentRepository mockRepo;
    late GetBlogPostsUseCase getBlogPostsUseCase;
    late GetBlogPostDetailUseCase getBlogPostDetailUseCase;
    late GetPostCommentsUseCase getPostCommentsUseCase;
    late AddPostCommentUseCase addPostCommentUseCase;
    late BlogBloc blogBloc;

    setUp(() {
      mockRepo = MockContentRepository();
      getBlogPostsUseCase = GetBlogPostsUseCase(mockRepo);
      getBlogPostDetailUseCase = GetBlogPostDetailUseCase(mockRepo);
      getPostCommentsUseCase = GetPostCommentsUseCase(mockRepo);
      addPostCommentUseCase = AddPostCommentUseCase(mockRepo);

      blogBloc = BlogBloc(
        getBlogPostsUseCase: getBlogPostsUseCase,
        getBlogPostDetailUseCase: getBlogPostDetailUseCase,
        getPostCommentsUseCase: getPostCommentsUseCase,
        addPostCommentUseCase: addPostCommentUseCase,
      );
    });

    tearDown(() {
      blogBloc.close();
    });

    test('FetchBlogPostsEvent emits [BlogLoading, BlogLoaded]', () async {
      when(() => mockRepo.getBlogPosts(
            category: any(named: 'category'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Right([tBlogPostModel.toEntity()]));

      blogBloc.add(const FetchBlogPostsEvent());

      await expectLater(
        blogBloc.stream,
        emitsInOrder([
          isA<BlogLoading>(),
          isA<BlogLoaded>().having((s) => s.posts.length, 'posts count', 1),
        ]),
      );
    });

    test('FetchBlogPostDetailEvent emits [BlogLoading, BlogLoaded with selectedPost and comments]', () async {
      when(() => mockRepo.getBlogPostDetail('dhaka-rent-tips'))
          .thenAnswer((_) async => Right(tBlogPostModel.toEntity()));
      when(() => mockRepo.getPostComments('bp-1'))
          .thenAnswer((_) async => Right([tBlogCommentModel.toEntity()]));

      blogBloc.add(const FetchBlogPostDetailEvent('dhaka-rent-tips'));

      await expectLater(
        blogBloc.stream,
        emitsInOrder([
          isA<BlogLoading>(),
          isA<BlogLoaded>()
              .having((s) => s.selectedPost?.title, 'title', 'ঢাকায় বাড়ি খোঁজার সেরা ৫টি টিপস')
              .having((s) => s.comments.length, 'comments length', 1),
        ]),
      );
    });
  });

  group('QaBloc', () {
    late MockContentRepository mockRepo;
    late GetQuestionsUseCase getQuestionsUseCase;
    late GetQuestionDetailUseCase getQuestionDetailUseCase;
    late AskQuestionUseCase askQuestionUseCase;
    late GetAnswersUseCase getAnswersUseCase;
    late PostAnswerUseCase postAnswerUseCase;
    late GetMyQuestionsUseCase getMyQuestionsUseCase;
    late QaBloc qaBloc;

    setUp(() {
      mockRepo = MockContentRepository();
      getQuestionsUseCase = GetQuestionsUseCase(mockRepo);
      getQuestionDetailUseCase = GetQuestionDetailUseCase(mockRepo);
      askQuestionUseCase = AskQuestionUseCase(mockRepo);
      getAnswersUseCase = GetAnswersUseCase(mockRepo);
      postAnswerUseCase = PostAnswerUseCase(mockRepo);
      getMyQuestionsUseCase = GetMyQuestionsUseCase(mockRepo);

      qaBloc = QaBloc(
        getQuestionsUseCase: getQuestionsUseCase,
        getQuestionDetailUseCase: getQuestionDetailUseCase,
        askQuestionUseCase: askQuestionUseCase,
        getAnswersUseCase: getAnswersUseCase,
        postAnswerUseCase: postAnswerUseCase,
        getMyQuestionsUseCase: getMyQuestionsUseCase,
      );
    });

    tearDown(() {
      qaBloc.close();
    });

    test('FetchQuestionsEvent emits [QaLoading, QaLoaded]', () async {
      when(() => mockRepo.getQuestions(
            category: any(named: 'category'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => Right([tQuestionModel.toEntity()]));

      qaBloc.add(const FetchQuestionsEvent());

      await expectLater(
        qaBloc.stream,
        emitsInOrder([
          isA<QaLoading>(),
          isA<QaLoaded>().having((s) => s.questions.length, 'questions length', 1),
        ]),
      );
    });

    test('AskQuestionEvent emits [QaLoaded with isSubmitting=true, then QaLoaded with actionSuccessMessage]', () async {
      when(() => mockRepo.askQuestion(
            title: any(named: 'title'),
            body: any(named: 'body'),
            category: any(named: 'category'),
            tags: any(named: 'tags'),
          )).thenAnswer((_) async => Right(tQuestionModel.toEntity()));

      qaBloc.add(const AskQuestionEvent(
        title: 'নতুন প্রশ্ন',
        body: 'প্রশ্নের বিস্তারিত বিবরণ',
        category: 'rent',
      ));

      await expectLater(
        qaBloc.stream,
        emitsInOrder([
          isA<QaLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<QaLoaded>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.actionSuccessMessage, 'actionSuccessMessage', isNotNull),
        ]),
      );
    });

    test('PostAnswerEvent submits answer when question is loaded', () async {
      when(() => mockRepo.getQuestionDetail('q-1'))
          .thenAnswer((_) async => Right(tQuestionModel.toEntity()));
      when(() => mockRepo.getAnswers('q-1'))
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepo.postAnswer(
            questionId: 'q-1',
            body: 'আইন অনুযায়ী সর্বোচ্চ এক মাসের অগ্রিম ভাড়া নেওয়ার বিধান রয়েছে।',
          )).thenAnswer((_) async => Right(tAnswerModel.toEntity()));

      qaBloc.add(const FetchQuestionDetailEvent('q-1'));
      await pumpEventQueue();

      qaBloc.add(const PostAnswerEvent(
        questionId: 'q-1',
        body: 'আইন অনুযায়ী সর্বোচ্চ এক মাসের অগ্রিম ভাড়া নেওয়ার বিধান রয়েছে।',
      ));

      await expectLater(
        qaBloc.stream,
        emitsInOrder([
          isA<QaLoaded>().having((s) => s.isSubmitting, 'isSubmitting', true),
          isA<QaLoaded>()
              .having((s) => s.isSubmitting, 'isSubmitting', false)
              .having((s) => s.answers.length, 'answers length', 1),
        ]),
      );
    });
  });

  group('StaticContentBloc', () {
    late MockContentRepository mockRepo;
    late GetGuidesUseCase getGuidesUseCase;
    late GetGuideDetailUseCase getGuideDetailUseCase;
    late GetStaticPageUseCase getStaticPageUseCase;
    late StaticContentBloc staticBloc;

    setUp(() {
      mockRepo = MockContentRepository();
      getGuidesUseCase = GetGuidesUseCase(mockRepo);
      getGuideDetailUseCase = GetGuideDetailUseCase(mockRepo);
      getStaticPageUseCase = GetStaticPageUseCase(mockRepo);

      staticBloc = StaticContentBloc(
        getGuidesUseCase: getGuidesUseCase,
        getGuideDetailUseCase: getGuideDetailUseCase,
        getStaticPageUseCase: getStaticPageUseCase,
      );
    });

    tearDown(() {
      staticBloc.close();
    });

    test('FetchGuidesEvent emits [StaticContentLoading, GuidesLoaded]', () async {
      when(() => mockRepo.getGuides())
          .thenAnswer((_) async => Right([tGuideModel.toEntity()]));

      staticBloc.add(const FetchGuidesEvent());

      await expectLater(
        staticBloc.stream,
        emitsInOrder([
          isA<StaticContentLoading>(),
          isA<GuidesLoaded>().having((s) => s.guides.length, 'guides length', 1),
        ]),
      );
    });

    test('FetchStaticPageEvent emits [StaticContentLoading, StaticPageLoaded]', () async {
      when(() => mockRepo.getStaticPage('about'))
          .thenAnswer((_) async => Right(tStaticPageModel.toEntity()));

      staticBloc.add(const FetchStaticPageEvent('about'));

      await expectLater(
        staticBloc.stream,
        emitsInOrder([
          isA<StaticContentLoading>(),
          isA<StaticPageLoaded>().having((s) => s.page.title, 'page title', 'আমাদের সম্পর্কে'),
        ]),
      );
    });
  });

  group('Content Widget Tests', () {
    late MockContentRepository mockRepo;

    setUp(() {
      mockRepo = MockContentRepository();

      if (sl.isRegistered<ContentRepository>()) {
        sl.unregister<ContentRepository>();
      }
      sl.registerSingleton<ContentRepository>(mockRepo);

      if (sl.isRegistered<GetBlogPostsUseCase>()) {
        sl.unregister<GetBlogPostsUseCase>();
      }
      sl.registerSingleton<GetBlogPostsUseCase>(GetBlogPostsUseCase(mockRepo));

      if (sl.isRegistered<GetBlogPostDetailUseCase>()) {
        sl.unregister<GetBlogPostDetailUseCase>();
      }
      sl.registerSingleton<GetBlogPostDetailUseCase>(GetBlogPostDetailUseCase(mockRepo));

      if (sl.isRegistered<GetPostCommentsUseCase>()) {
        sl.unregister<GetPostCommentsUseCase>();
      }
      sl.registerSingleton<GetPostCommentsUseCase>(GetPostCommentsUseCase(mockRepo));

      if (sl.isRegistered<AddPostCommentUseCase>()) {
        sl.unregister<AddPostCommentUseCase>();
      }
      sl.registerSingleton<AddPostCommentUseCase>(AddPostCommentUseCase(mockRepo));

      if (sl.isRegistered<GetQuestionsUseCase>()) {
        sl.unregister<GetQuestionsUseCase>();
      }
      sl.registerSingleton<GetQuestionsUseCase>(GetQuestionsUseCase(mockRepo));

      if (sl.isRegistered<GetQuestionDetailUseCase>()) {
        sl.unregister<GetQuestionDetailUseCase>();
      }
      sl.registerSingleton<GetQuestionDetailUseCase>(GetQuestionDetailUseCase(mockRepo));

      if (sl.isRegistered<AskQuestionUseCase>()) {
        sl.unregister<AskQuestionUseCase>();
      }
      sl.registerSingleton<AskQuestionUseCase>(AskQuestionUseCase(mockRepo));

      if (sl.isRegistered<GetAnswersUseCase>()) {
        sl.unregister<GetAnswersUseCase>();
      }
      sl.registerSingleton<GetAnswersUseCase>(GetAnswersUseCase(mockRepo));

      if (sl.isRegistered<PostAnswerUseCase>()) {
        sl.unregister<PostAnswerUseCase>();
      }
      sl.registerSingleton<PostAnswerUseCase>(PostAnswerUseCase(mockRepo));

      if (sl.isRegistered<GetMyQuestionsUseCase>()) {
        sl.unregister<GetMyQuestionsUseCase>();
      }
      sl.registerSingleton<GetMyQuestionsUseCase>(GetMyQuestionsUseCase(mockRepo));

      if (sl.isRegistered<GetGuidesUseCase>()) {
        sl.unregister<GetGuidesUseCase>();
      }
      sl.registerSingleton<GetGuidesUseCase>(GetGuidesUseCase(mockRepo));

      if (sl.isRegistered<GetGuideDetailUseCase>()) {
        sl.unregister<GetGuideDetailUseCase>();
      }
      sl.registerSingleton<GetGuideDetailUseCase>(GetGuideDetailUseCase(mockRepo));

      if (sl.isRegistered<GetStaticPageUseCase>()) {
        sl.unregister<GetStaticPageUseCase>();
      }
      sl.registerSingleton<GetStaticPageUseCase>(GetStaticPageUseCase(mockRepo));

      if (sl.isRegistered<BlogBloc>()) {
        sl.unregister<BlogBloc>();
      }
      sl.registerFactory<BlogBloc>(() => BlogBloc(
            getBlogPostsUseCase: sl<GetBlogPostsUseCase>(),
            getBlogPostDetailUseCase: sl<GetBlogPostDetailUseCase>(),
            getPostCommentsUseCase: sl<GetPostCommentsUseCase>(),
            addPostCommentUseCase: sl<AddPostCommentUseCase>(),
          ));

      if (sl.isRegistered<QaBloc>()) {
        sl.unregister<QaBloc>();
      }
      sl.registerFactory<QaBloc>(() => QaBloc(
            getQuestionsUseCase: sl<GetQuestionsUseCase>(),
            getQuestionDetailUseCase: sl<GetQuestionDetailUseCase>(),
            askQuestionUseCase: sl<AskQuestionUseCase>(),
            getAnswersUseCase: sl<GetAnswersUseCase>(),
            postAnswerUseCase: sl<PostAnswerUseCase>(),
            getMyQuestionsUseCase: sl<GetMyQuestionsUseCase>(),
          ));

      if (sl.isRegistered<StaticContentBloc>()) {
        sl.unregister<StaticContentBloc>();
      }
      sl.registerFactory<StaticContentBloc>(() => StaticContentBloc(
            getGuidesUseCase: sl<GetGuidesUseCase>(),
            getGuideDetailUseCase: sl<GetGuideDetailUseCase>(),
            getStaticPageUseCase: sl<GetStaticPageUseCase>(),
          ));
    });

    testWidgets('BlogPage renders list of posts on loaded state', (tester) async {
      when(() => mockRepo.getBlogPosts(
            category: any(named: 'category'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Right([tBlogPostModel.toEntity()]));

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
          home: BlogPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ঢাকায় বাড়ি খোঁজার সেরা ৫টি টিপস'), findsOneWidget);
    });

    testWidgets('QaPage renders questions and Ask FAB', (tester) async {
      when(() => mockRepo.getQuestions(
            category: any(named: 'category'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => Right([tQuestionModel.toEntity()]));

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
          home: QaPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('অগ্রিম ভাড়ার আইনগত নিয়ম কী?'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('StaticContentPage renders page content', (tester) async {
      when(() => mockRepo.getStaticPage('about'))
          .thenAnswer((_) async => Right(tStaticPageModel.toEntity()));

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
          home: StaticContentPage(slug: 'about'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ঘরবিডি একটি বিশ্বস্ত রিয়েল এস্টেট প্ল্যাটফর্ম।'), findsOneWidget);
    });
  });
}
