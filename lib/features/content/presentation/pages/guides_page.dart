import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../bloc/static_content_bloc.dart';

/// Guides listing page.
/// Traceability: REQ-037, SCR-020, API-051.
class GuidesPage extends StatelessWidget {
  const GuidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StaticContentBloc>()..add(const FetchGuidesEvent()),
      child: const _GuidesView(),
    );
  }
}

class _GuidesView extends StatelessWidget {
  const _GuidesView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.guidesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                context.read<StaticContentBloc>().add(const FetchGuidesEvent());
              },
            );
          }

          if (state is GuidesLoaded) {
            if (state.guides.isEmpty) {
              return const AppEmptyView(
                title: 'কোনো গাইড পাওয়া যায়নি',
                message: 'নতুন প্রপার্টি ও জমি সংক্রান্ত গাইড শীঘ্রই আসছে।',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.guides.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final guide = state.guides[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withAlpha(25),
                      child: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                    ),
                    title: Text(
                      guide.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: guide.excerpt != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              guide.excerpt!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/guides/${guide.slug}'),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
