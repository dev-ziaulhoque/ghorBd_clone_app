import 'dart:async';

import 'package:fpdart/fpdart.dart';
import '../../../../core/cache/response_cache.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/content_entities.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_data_source.dart';
import '../models/content_models.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource remoteDataSource;

  /// Optional response cache (Round 2): guides and static pages are
  /// slow-changing editorial content, served stale-while-revalidate
  /// with a 24 h TTL. Blog posts and Q&A are dynamic and stay
  /// network-only. Null in existing tests → network-only behaviour.
  final ResponseCache? _cache;

  ContentRepositoryImpl({required this.remoteDataSource, ResponseCache? cache})
      : _cache = cache;

  /// Returns the decoded cached payload for [key], or null on a miss /
  /// corrupt entry. When the entry is stale, [revalidate] is fired in
  /// the background (it refetches and rewrites the cache itself).
  Future<dynamic> _swrRead(
    String key,
    Duration ttl,
    Future<void> Function() revalidate,
  ) async {
    final cache = _cache;
    if (cache == null) return null;
    final entry = await cache.read(key);
    if (entry == null) return null;
    if (entry.isStale(ttl)) unawaited(revalidate());
    return entry.data;
  }

  Future<void> _writeCache(String key, dynamic data) async {
    final cache = _cache;
    if (cache != null) await cache.write(key, data);
  }

  @override
  Future<Either<Failure, List<GuideEntity>>> getGuides({int page = 1, int perPage = 12}) async {
    final key = 'guides_${page}_$perPage';
    final cached = await _swrRead(key, ResponseCache.staticContentTtl, () async {
      try {
        final fresh = await remoteDataSource.getGuides(page: page, perPage: perPage);
        await _writeCache(key, fresh.map((m) => m.toJson()).toList());
      } catch (_) {}
    });
    if (cached is List) {
      try {
        return Right(
          cached
              .map((j) => GuideModel.fromJson(j as Map<String, dynamic>))
              .map((m) => m.toEntity())
              .toList(),
        );
      } catch (_) {
        // Corrupt payload — fall through to the network.
      }
    }
    try {
      final models = await remoteDataSource.getGuides(page: page, perPage: perPage);
      unawaited(_writeCache(key, models.map((m) => m.toJson()).toList()));
      return Right(models.map((m) => m.toEntity()).toList());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, GuideEntity>> getGuideDetail(String slug) async {
    final key = 'guide_$slug';
    final cached = await _swrRead(key, ResponseCache.staticContentTtl, () async {
      try {
        final fresh = await remoteDataSource.getGuideDetail(slug);
        await _writeCache(key, fresh.toJson());
      } catch (_) {}
    });
    if (cached is Map) {
      try {
        return Right(
          GuideModel.fromJson(Map<String, dynamic>.from(cached)).toEntity(),
        );
      } catch (_) {
        // Corrupt payload — fall through to the network.
      }
    }
    try {
      final model = await remoteDataSource.getGuideDetail(slug);
      unawaited(_writeCache(key, model.toJson()));
      return Right(model.toEntity());
    } on Exception catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaticPageEntity>> getStaticPage(String slug) async {
    final key = 'static_page_$slug';
    final cached = await _swrRead(key, ResponseCache.staticContentTtl, () async {
      try {
        final fresh = await remoteDataSource.getStaticPage(slug);
        await _writeCache(key, fresh.toJson());
      } catch (_) {}
    });
    if (cached is Map) {
      try {
        return Right(
          StaticPageModel.fromJson(Map<String, dynamic>.from(cached))
              .toEntity(),
        );
      } catch (_) {
        // Corrupt payload — fall through to the network.
      }
    }
    try {
      final model = await remoteDataSource.getStaticPage(slug);
      unawaited(_writeCache(key, model.toJson()));
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
