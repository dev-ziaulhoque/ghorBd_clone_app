import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../bloc/blog_bloc.dart';

/// Blog post detail and comments page.
/// Traceability: REQ-035, SCR-016, API-056, API-057, API-058.
class BlogDetailPage extends StatelessWidget {
  final String slug;
  const BlogDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BlogBloc>()..add(FetchBlogPostDetailEvent(slug)),
      child: _BlogDetailView(slug: slug),
    );
  }
}

class _BlogDetailView extends StatefulWidget {
  final String slug;
  const _BlogDetailView({required this.slug});

  @override
  State<_BlogDetailView> createState() => _BlogDetailViewState();
}

class _BlogDetailViewState extends State<_BlogDetailView> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(String postId) {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    context.read<BlogBloc>().add(AddCommentEvent(postId: postId, body: text));
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.blogTitle),
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading || state is BlogInitial) {
            return const AppLoadingView();
          }

          if (state is BlogError) {
            return AppErrorView(
              message: state.message,
              onRetry: () {
                context.read<BlogBloc>().add(FetchBlogPostDetailEvent(widget.slug));
              },
            );
          }

          if (state is BlogLoaded && state.selectedPost != null) {
            final post = state.selectedPost!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (post.categories.isNotEmpty) ...[
                        Chip(
                          label: Text(post.categories.first),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        '${post.readingMinutes} min read',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (post.coverImageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      child: Image.network(
                        post.coverImageUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    post.body ?? post.excerpt ?? '',
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                  const Divider(height: 48),

                  // Comments section
                  Text(
                    '${l10n.comments} (${state.comments.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: l10n.writeComment,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: state.isCommentSubmitting
                            ? null
                            : () => _submitComment(post.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'কোনো মন্তব্য নেই। প্রথম মন্তব্যটি আপনিই করুন!',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.comments.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final c = state.comments[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withAlpha(30),
                            child: Text(
                              c.authorName.isNotEmpty ? c.authorName[0].toUpperCase() : 'U',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(c.body, style: const TextStyle(fontSize: 14)),
                        );
                      },
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
