import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../bloc/static_content_bloc.dart';

/// Static pages reader (About, Contact, Privacy Policy, Terms, Help Center).
/// Traceability: REQ-038, REQ-039, SCR-021–025, API-053.
class StaticContentPage extends StatelessWidget {
  final String slug;
  const StaticContentPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _getTitle(slug, l10n);

    return BlocProvider(
      create: (_) => sl<StaticContentBloc>()..add(FetchStaticPageEvent(slug)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  context.read<StaticContentBloc>().add(FetchStaticPageEvent(slug));
                },
              );
            }

            if (state is StaticPageLoaded) {
              final page = state.page;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      page.body,
                      style: const TextStyle(fontSize: 15, height: 1.6),
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

  String _getTitle(String slug, AppLocalizations l10n) {
    switch (slug.toLowerCase()) {
      case 'about':
        return l10n.aboutTitle;
      case 'contact':
        return l10n.contactUsTitle;
      case 'privacy':
        return l10n.privacyTitle;
      case 'terms':
        return l10n.termsTitle;
      case 'help':
        return l10n.helpTitle;
      default:
        return 'GhorBD';
    }
  }
}
