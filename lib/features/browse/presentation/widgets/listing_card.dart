import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/listing_entity.dart';

/// Property listing card component adhering to REQ-007 and DESIGN_AUDIT.md.
/// Displays photo, verified badge, price in BDT (lakh/crore), and key specs.
///
/// Responsive/overflow notes (V2): the photo uses an aspect ratio instead of
/// a fixed height so the card scales from 320dp phones to tablet grid cells;
/// the price row and spec wrap shrink/ellipsis instead of overflowing at
/// large text scales.
class ListingCard extends StatelessWidget {
  final ListingEntity listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = l10n.localeName == 'bn';

    final formattedPrice = AppFormatters.formatBdt(listing.pricePerMonth);

    return AppCard(
      onTap: onTap ??
          () {
            final target =
                listing.slug.isNotEmpty ? listing.slug : listing.id;
            context.push('/listings/$target?id=${listing.id}');
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Thumbnail container with Verified Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: AspectRatio(
                  aspectRatio: AppSpacing.listingImageAspectRatio,
                  child: Container(
                    width: double.infinity,
                    color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                    child: listing.images.isNotEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              // Round 4 smoothness: decode the photo at
                              // (roughly) its displayed size instead of
                              // full resolution — far less memory churn
                              // and jank while scrolling long lists.
                              final dpr =
                                  MediaQuery.devicePixelRatioOf(context);
                              final cacheWidth =
                                  (constraints.maxWidth * dpr).round();
                              return CachedNetworkImage(
                                imageUrl: listing.images.first,
                                fit: BoxFit.cover,
                                memCacheWidth:
                                    cacheWidth > 0 ? cacheWidth : null,
                                // Fade the photo in over the placeholder
                                // instead of popping (Round 4).
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                                fadeOutDuration:
                                    const Duration(milliseconds: 120),
                                errorWidget: (_, __, ___) =>
                                    _buildPlaceholder(),
                                placeholder: (_, __) => _buildPlaceholder(),
                              );
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
              ),
              if (listing.verified)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.verifiedBadge,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.verifiedBadge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (listing.purpose.isNotEmpty)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(160),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      listing.purpose == 'sale' ? l10n.sale : l10n.rent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (onFavoritePressed != null)
                Positioned(
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Material(
                    color: Colors.black45,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onFavoritePressed,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Price Tag (price-first, mint accent on dark surfaces)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  formattedPrice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.accentMint : AppColors.priceTag,
                  ),
                ),
              ),
              if (listing.purpose == 'rent') ...[
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    l10n.perMonth,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Title
          Text(
            listing.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  listing.address.isNotEmpty
                      ? '${listing.address}, ${listing.city}'
                      : listing.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Property specs: Bed, Bath, Sqft (numbers in Bengali digits
          // when the UI locale is Bengali)
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              if (listing.bed > 0)
                _buildSpecItem(
                  icon: Icons.king_bed_outlined,
                  text: l10n.bedroomsCount(
                    AppFormatters.formatNumber(listing.bed, isBangla: isBn),
                  ),
                  isDark: isDark,
                  context: context,
                ),
              if (listing.bath > 0)
                _buildSpecItem(
                  icon: Icons.bathtub_outlined,
                  text: l10n.bathroomsCount(
                    AppFormatters.formatNumber(listing.bath, isBangla: isBn),
                  ),
                  isDark: isDark,
                  context: context,
                ),
              if (listing.size > 0)
                _buildSpecItem(
                  icon: Icons.square_foot_outlined,
                  text: l10n.sizeSqft(
                    AppFormatters.formatNumber(listing.size, isBangla: isBn),
                  ),
                  isDark: isDark,
                  context: context,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Center(
      child: isLoading
          ? const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : const Icon(
              Icons.home_outlined,
              size: 48,
              color: Colors.grey,
            ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String text,
    required bool isDark,
    required BuildContext context,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
