import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/content_entities.dart';
import '../../domain/usecases/content_usecases.dart';

// Events
abstract class BlogEvent extends Equatable {
  const BlogEvent();
  @override
  List<Object?> get props => [];
}

class FetchBlogPostsEvent extends BlogEvent {
  final String? category;
  final String? search;
  const FetchBlogPostsEvent({this.category, this.search});

  @override
  List<Object?> get props => [category, search];
}

class FetchBlogPostDetailEvent extends BlogEvent {
  final String slug;
  const FetchBlogPostDetailEvent(this.slug);

  @override
  List<Object?> get props => [slug];
}

class AddCommentEvent extends BlogEvent {
  final String postId;
  final String body;
  const AddCommentEvent({required this.postId, required this.body});

  @override
  List<Object?> get props => [postId, body];
}

// States
abstract class BlogState extends Equatable {
  const BlogState();
  @override
  List<Object?> get props => [];
}

class BlogInitial extends BlogState {}

class BlogLoading extends BlogState {}

class BlogLoaded extends BlogState {
  final List<BlogPostEntity> posts;
  final BlogPostEntity? selectedPost;
  final List<BlogCommentEntity> comments;
  final bool isCommentSubmitting;
  final String? message;

  const BlogLoaded({
    required this.posts,
    this.selectedPost,
    this.comments = const [],
    this.isCommentSubmitting = false,
    this.message,
  });

  BlogLoaded copyWith({
    List<BlogPostEntity>? posts,
    BlogPostEntity? selectedPost,
    List<BlogCommentEntity>? comments,
    bool? isCommentSubmitting,
    String? message,
  }) {
    return BlogLoaded(
      posts: posts ?? this.posts,
      selectedPost: selectedPost ?? this.selectedPost,
      comments: comments ?? this.comments,
      isCommentSubmitting: isCommentSubmitting ?? this.isCommentSubmitting,
      message: message,
    );
  }

  @override
  List<Object?> get props => [posts, selectedPost, comments, isCommentSubmitting, message];
}

class BlogError extends BlogState {
  final String message;
  const BlogError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final GetBlogPostsUseCase getBlogPostsUseCase;
  final GetBlogPostDetailUseCase getBlogPostDetailUseCase;
  final GetPostCommentsUseCase getPostCommentsUseCase;
  final AddPostCommentUseCase addPostCommentUseCase;

  BlogBloc({
    required this.getBlogPostsUseCase,
    required this.getBlogPostDetailUseCase,
    required this.getPostCommentsUseCase,
    required this.addPostCommentUseCase,
  }) : super(BlogInitial()) {
    on<FetchBlogPostsEvent>(_onFetchPosts);
    on<FetchBlogPostDetailEvent>(_onFetchDetail);
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onFetchPosts(
    FetchBlogPostsEvent event,
    Emitter<BlogState> emit,
  ) async {
    emit(BlogLoading());
    final result = await getBlogPostsUseCase(
      category: event.category,
      search: event.search,
    );
    result.fold(
      (failure) => emit(BlogError(failure.message)),
      (posts) => emit(BlogLoaded(posts: posts)),
    );
  }

  Future<void> _onFetchDetail(
    FetchBlogPostDetailEvent event,
    Emitter<BlogState> emit,
  ) async {
    emit(BlogLoading());
    final postResult = await getBlogPostDetailUseCase(event.slug);
    await postResult.fold(
      (failure) async => emit(BlogError(failure.message)),
      (post) async {
        final commentsResult = await getPostCommentsUseCase(post.id);
        final comments = commentsResult.getOrElse((_) => []);
        emit(BlogLoaded(posts: const [], selectedPost: post, comments: comments));
      },
    );
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<BlogState> emit,
  ) async {
    if (state is! BlogLoaded) return;
    final current = state as BlogLoaded;

    emit(current.copyWith(isCommentSubmitting: true));
    final result = await addPostCommentUseCase(postId: event.postId, body: event.body);

    result.fold(
      (failure) => emit(current.copyWith(isCommentSubmitting: false, message: failure.message)),
      (comment) {
        emit(current.copyWith(
          comments: [...current.comments, comment],
          isCommentSubmitting: false,
          message: 'Comment added',
        ));
      },
    );
  }
}
