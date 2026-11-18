import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/glass_bar.dart';
import '../../../../shared/widgets/listing_skeleton.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/facets_entity.dart';
import '../bloc/listings_bloc.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/listing_card.dart';
import '../widgets/search_bar_widget.dart';

/// Public listings browser page with filtering, sorting and pagination.
/// Traceability: SCR-002, SCR-026, SCR-027, REQ-003, REQ-007–010, API-022, API-034.
///
/// Responsive (V2): results render in the shared 1→2→3-column layout
/// (list on phones, grid on tablets/large), content is centred with a
/// max width, and reaching the end of the list loads the next page.
///
/// Round 3: the page is a [CustomScrollView] — floating/snapping
/// [SliverAppBar], the search bar as a floating sliver header, results
/// as lazy [SliverList]/[SliverGrid] (no shrink-wrapped grids, so long
/// result sets stay smooth).
///
/// Round 4: premium gradient scaffold + glassy app bar; the loading
/// skeleton and the content crossfade via [CrossfadeSwitcher] (the
/// skeleton gets its own controller-less scroll view so the shared
/// [ScrollController] is never attached to two scroll views during
/// the transition); result cards reveal on scroll via [ScrollReveal]
/// inside [RepaintBoundary]s.
class ListingsPage extends StatefulWidget {
  final ListingFilterParams initialParams;

