import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../domain/entities/listing_entity.dart';
import '../bloc/listing_detail_bloc.dart';
import '../widgets/listing_card.dart';
import '../../../contact/presentation/bloc/contact_bloc.dart';
import '../../../contact/presentation/widgets/inquiry_bottom_sheet.dart';
import '../../../contact/presentation/widgets/report_bottom_sheet.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';

/// Property listing detail screen.
/// Traceability: SCR-006, REQ-014–021, API-023.
class ListingDetailPage extends StatefulWidget {
  final String idOrSlug;

  const ListingDetailPage({
    super.key,
    required this.idOrSlug,
  });

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ListingDetailBloc>()
            ..add(ListingDetailFetch(widget.idOrSlug)),
        ),
        BlocProvider(create: (_) => sl<ContactBloc>()),
        BlocProvider(create: (_) => sl<FavoritesBloc>()),
      ],
      child: BlocConsumer<ContactBloc, ContactState>(
        listener: (context, contactState) {
          if (contactState is PhoneRevealed) {
            showDialog(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                title: Text(l10n.phoneRevealed),
                content: SelectableText(
                  contactState.phone.isNotEmpty
                      ? contactState.phone
                      : l10n.noPhoneAvailable,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: Text(MaterialLocalizations.of(dialogCtx).okButtonLabel),
                  ),
                ],
              ),
            );
          } else if (contactState is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(contactState.messageKey)),
            );
          }
        },
        builder: (context, _) {
          return BlocBuilder<ListingDetailBloc, ListingDetailState>(
            builder: (context, state) {
              final listing = state is ListingDetailLoaded ? state.listing : null;

              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.propertyOverview),
                  actions: [
                    if (listing != null)
                      IconButton(
                        icon: const Icon(Icons.flag_outlined),
                        tooltip: l10n.reportListing,
                        onPressed: () {
                          if (!AppRouter.isAuthenticated) {
                            context.push('/login');
                          } else {
                            ReportBottomSheet.show(context, listingId: listing.id);
                          }
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('https://ghorbd.com/listings')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      tooltip: l10n.addToFavorites,
                      onPressed: () {
                        if (!AppRouter.isAuthenticated) {
                          context.push('/login');
                        } else if (listing != null) {
                          context.read<FavoritesBloc>().add(ToggleFavorite(listing));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.addedToFavoritesSuccess),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                body: Builder(
                  builder: (context) {
                    if (state is ListingDetailLoading) {
                      return const AppLoadingView();
                    }

                    if (state is ListingDetailError) {
                      return AppErrorView(
                        message: state.message,
                        onRetry: () => context
                            .read<ListingDetailBloc>()
                            .add(ListingDetailFetch(widget.idOrSlug)),
                      );
                    }

                    if (state is ListingDetailLoaded) {
                      final listing = state.listing;
                      final formattedPrice =
                          AppFormatters.formatBdt(listing.pricePerMonth);

                      return Column(
                        children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Photo Gallery Carousel
                          _buildGallery(listing, isDark),
                          const SizedBox(height: AppSpacing.md),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Price & Purpose Badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          formattedPrice,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.primaryLight
                                                : AppColors.priceTag,
                                          ),
                                        ),
                                        if (listing.purpose == 'rent') ...[
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            l10n.perMonth,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (listing.verified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.verifiedBadge,
                                          borderRadius: BorderRadius.circular(
                                            AppSpacing.radiusPill,
                                          ),
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
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),

                                // Title
                                Text(
                                  listing.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.xs),

                                // Location & Views
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ),
                                    if (listing.viewCount > 0)
                                      Text(
                                        l10n.viewCount(
                                          AppFormatters.toBanglaDigits(
                                            listing.viewCount,
                                          ),
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isDark
                                                  ? AppColors.textMutedDark
                                                  : AppColors.textMutedLight,
                                            ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Safety Notice (REQ-015)
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withAlpha(20),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: AppColors.warning.withAlpha(60),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.security,
                                        color: AppColors.warning,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          l10n.safetyNotice,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),

                                // Key Property Attributes Grid
                                _buildSpecsGrid(listing, l10n, isDark),
                                const SizedBox(height: AppSpacing.lg),

                                // Description
                                if (listing.description.isNotEmpty) ...[
                                  Text(
                                    l10n.propertyOverview,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    listing.description,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // Amenities
                                if (listing.amenities.isNotEmpty) ...[
                                  Text(
                                    l10n.amenities,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.xs,
                                    children: listing.amenities
                                        .map(
                                          (a) => Chip(
                                            label: Text(a),
                                            backgroundColor: isDark
                                                ? AppColors.surfaceDark
                                                : Colors.grey[100],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                ],

                                // Report listing link
                                TextButton.icon(
                                  icon: const Icon(
                                    Icons.flag_outlined,
                                    size: 18,
                                    color: AppColors.error,
                                  ),
                                  label: Text(
                                    l10n.reportListing,
                                    style:
                                        const TextStyle(color: AppColors.error),
                                  ),
                                  onPressed: () {
                                    if (!AppRouter.isAuthenticated) {
                                      context.push('/login');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(l10n.reportListingHint),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xl),

                                // Similar Listings (REQ-021)
                                if (state.similar.isNotEmpty) ...[
                                  Text(
                                    l10n.similarListings,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Column(
                                    children: state.similar
                                        .map(
                                          (item) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: AppSpacing.md,
                                            ),
                                            child: ListingCard(listing: item),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Sticky Bar
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: AppRouter.isAuthenticated
                                  ? l10n.callOwner
                                  : l10n.loginToViewPhone,
                              icon: Icons.phone,
                              onPressed: () {
                                if (!AppRouter.isAuthenticated) {
                                  context.push('/login');
                                } else {
                                  context
                                      .read<ContactBloc>()
                                      .add(RevealContactPhone(listing.id));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: AppRouter.isAuthenticated
                                  ? l10n.sendMessage
                                  : l10n.loginToSendMessage,
                              icon: Icons.chat_bubble_outline,
                              variant: AppButtonVariant.outline,
                              onPressed: () {
                                if (!AppRouter.isAuthenticated) {
                                  context.push('/login');
                                } else {
                                  InquiryBottomSheet.show(
                                    context,
                                    listingId: listing.id,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGallery(ListingEntity listing, bool isDark) {
    if (listing.images.isEmpty) {
      return Container(
        height: 240,
        color: isDark ? AppColors.surfaceDark : Colors.grey[200],
        child: const Center(
          child: Icon(Icons.home_outlined, size: 64, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            itemCount: listing.images.length,
            onPageChanged: (index) => setState(() => _activeImageIndex = index),
            itemBuilder: (context, index) {
              return Image.network(
                listing.images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
        if (listing.images.length > 1) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              listing.images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _activeImageIndex == index
                      ? AppColors.primary
                      : Colors.grey.withAlpha(100),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecsGrid(
    ListingEntity listing,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final specs = <(IconData, String, String)>[];

    if (listing.bed > 0) {
      specs.add((
        Icons.king_bed_outlined,
        l10n.filterBedrooms,
        l10n.bedroomsCount(listing.bed),
      ));
    }
    if (listing.bath > 0) {
      specs.add((
        Icons.bathtub_outlined,
        'বাথরুম',
        l10n.bathroomsCount(listing.bath),
      ));
    }
    if (listing.size > 0) {
      specs.add((
        Icons.square_foot_outlined,
        'আয়তন',
        l10n.sizeSqft(listing.size),
      ));
    }
    if (listing.floor != null) {
      specs.add((
        Icons.stairs_outlined,
        l10n.floorNumber,
        AppFormatters.toBanglaDigits(listing.floor!),
      ));
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.8,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: specs.length,
        itemBuilder: (context, index) {
          final (icon, title, value) = specs[index];
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark
                    ? AppColors.surfaceLight.withAlpha(20)
                    : Colors.grey[100],
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
