import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/facets_entity.dart';
import '../bloc/listings_bloc.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/listing_card.dart';
import '../widgets/search_bar_widget.dart';

/// Public listings browser page with filtering, sorting and pagination.
/// Traceability: SCR-002, SCR-026, SCR-027, REQ-003, REQ-007–010, API-022, API-034.
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
  late final ListingsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.initialParams.search ?? '');
    _bloc = sl<ListingsBloc>(param1: widget.initialParams)
      ..add(ListingsFilterChanged(widget.initialParams));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
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

    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.navListings),
        ),
        body: Column(
          children: [
            // Search Bar & Filter trigger
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: BlocBuilder<ListingsBloc, ListingsState>(
                builder: (context, state) {
                  final params = state.currentParams;
                  final hasFilters = params.propertyType != null ||
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
                          _bloc.add(ListingsFilterChanged(updated));
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Sort & Result Count Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              child: BlocBuilder<ListingsBloc, ListingsState>(
                builder: (context, state) {
                  final currentSort = state.currentParams.sort;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Result count
                      if (state is ListingsLoaded)
                        Text(
                          l10n.foundResults(
                            AppFormatters.toBanglaDigits(state.total),
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        )
                      else
                        const SizedBox.shrink(),

                      // Sort dropdown
                      DropdownButton<String>(
                        value: currentSort,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.sort, size: 18),
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
            const Divider(height: 1),

            // Content List
            Expanded(
              child: BlocBuilder<ListingsBloc, ListingsState>(
                builder: (context, state) {
                  if (state is ListingsLoading) {
                    return const AppLoadingView();
                  }

                  if (state is ListingsError) {
                    return AppErrorView(
                      message: state.message,
                      onRetry: () => _bloc.add(const ListingsRefresh()),
                    );
                  }

                  if (state is ListingsEmpty) {
                    return AppEmptyView(
                      message: l10n.emptyMessage,
                      action: TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _bloc.add(
                            const ListingsFilterChanged(ListingFilterParams()),
                          );
                        },
                        child: Text(l10n.filterReset),
                      ),
                    );
                  }

                  if (state is ListingsLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _bloc.add(const ListingsRefresh());
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: state.listings.length + 1, // +1 for pager
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          if (index < state.listings.length) {
                            return ListingCard(
                              listing: state.listings[index],
                            );
                          }

                          // Pagination Controls
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left),
                                  onPressed: state.currentPage > 1
                                      ? () => _bloc.add(
                                            ListingsPageChanged(
                                              state.currentPage - 1,
                                            ),
                                          )
                                      : null,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${AppFormatters.toBanglaDigits(state.currentPage)} / ${AppFormatters.toBanglaDigits(state.totalPages)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: state.currentPage < state.totalPages
                                      ? () => _bloc.add(
                                            ListingsPageChanged(
                                              state.currentPage + 1,
                                            ),
                                          )
                                      : null,
                                ),
                              ],
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
          ],
        ),
      ),
    );
  }
}