  const ListingsPage({
    super.key,
    this.initialParams = const ListingFilterParams(),
  });

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final ListingsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialParams.search ?? '');
    _scrollController = ScrollController()..addListener(_onScroll);
    _bloc = sl<ListingsBloc>(param1: widget.initialParams)
      ..add(ListingsFilterChanged(widget.initialParams));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _bloc.close();
    super.dispose();
  }

  /// Infinite scroll: when the user nears the end and more pages exist,
  /// ask the bloc for the next page (it appends and de-dupes).
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 400) return;
    final state = _bloc.state;
    if (state is ListingsLoaded && state.currentPage < state.totalPages) {
      _bloc.add(ListingsPageChanged(state.currentPage + 1));
    }
  }

  void _onSearch(String query) {
    final updated = _bloc.state.currentParams.copyWith(
      search: query.trim(),
      clearSearch: query.trim().isEmpty,
    );
    _bloc.add(ListingsFilterChanged(updated));
  }

  void _onSortChanged(String? sort) {
    if (sort != null) {
      final updated = _bloc.state.currentParams.copyWith(sort: sort);
      _bloc.add(ListingsFilterChanged(updated));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        // Premium scaffold decoration painted by the body wrapper.
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
            decoration: AppColors.scaffoldDecoration(isDark),
            child: Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: BlocBuilder<ListingsBloc, ListingsState>(
                    builder: (context, state) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final sidePad = AppSpacing.pagePadding(width) +
                              math.max(
                                0.0,
                                (width - AppSpacing.contentMaxWidth) / 2,
                              );
                          final textScale = MediaQuery.textScalerOf(context)
                              .scale(1)
                              .clamp(1.0, 1.5);
                          final searchExtent = AppSpacing.inputHeight +
                              AppSpacing.sm * 2 +
                              (textScale - 1) * 24;

                          // Header slivers shared by the skeleton and
                          // content scroll views (app bar, floating
                          // search, sort bar).
                          final headerSlivers = <Widget>[
                            SliverAppBar(
                              floating: true,
                              snap: true,
                              pinned: false,
                              backgroundColor: Colors.transparent,
                              flexibleSpace: const GlassBarBackground(),
                              title: Text(l10n.navListings),
                            ),

                            // Search — floating sliver header (hides on
                            // scroll down, floats/snaps back on scroll up).
                            SliverPersistentHeader(
                              floating: true,
                              delegate: _ListingsSearchHeaderDelegate(
                                extent: searchExtent,
                                child: Container(
                                  // Opaque surface strip (the scaffold
                                  // itself is transparent over the
                                  // premium gradient since Round 4).
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.surfaceLight,
                                  padding: EdgeInsets.fromLTRB(
                                    sidePad,
                                    AppSpacing.sm,
                                    sidePad,
                                    AppSpacing.sm,
                                  ),
                                  child:
                                      BlocBuilder<ListingsBloc, ListingsState>(
                                    builder: (context, state) {
                                      final params = state.currentParams;
                                      final hasFilters =
                                          params.propertyType != null ||
                                              params.purpose != null ||
                                              params.bedrooms != null ||
                                              params.minPrice != null ||
                                              params.maxPrice != null ||
                                              params.verified != null;

                                      return SearchBarWidget(
                                        controller: _searchController,
                                        onSubmitted: _onSearch,
                                        hasActiveFilters: hasFilters,
                                        onFilterTap: () {
                                          FilterBottomSheet.show(
                                            context: context,
                                            currentParams: params,
                                            onApply: (updated) {
                                              _bloc.add(
                                                ListingsFilterChanged(updated),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                            // Sort & result count bar.
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  sidePad,
                                  AppSpacing.xs,
                                  sidePad,
                                  AppSpacing.xs,
                                ),
                                child:
                                    BlocBuilder<ListingsBloc, ListingsState>(
                                  builder: (context, state) {
                                    final currentSort =
                                        state.currentParams.sort;

                                    return Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: AppSpacing.md,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        if (state is ListingsLoaded)
                                          Text(
                                            l10n.foundResults(
                                              AppFormatters.toBanglaDigits(
                                                state.total,
                                              ),
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          )
                                        else
                                          const SizedBox.shrink(),
                                        DropdownButton<String>(
                                          value: currentSort,
                                          underline: const SizedBox.shrink(),
                                          icon:
                                              const Icon(Icons.sort, size: 18),
                                          items: [
                                            DropdownMenuItem(
                                              value: 'newest',
                                              child: Text(l10n.sortNewest),
                                            ),
                                            DropdownMenuItem(
                                              value: 'price_asc',
                                              child: Text(l10n.sortPriceAsc),
                                            ),
                                            DropdownMenuItem(
                                              value: 'price_desc',
                                              child: Text(l10n.sortPriceDesc),
                                            ),
                                            DropdownMenuItem(
                                              value: 'popular',
                                              child: Text(l10n.sortPopular),
                                            ),
                                          ],
                                          onChanged: _onSortChanged,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(child: Divider(height: 1)),
                          ];

                          final isLoading = state is ListingsLoading ||
                              state is ListingsInitial;

                          // Skeleton and content are separate scroll
                          // views so they can crossfade; only the
                          // content view owns the shared controller.
                          final Widget scrollView = isLoading
                              ? CustomScrollView(
                                  key: const ValueKey('listings-loading'),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: [
                                    ...headerSlivers,
                                    const SliverFillRemaining(
                                      hasScrollBody: true,
                                      child: ListingListSkeleton(),
                                    ),
                                  ],
                                )
                              : CustomScrollView(
                                  key: const ValueKey('listings-content'),
                                  controller: _scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  slivers: [
                                    ...headerSlivers,
                                    _resultsSliver(
                                      context,
                                      l10n,
                                      state,
                                      width,
                                      sidePad,
                                    ),
                                  ],
                                );

                          return RefreshIndicator(
                            onRefresh: () async {
                              _bloc.add(const ListingsRefresh());
                            },
                            child: CrossfadeSwitcher(child: scrollView),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Results sliver for the loaded/error/empty states (loading is
  /// rendered as its own skeleton scroll view in [build]): lazy
  /// list/grid plus a load-more footer while more pages exist (the
  /// scroll listener also auto-loads the next page).
  Widget _resultsSliver(
    BuildContext context,
    AppLocalizations l10n,
    ListingsState state,
    double width,
    double sidePad,
  ) {
    if (state is ListingsError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(
          message: state.message,
          onRetry: () => _bloc.add(const ListingsRefresh()),
        ),
      );
    }

    if (state is ListingsEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppEmptyView(
          message: l10n.emptyMessage,
          action: TextButton(
            onPressed: () {
              _searchController.clear();
              _bloc.add(const ListingsFilterChanged(ListingFilterParams()));
            },
            child: Text(l10n.filterReset),
          ),
        ),
      );
    }

    if (state is! ListingsLoaded) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final columns = AppSpacing.listingColumns(width);
    final hasMore = state.currentPage < state.totalPages;

    // Round 4: cards reveal as they scroll into view, isolated in
    // RepaintBoundarys so entrances never repaint neighbours.
    Widget animatedCard(int index) => RepaintBoundary(
          child: ScrollReveal(
            index: index,
            child: PressScale(
              child: ListingCard(listing: state.listings[index]),
            ),
          ),
        );

    final Widget results;
    if (columns == 1) {
      results = SliverPadding(
        padding: EdgeInsets.fromLTRB(
          sidePad,
          AppSpacing.md,
          sidePad,
          AppSpacing.md,
        ),
        sliver: SliverList.separated(
          itemCount: state.listings.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, index) => animatedCard(index),
        ),
      );
    } else {
      results = SliverPadding(
        padding: EdgeInsets.fromLTRB(
          sidePad,
          AppSpacing.md,
          sidePad,
          AppSpacing.md,
        ),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 430,
          ),
          itemCount: state.listings.length,
          itemBuilder: (_, index) => animatedCard(index),
        ),
      );
    }

    if (!hasMore) return results;

    return SliverMainAxisGroup(
      slivers: [
        results,
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: IconButton(
                icon: const Icon(Icons.expand_more),
                tooltip: l10n.all,
                onPressed: () =>
                    _bloc.add(ListingsPageChanged(state.currentPage + 1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fixed-height delegate for the floating search header on Listings.
class _ListingsSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  _ListingsSearchHeaderDelegate({required this.child, required this.extent});

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _ListingsSearchHeaderDelegate oldDelegate) {
    return oldDelegate.extent != extent || oldDelegate.child != child;
  }
}
