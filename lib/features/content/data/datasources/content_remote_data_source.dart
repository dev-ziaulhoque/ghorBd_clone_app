import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/content_models.dart';

abstract class ContentRemoteDataSource {
  Future<List<GuideModel>> getGuides({int page = 1, int perPage = 12});
  Future<GuideModel> getGuideDetail(String slug);

  Future<StaticPageModel> getStaticPage(String slug);

  Future<List<BlogPostModel>> getBlogPosts({
    String? category,
    int page = 1,
    int perPage = 12,
    String? search,
  });
  Future<BlogPostModel> getBlogPostDetail(String slug);
  Future<List<BlogCommentModel>> getPostComments(String postId);
  Future<BlogCommentModel> addPostComment(String postId, String body);

  Future<List<QuestionModel>> getQuestions({
    String? category,
    int page = 1,
    int perPage = 12,
    String? sort,
  });
  Future<QuestionModel> getQuestionDetail(String idOrSlug);
  Future<QuestionModel> askQuestion({
    required String title,
    required String body,
    required String category,
    List<String> tags = const [],
  });
  Future<List<AnswerModel>> getAnswers(String questionId);
  Future<AnswerModel> postAnswer({
    required String questionId,
    required String body,
  });
  Future<List<QuestionModel>> getMyQuestions();
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final DioClient dioClient;

  ContentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<GuideModel>> getGuides({int page = 1, int perPage = 12}) async {
    final response = await dioClient.get(
      ApiEndpoints.guides,
      queryParameters: {'page': page, 'perPage': perPage},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((item) => GuideModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<GuideModel> getGuideDetail(String slug) async {
    final response = await dioClient.get(ApiEndpoints.guideDetail(slug));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final guideJson = data['guide'] as Map<String, dynamic>? ?? data;
    return GuideModel.fromJson(guideJson);
  }

  @override
  Future<StaticPageModel> getStaticPage(String slug) async {
    final response = await dioClient.get(ApiEndpoints.staticPage(slug));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final pageJson = data['page'] as Map<String, dynamic>? ?? data;
    return StaticPageModel.fromJson(pageJson);
  }

  @override
  Future<List<BlogPostModel>> getBlogPosts({
    String? category,
    int page = 1,
    int perPage = 12,
    String? search,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      if (category != null && category.isNotEmpty) 'tag': category,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await dioClient.get(ApiEndpoints.blogPosts, queryParameters: query);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((item) => BlogPostModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<BlogPostModel> getBlogPostDetail(String slug) async {
    final response = await dioClient.get(ApiEndpoints.blogPostDetail(slug));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final postJson = data['post'] as Map<String, dynamic>? ?? data;
    return BlogPostModel.fromJson(postJson);
  }

  @override
  Future<List<BlogCommentModel>> getPostComments(String postId) async {
    final response = await dioClient.get(ApiEndpoints.postComments(postId));
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((item) => BlogCommentModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<BlogCommentModel> addPostComment(String postId, String body) async {
    final response = await dioClient.post(
      ApiEndpoints.postComments(postId),
      data: {'body': body, 'parentId': null},
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final commentJson = data['comment'] as Map<String, dynamic>? ?? data;
    return BlogCommentModel.fromJson(commentJson);
  }

  @override
  Future<List<QuestionModel>> getQuestions({
    String? category,
    int page = 1,
    int perPage = 12,
    String? sort,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      if (category != null && category.isNotEmpty && category != 'all') 'category': category,
      if (sort != null) 'sort': sort,
    };
    final response = await dioClient.get(ApiEndpoints.qaQuestions, queryParameters: query);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((item) => QuestionModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<QuestionModel> getQuestionDetail(String idOrSlug) async {
    final response = await dioClient.get(ApiEndpoints.questionDetail(idOrSlug));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final qJson = data['question'] as Map<String, dynamic>? ?? data;
    return QuestionModel.fromJson(qJson);
  }

  @override
  Future<QuestionModel> askQuestion({
    required String title,
    required String body,
    required String category,
    List<String> tags = const [],
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.qaQuestions,
      data: {
        'title': title,
        'body': body,
        'category': category,
        'tags': tags,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final qJson = data['question'] as Map<String, dynamic>? ?? data;
    return QuestionModel.fromJson(qJson);
  }

  @override
  Future<List<AnswerModel>> getAnswers(String questionId) async {
    final response = await dioClient.get(ApiEndpoints.questionAnswers(questionId));
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((item) => AnswerModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<AnswerModel> postAnswer({
    required String questionId,
    required String body,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.questionAnswers(questionId),
      data: {'body': body},
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final aJson = data['answer'] as Map<String, dynamic>? ?? data;
    return AnswerModel.fromJson(aJson);
  }

  @override
  Future<List<QuestionModel>> getMyQuestions() async {
    final response = await dioClient.get(ApiEndpoints.myQuestions);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data.map((item) => QuestionModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
