import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../../browse/presentation/widgets/filter_bottom_sheet.dart';
import '../../../browse/presentation/widgets/listing_card.dart';
import '../bloc/map_bloc.dart';

class MapPage extends StatefulWidget {
  final ListingFilterParams? initialParams;
  const MapPage({super.key, this.initialParams});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilters(BuildContext context, ListingFilterParams currentParams) {
    FilterBottomSheet.show(
      context: context,
      currentParams: currentParams,
      onApply: (newParams) {
        context.read<MapBloc>().add(LoadMapDataEvent(params: newParams));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<MapBloc>()
        ..add(LoadMapDataEvent(params: widget.initialParams)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.mapTitle),
          actions: [
            BlocBuilder<MapBloc, MapState>(
              builder: (context, state) {
                final params = state is MapLoaded
                    ? state.filterParams
                    : const ListingFilterParams();
                return IconButton(
                  key: const Key('map_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filterTitle,
                  onPressed: () => _openFilters(context, params),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const AppLoadingView();
            }

            if (state is MapError) {
              return AppErrorView(
                message: state.messageKey,
                onRetry: () =>
                    context.read<MapBloc>().add(const LoadMapDataEvent()),
              );
            }

            if (state is MapLoaded) {
              return Stack(
                children: [
                  // 1. Map Canvas Background & Pin Grid
                  _buildMapCanvas(context, state, isDark, l10n),

                  // 2. Search Autocomplete Bar (Top)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _buildSearchSection(context, state, isDark, l10n),
                  ),

                  // 3. Selected Listing Card Preview (Bottom)
                  if (state.selectedListing != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _buildSelectedListingCard(
                        context,
                        state.selectedListing!,
                        l10n,
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSearchSection(
    BuildContext context,
    MapLoaded state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            key: const Key('map_place_search_field'),
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchPlaceHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<MapBloc>()
                            .add(const SearchPlacesEvent(''));
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: (query) {
              context.read<MapBloc>().add(SearchPlacesEvent(query));
            },
          ),
        ),
        if (state.placeSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            child: Material(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.placeSuggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final place = state.placeSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(place.label),
                    subtitle: Text(
                      place.fullLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _searchController.text = place.label;
                      context.read<MapBloc>().add(SelectPlaceEvent(place));
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapCanvas(
    BuildContext context,
    MapLoaded state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (state.listings.isEmpty) {
      return AppEmptyView(
        icon: Icons.map_outlined,
        title: l10n.noLocationListings,
        message: l10n.noMapLocationNotice,
      );
    }

    return Container(
      color: isDark ? const Color(0xFF131A22) : const Color(0xFFE8ECEF),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.selectedPlace != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.selectedPlace!.label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Interactive Pin Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: state.listings.map((listing) {
                  final isSelected = state.selectedListing?.id == listing.id;
                  final formattedPrice =
                      AppFormatters.formatBdt(listing.pricePerMonth);

                  return GestureDetector(
                    key: ValueKey('map_pin_${listing.id}'),
                    onTap: () {
                      context
                          .read<MapBloc>()
                          .add(SelectListingPinEvent(listing));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isSelected ? 40 : 15),
                            blurRadius: isSelected ? 6 : 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : (listing.verified
                                    ? AppColors.verifiedBadge
                                    : AppColors.primary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedPrice,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              // Safety / Map location notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.noMapLocationNotice,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedListingCard(
    BuildContext context,
    ListingEntity listing,
    AppLocalizations l10n,
  ) {
    return ListingCard(
      key: const Key('map_selected_listing_card'),
      listing: listing,
      onTap: () {
        context.push('/listings/${listing.slug}');
      },
    );
  }
}
