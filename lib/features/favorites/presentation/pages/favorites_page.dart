import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../browse/presentation/widgets/listing_card.dart';
import '../bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<FavoritesBloc>()..add(const FetchFavorites()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.favoritesTitle),
        ),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const AppLoadingView();
            }

            if (state is FavoritesError) {
              return AppErrorView(
                message: state.messageKey,
                onRetry: () =>
                    context.read<FavoritesBloc>().add(const FetchFavorites()),
              );
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return AppEmptyView(
                  icon: Icons.favorite_border,
                  title: l10n.favoritesEmpty,
                  message: l10n.favoritesEmptySubtitle,
                  action: ElevatedButton(
                    onPressed: () => context.go('/listings'),
                    child: Text(l10n.browseListings),
                  ),
                );
              }

              return RefreshIndicator(
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Theme.of(context).colorScheme.error,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context
                              .read<FavoritesBloc>()
                              .add(RemoveFavorite(listing.id));
                        },
                        child: ListingCard(
                          listing: listing,
                          isFavorite: true,
                          onFavoritePressed: () {
                            context
                                .read<FavoritesBloc>()
                                .add(ToggleFavorite(listing));
                          },
                          onTap: () {
                            final target = listing.slug.isNotEmpty ? listing.slug : listing.id;
                            context.push('/listings/$target?id=${listing.id}');
                          },
                        ),
                      ),
                    );
                  },
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
