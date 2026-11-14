import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../bloc/static_content_bloc.dart';

/// Guide detail reader page.
/// Traceability: REQ-038, SCR-021, API-052.
class GuideDetailPage extends StatelessWidget {
  final String slug;
  const GuideDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<StaticContentBloc>()..add(FetchGuideDetailEvent(slug)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.guidesTitle),
        ),
        body: BlocBuilder<StaticContentBloc, StaticContentState>(
          builder: (context, state) {
            if (state is StaticContentLoading || state is StaticContentInitial) {
              return const AppLoadingView();
            }

            if (state is StaticContentError) {
              return AppErrorView(
                message: state.message,
                onRetry: () {
                  context.read<StaticContentBloc>().add(FetchGuideDetailEvent(slug));
                },
              );
            }

            if (state is GuideDetailLoaded) {
              final guide = state.guide;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (guide.coverImageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        child: Image.network(
                          guide.coverImageUrl!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(
                      guide.body ?? guide.excerpt ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
