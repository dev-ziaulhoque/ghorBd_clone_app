import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/content_entities.dart';
import '../repositories/content_repository.dart';

class GetGuidesUseCase {
  final ContentRepository repository;
  GetGuidesUseCase(this.repository);

  Future<Either<Failure, List<GuideEntity>>> call({int page = 1, int perPage = 12}) {
    return repository.getGuides(page: page, perPage: perPage);
  }
}

class GetGuideDetailUseCase {
  final ContentRepository repository;
  GetGuideDetailUseCase(this.repository);

  Future<Either<Failure, GuideEntity>> call(String slug) {
    return repository.getGuideDetail(slug);
  }
}

class GetStaticPageUseCase {
  final ContentRepository repository;
  GetStaticPageUseCase(this.repository);

  Future<Either<Failure, StaticPageEntity>> call(String slug) {
    return repository.getStaticPage(slug);
  }
}

class GetBlogPostsUseCase {
  final ContentRepository repository;
  GetBlogPostsUseCase(this.repository);

  Future<Either<Failure, List<BlogPostEntity>>> call({
    String? category,
    int page = 1,
    int perPage = 12,
    String? search,
  }) {
    return repository.getBlogPosts(
      category: category,
      page: page,
      perPage: perPage,
      search: search,
    );
  }
}

class GetBlogPostDetailUseCase {
  final ContentRepository repository;
  GetBlogPostDetailUseCase(this.repository);

  Future<Either<Failure, BlogPostEntity>> call(String slug) {
    return repository.getBlogPostDetail(slug);
  }
}

class GetPostCommentsUseCase {
  final ContentRepository repository;
  GetPostCommentsUseCase(this.repository);

  Future<Either<Failure, List<BlogCommentEntity>>> call(String postId) {
    return repository.getPostComments(postId);
  }
}

class AddPostCommentUseCase {
  final ContentRepository repository;
  AddPostCommentUseCase(this.repository);

  Future<Either<Failure, BlogCommentEntity>> call({
    required String postId,
    required String body,
  }) {
    return repository.addPostComment(postId, body);
  }
}

class GetQuestionsUseCase {
  final ContentRepository repository;
  GetQuestionsUseCase(this.repository);

  Future<Either<Failure, List<QuestionEntity>>> call({
    String? category,
    int page = 1,
    int perPage = 12,
    String? sort,
  }) {
    return repository.getQuestions(
      category: category,
      page: page,
      perPage: perPage,
      sort: sort,
    );
  }
}

class GetQuestionDetailUseCase {
  final ContentRepository repository;
  GetQuestionDetailUseCase(this.repository);

  Future<Either<Failure, QuestionEntity>> call(String idOrSlug) {
    return repository.getQuestionDetail(idOrSlug);
  }
}

class AskQuestionUseCase {
  final ContentRepository repository;
  AskQuestionUseCase(this.repository);

  Future<Either<Failure, QuestionEntity>> call({
    required String title,
    required String body,
    required String category,
    List<String> tags = const [],
  }) {
    return repository.askQuestion(
      title: title,
      body: body,
      category: category,
      tags: tags,
    );
  }
}

class GetAnswersUseCase {
  final ContentRepository repository;
  GetAnswersUseCase(this.repository);

  Future<Either<Failure, List<AnswerEntity>>> call(String questionId) {
    return repository.getAnswers(questionId);
  }
}

class PostAnswerUseCase {
  final ContentRepository repository;
  PostAnswerUseCase(this.repository);

  Future<Either<Failure, AnswerEntity>> call({
    required String questionId,
    required String body,
  }) {
    return repository.postAnswer(questionId: questionId, body: body);
  }
}

class GetMyQuestionsUseCase {
  final ContentRepository repository;
  GetMyQuestionsUseCase(this.repository);

  Future<Either<Failure, List<QuestionEntity>>> call() {
    return repository.getMyQuestions();
  }
}
