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
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/presentation/widgets/filter_bottom_sheet.dart';
import '../../../browse/presentation/widgets/listing_card.dart';
import '../bloc/land_bloc.dart';

class LandPage extends StatefulWidget {
  final ListingFilterParams? initialParams;
  const LandPage({super.key, this.initialParams});

  @override
  State<LandPage> createState() => _LandPageState();
}

class _LandPageState extends State<LandPage> {
  String? _selectedLandType;

  void _openFilters(BuildContext context, ListingFilterParams currentParams) {
    FilterBottomSheet.show(
      context: context,
      currentParams: currentParams,
      onApply: (newParams) {
        context.read<LandBloc>().add(FetchLandListingsEvent(params: newParams));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final landTypes = [
      {'key': null, 'label': l10n.all},
      {'key': 'residential', 'label': l10n.landTypeResidential},
      {'key': 'commercial', 'label': l10n.landTypeCommercial},
      {'key': 'agricultural', 'label': l10n.landTypeAgricultural},
      {'key': 'industrial', 'label': l10n.landTypeIndustrial},
    ];

    return BlocProvider(
      create: (_) => sl<LandBloc>()
        ..add(FetchLandListingsEvent(params: widget.initialParams)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.landTitle),
          actions: [
            BlocBuilder<LandBloc, LandState>(
              builder: (context, state) {
                final params = state is LandLoaded
                    ? state.currentParams
                    : const ListingFilterParams();
                return IconButton(
                  key: const Key('land_filter_button'),
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filterTitle,
                  onPressed: () => _openFilters(context, params),
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Horizontal Land Type Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: landTypes.map((type) {
                    final key = type['key'];
                    final label = type['label']!;
                    final isSelected = _selectedLandType == key;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppFilterChip(
                        label: label,
                        isSelected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedLandType = key);
                          context
                              .read<LandBloc>()
                              .add(FilterLandTypeEvent(key));
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: BlocBuilder<LandBloc, LandState>(
                builder: (context, state) {
                  if (state is LandLoading) {
                    return const AppLoadingView();
                  }

                  if (state is LandError) {
                    return AppErrorView(
                      message: state.messageKey,
                      onRetry: () => context
                          .read<LandBloc>()
                          .add(const FetchLandListingsEvent()),
                    );
                  }

                  if (state is LandLoaded) {
                    if (state.listings.isEmpty) {
                      return AppEmptyView(
                        icon: Icons.landscape_outlined,
                        title: l10n.noLandListings,
                        message: l10n.emptyMessage,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<LandBloc>()
                            .add(FetchLandListingsEvent(params: state.currentParams));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: state.listings.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Text(
                                l10n.foundLandResults(
                                  AppFormatters.toBanglaDigits(state.total),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                              ),
                            );
                          }

                          final listing = state.listings[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: ListingCard(
                              listing: listing,
                              onTap: () {
                                final target = listing.slug.isNotEmpty ? listing.slug : listing.id;
                                context.push('/listings/$target?id=${listing.id}');
                              },
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
