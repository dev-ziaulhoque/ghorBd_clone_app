import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/content_entities.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_data_source.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;

  ContentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<GuideEntity>>> getGuides({int page = 1, int perPage = 12}) async {
    try {
      final models = await remoteDataSource.getGuides(page: page, perPage: perPage);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GuideEntity>> getGuideDetail(String slug) async {
    try {
      final model = await remoteDataSource.getGuideDetail(slug);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaticPageEntity>> getStaticPage(String slug) async {
    try {
      final model = await remoteDataSource.getStaticPage(slug);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogPostEntity>>> getBlogPosts({
    String? category,
    int page = 1,
    int perPage = 12,
    String? search,
  }) async {
    try {
      final models = await remoteDataSource.getBlogPosts(
        category: category,
        page: page,
        perPage: perPage,
        search: search,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPostEntity>> getBlogPostDetail(String slug) async {
    try {
      final model = await remoteDataSource.getBlogPostDetail(slug);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BlogCommentEntity>>> getPostComments(String postId) async {
    try {
      final models = await remoteDataSource.getPostComments(postId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogCommentEntity>> addPostComment(String postId, String body) async {
    try {
      final model = await remoteDataSource.addPostComment(postId, body);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    String? category,
    int page = 1,
    int perPage = 12,
    String? sort,
  }) async {
    try {
      final models = await remoteDataSource.getQuestions(
        category: category,
        page: page,
        perPage: perPage,
        sort: sort,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuestionEntity>> getQuestionDetail(String idOrSlug) async {
    try {
      final model = await remoteDataSource.getQuestionDetail(idOrSlug);
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, QuestionEntity>> askQuestion({
    required String title,
    required String body,
    required String category,
    List<String> tags = const [],
  }) async {
    try {
      final model = await remoteDataSource.askQuestion(
        title: title,
        body: body,
        category: category,
        tags: tags,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnswerEntity>>> getAnswers(String questionId) async {
    try {
      final models = await remoteDataSource.getAnswers(questionId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnswerEntity>> postAnswer({
    required String questionId,
    required String body,
  }) async {
    try {
      final model = await remoteDataSource.postAnswer(
        questionId: questionId,
        body: body,
      );
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuestionEntity>>> getMyQuestions() async {
    try {
      final models = await remoteDataSource.getMyQuestions();
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
