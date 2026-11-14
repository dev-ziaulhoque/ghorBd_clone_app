import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/content_entities.dart';

/// Contract for Content repository (Guides, Blog, Q&A, Static Pages).
/// Traceability: REQ-035–040, SCR-015–025, API-051–060, API-062–069.
abstract class ContentRepository {
  Future<Either<Failure, List<GuideEntity>>> getGuides({int page = 1, int perPage = 12});
  Future<Either<Failure, GuideEntity>> getGuideDetail(String slug);

  Future<Either<Failure, StaticPageEntity>> getStaticPage(String slug);

  Future<Either<Failure, List<BlogPostEntity>>> getBlogPosts({
    String? category,
    int page = 1,
    int perPage = 12,
    String? search,
  });
  Future<Either<Failure, BlogPostEntity>> getBlogPostDetail(String slug);
  Future<Either<Failure, List<BlogCommentEntity>>> getPostComments(String postId);
  Future<Either<Failure, BlogCommentEntity>> addPostComment(String postId, String body);

  Future<Either<Failure, List<QuestionEntity>>> getQuestions({
    String? category,
    int page = 1,
    int perPage = 12,
    String? sort,
  });
  Future<Either<Failure, QuestionEntity>> getQuestionDetail(String idOrSlug);
  Future<Either<Failure, QuestionEntity>> askQuestion({
    required String title,
    required String body,
    required String category,
    List<String> tags = const [],
  });
  Future<Either<Failure, List<AnswerEntity>>> getAnswers(String questionId);
  Future<Either<Failure, AnswerEntity>> postAnswer({
    required String questionId,
    required String body,
  });
  Future<Either<Failure, List<QuestionEntity>>> getMyQuestions();
}
