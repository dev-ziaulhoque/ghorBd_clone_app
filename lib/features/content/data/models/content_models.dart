import '../../domain/entities/content_entities.dart';

class GuideModel {
  final String id;
  final String slug;
  final String title;
  final String? titleEn;
  final String? excerpt;
  final String? body;
  final String? coverImageUrl;
  final String? path;

  const GuideModel({
    required this.id,
    required this.slug,
    required this.title,
    this.titleEn,
    this.excerpt,
    this.body,
    this.coverImageUrl,
    this.path,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String?,
      excerpt: json['excerpt'] as String?,
      body: json['body'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      path: json['path'] as String?,
    );
  }

  GuideEntity toEntity() => GuideEntity(
        id: id,
        slug: slug,
        title: title,
        titleEn: titleEn,
        excerpt: excerpt,
        body: body,
        coverImageUrl: coverImageUrl,
        path: path,
      );
}

class StaticPageModel {
  final String id;
  final String slug;
  final String title;
  final String? titleEn;
  final String body;
  final String? path;

  const StaticPageModel({
    required this.id,
    required this.slug,
    required this.title,
    this.titleEn,
    required this.body,
    this.path,
  });

  factory StaticPageModel.fromJson(Map<String, dynamic> json) {
    return StaticPageModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleEn: json['titleEn'] as String?,
      body: json['body'] as String? ?? '',
      path: json['path'] as String?,
    );
  }

  StaticPageEntity toEntity() => StaticPageEntity(
        id: id,
        slug: slug,
        title: title,
        titleEn: titleEn,
        body: body,
        path: path,
      );
}

class BlogPostModel {
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

  const BlogPostModel({
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

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedPublishedAt;
    if (json['publishedAt'] != null) {
      parsedPublishedAt = DateTime.tryParse(json['publishedAt'].toString());
    }
    return BlogPostModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      body: json['body'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      publishedAt: parsedPublishedAt,
      readingMinutes: json['readingMinutes'] as int? ?? 3,
      path: json['path'] as String?,
    );
  }

  BlogPostEntity toEntity() => BlogPostEntity(
        id: id,
        slug: slug,
        title: title,
        excerpt: excerpt,
        body: body,
        coverImageUrl: coverImageUrl,
        categories: categories,
        publishedAt: publishedAt,
        readingMinutes: readingMinutes,
        path: path,
      );
}

class BlogCommentModel {
  final String id;
  final String postId;
  final String body;
  final DateTime? createdAt;
  final String authorName;

  const BlogCommentModel({
    required this.id,
    required this.postId,
    required this.body,
    this.createdAt,
    this.authorName = 'Anonymous',
  });

  factory BlogCommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'].toString());
    }
    return BlogCommentModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: parsedCreatedAt,
      authorName: author?['name'] as String? ?? 'Anonymous',
    );
  }

  BlogCommentEntity toEntity() => BlogCommentEntity(
        id: id,
        postId: postId,
        body: body,
        createdAt: createdAt,
        authorName: authorName,
      );
}

class QuestionModel {
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

  const QuestionModel({
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

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'].toString());
    }
    return QuestionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      excerpt: json['excerpt'] as String?,
      category: json['category'] as String? ?? 'general',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      views: json['views'] as int? ?? 0,
      answersCount: json['answersCount'] as int? ?? 0,
      createdAt: parsedCreatedAt,
      authorName: author?['name'] as String? ?? 'Anonymous',
      isOwn: json['isOwn'] as bool? ?? false,
    );
  }

  QuestionEntity toEntity() => QuestionEntity(
        id: id,
        slug: slug,
        title: title,
        body: body,
        excerpt: excerpt,
        category: category,
        tags: tags,
        views: views,
        answersCount: answersCount,
        createdAt: createdAt,
        authorName: authorName,
        isOwn: isOwn,
      );
}

class AnswerModel {
  final String id;
  final String questionId;
  final String body;
  final DateTime? createdAt;
  final String authorName;
  final bool isOwn;

  const AnswerModel({
    required this.id,
    required this.questionId,
    required this.body,
    this.createdAt,
    this.authorName = 'Anonymous',
    this.isOwn = false,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    DateTime? parsedCreatedAt;
    if (json['createdAt'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['createdAt'].toString());
    }
    return AnswerModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      questionId: json['questionId'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: parsedCreatedAt,
      authorName: author?['name'] as String? ?? 'Anonymous',
      isOwn: json['isOwn'] as bool? ?? false,
    );
  }

  AnswerEntity toEntity() => AnswerEntity(
        id: id,
        questionId: questionId,
        body: body,
        createdAt: createdAt,
        authorName: authorName,
        isOwn: isOwn,
      );
}
