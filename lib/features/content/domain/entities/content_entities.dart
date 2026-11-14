import 'package:equatable/equatable.dart';

/// Guide entity.
/// Traceability: REQ-037, REQ-038, SCR-020, SCR-021, API-051, API-052.
class GuideEntity extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String? titleEn;
  final String? excerpt;
  final String? body;
  final String? coverImageUrl;
  final String? path;

  const GuideEntity({
    required this.id,
    required this.slug,
    required this.title,
    this.titleEn,
    this.excerpt,
    this.body,
    this.coverImageUrl,
    this.path,
  });

  @override
  List<Object?> get props => [id, slug, title, excerpt, body, coverImageUrl];
}

/// Static page entity (About, Contact, Privacy, Terms, Help).
/// Traceability: REQ-038, REQ-039, SCR-021–025, API-053.
class StaticPageEntity extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String? titleEn;
  final String body;
  final String? path;

  const StaticPageEntity({
    required this.id,
    required this.slug,
    required this.title,
    this.titleEn,
    required this.body,
    this.path,
  });

  @override
  List<Object?> get props => [id, slug, title, titleEn, body, path];
}

/// Blog post entity.
/// Traceability: REQ-035, SCR-015, SCR-016, API-054, API-056.
class BlogPostEntity extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String? excerpt;
  final String? body;
  final String? coverImageUrl;
  final List<String> categories;
  final DateTime? publishedAt;
  final int readingMinutes;
  final String? path;

  const BlogPostEntity({
    required this.id,
    required this.slug,
    required this.title,
    this.excerpt,
    this.body,
    this.coverImageUrl,
    this.categories = const [],
    this.publishedAt,
    this.readingMinutes = 3,
    this.path,
  });

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        excerpt,
        body,
        coverImageUrl,
        categories,
        publishedAt,
        readingMinutes,
      ];
}

/// Blog comment entity.
/// Traceability: REQ-035, SCR-016, API-057, API-058.
class BlogCommentEntity extends Equatable {
  final String id;
  final String postId;
  final String body;
  final DateTime? createdAt;
  final String authorName;

  const BlogCommentEntity({
    required this.id,
    required this.postId,
    required this.body,
    this.createdAt,
    this.authorName = 'Anonymous',
  });

  @override
  List<Object?> get props => [id, postId, body, createdAt, authorName];
}

/// Q&A question entity.
/// Traceability: REQ-036, SCR-017, SCR-018, SCR-019, API-063, API-064, API-065.
class QuestionEntity extends Equatable {
  final String id;
  final String slug;
  final String title;
  final String? body;
  final String? excerpt;
  final String category;
  final List<String> tags;
  final int views;
  final int answersCount;
  final DateTime? createdAt;
  final String authorName;
  final bool isOwn;

  const QuestionEntity({
    required this.id,
    required this.slug,
    required this.title,
    this.body,
    this.excerpt,
    this.category = 'general',
    this.tags = const [],
    this.views = 0,
    this.answersCount = 0,
    this.createdAt,
    this.authorName = 'Anonymous',
    this.isOwn = false,
  });

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        body,
        excerpt,
        category,
        tags,
        views,
        answersCount,
        createdAt,
        authorName,
        isOwn,
      ];
}

/// Q&A answer entity.
/// Traceability: REQ-036, SCR-019, API-067, API-068.
class AnswerEntity extends Equatable {
  final String id;
  final String questionId;
  final String body;
  final DateTime? createdAt;
  final String authorName;
  final bool isOwn;

  const AnswerEntity({
    required this.id,
    required this.questionId,
    required this.body,
    this.createdAt,
    this.authorName = 'Anonymous',
    this.isOwn = false,
  });

  @override
  List<Object?> get props => [id, questionId, body, createdAt, authorName, isOwn];
}
