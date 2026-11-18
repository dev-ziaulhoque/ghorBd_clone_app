import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Branded shimmer skeletons shown on first paint of Home / Listings /
/// Detail instead of a bare spinner, so the layout feels instant and
/// stable (no jump when real content arrives).
class ListingCardSkeleton extends StatelessWidget {
  const ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.cardDark : const Color(0xFFDCE7DD);
    final highlight = isDark ? AppColors.surfaceDark : Colors.white;
    final block = isDark ? AppColors.surfaceDark : const Color(0xFFE7EFE8);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: AppSpacing.listingImageAspectRatio,
            child: Container(
              decoration: BoxDecoration(
                color: block,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(height: 14, width: double.infinity, color: block),
          const SizedBox(height: AppSpacing.xs),
          Container(height: 14, width: 120, color: block),
          const SizedBox(height: AppSpacing.xs),
          Container(height: 16, width: 90, color: block),
        ],
      ),
    );
  }
}

/// Vertical list of card skeletons for the Listings page first paint.
class ListingListSkeleton extends StatelessWidget {
  final int count;

  const ListingListSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('listing_list_skeleton'),
      padding: AppSpacing.screenPadding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, __) => const ListingCardSkeleton(),
    );
  }
}

/// Home first-paint skeleton: search block + category row + cards.
class HomeSkeletonView extends StatelessWidget {
  const HomeSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.cardDark : const Color(0xFFDCE7DD);
    final highlight = isDark ? AppColors.surfaceDark : Colors.white;
    final block = isDark ? AppColors.surfaceDark : const Color(0xFFE7EFE8);

    return SingleChildScrollView(
      key: const Key('home_skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      padding: AppSpacing.screenPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
          child: Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (_) => Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: block, shape: BoxShape.circle),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(height: 10, width: 44, color: block),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(height: 18, width: 160, color: block),
                const SizedBox(height: AppSpacing.md),
                const ListingCardSkeleton(),
                const SizedBox(height: AppSpacing.md),
                const ListingCardSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
