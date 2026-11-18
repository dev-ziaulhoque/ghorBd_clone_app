import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../browse/presentation/widgets/listing_card.dart';
import '../bloc/favorites_bloc.dart';

/// Saved favorites. Round 4: premium gradient scaffold, state
/// crossfades, and cards that reveal on scroll ([ScrollReveal] +
/// [PressScale], each in a [RepaintBoundary]).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(const FetchFavorites()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(l10n.favoritesTitle),
        ),
        body: Container(
          decoration: AppColors.scaffoldDecoration(isDark),
          child: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final Widget view;
              final String viewKey;
              if (state is FavoritesLoading) {
                viewKey = 'favorites-loading';
                view = const AppLoadingView();
              } else if (state is FavoritesError) {
                viewKey = 'favorites-error';
                view = AppErrorView(
                  message: state.messageKey,
                  onRetry: () => context
                      .read<FavoritesBloc>()
                      .add(const FetchFavorites()),
                );
              } else if (state is FavoritesLoaded &&
                  state.favorites.isEmpty) {
                viewKey = 'favorites-empty';
                view = AppEmptyView(
                  icon: Icons.favorite_border,
                  title: l10n.favoritesEmpty,
                  message: l10n.favoritesEmptySubtitle,
                  action: ElevatedButton(
                    onPressed: () => context.go('/listings'),
                    child: Text(l10n.browseListings),
                  ),
                );
              } else if (state is FavoritesLoaded) {
                viewKey = 'favorites-loaded';
                view = RefreshIndicator(
                  onRefresh: () async {
                    context.read<FavoritesBloc>().add(const FetchFavorites());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.favorites.length,
                    itemBuilder: (context, index) {
                      final listing = state.favorites[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(listing.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            color: Theme.of(context).colorScheme.error,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            context
                                .read<FavoritesBloc>()
                                .add(RemoveFavorite(listing.id));
                          },
                          child: RepaintBoundary(
                            child: ScrollReveal(
                              index: index,
                              child: PressScale(
                                child: ListingCard(
                                  listing: listing,
                                  isFavorite: true,
                                  onFavoritePressed: () {
                                    context
                                        .read<FavoritesBloc>()
                                        .add(ToggleFavorite(listing));
                                  },
                                  onTap: () {
                                    final target = listing.slug.isNotEmpty
                                        ? listing.slug
                                        : listing.id;
                                    context.push(
                                        '/listings/$target?id=${listing.id}');
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                viewKey = 'favorites-blank';
                view = const SizedBox.shrink();
              }

              return CrossfadeSwitcher(
                child: KeyedSubtree(key: ValueKey(viewKey), child: view),
              );
            },
          ),
        ),
      ),
    );
  }
}
