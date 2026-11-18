import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/security/secure_storage.dart';
import '../../../../core/security/session_manager.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_motion.dart';
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
  final String? fallbackId;

  const ListingDetailPage({
    super.key,
    required this.idOrSlug,
    this.fallbackId,
  });

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  int _activeImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (sl.isRegistered<SessionManager>()) {
      final session = sl<SessionManager>();
      if (session.currentStatus != SessionStatus.authenticated) {
        await session.initialize();
        if (mounted) setState(() {});
      }
    }
  }

  Future<bool> _ensureAuthenticated() async {
    if (AppRouter.isAuthenticated) return true;
    if (sl.isRegistered<AppSecureStorage>()) {
      final hasSession = await sl<AppSecureStorage>().hasValidSession();
      if (hasSession && sl.isRegistered<SessionManager>()) {
        await sl<SessionManager>().initialize();
        if (AppRouter.isAuthenticated) return true;
      }
    } else if (sl.isRegistered<SessionManager>()) {
      final session = sl<SessionManager>();
      await session.initialize();
      if (AppRouter.isAuthenticated) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ListingDetailBloc>()
            ..add(ListingDetailFetch(widget.idOrSlug, fallbackId: widget.fallbackId)),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  if (contactState.phone.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.call, size: 18),
                      label: Text(l10n.callOwner),
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'tel',
                          path: contactState.phone.replaceAll(' ', ''),
                        );
                        final launched = await launchUrl(uri);
                        if (!launched && dialogCtx.mounted) {
                          ScaffoldMessenger.of(dialogCtx).showSnackBar(
                            SnackBar(content: Text(l10n.callFailed)),
                          );
                        }
                      },
                    ),
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

              return ListenableBuilder(
                listenable: sl.isRegistered<SessionManager>()
                    ? sl<SessionManager>()
                    : AppRouter.authRefreshListenable,
                builder: (context, _) {
                  final isAuth = AppRouter.isAuthenticated;

                  return Scaffold(
                    // Premium gradient scaffold (Round 4); the body
                    // paints the decoration, so the scaffold is clear.
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      title: Text(l10n.propertyOverview),
                      actions: [
                        if (listing != null)
                          IconButton(
                            icon: const Icon(Icons.flag_outlined),
                            tooltip: l10n.reportListing,
                            onPressed: () async {
                              final authed = await _ensureAuthenticated();
                              if (!authed) {
                                if (context.mounted) context.push('/login');
                              } else {
                                if (context.mounted) {
                                  ReportBottomSheet.show(context, listingId: listing.id);
                                }
                              }
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          tooltip: l10n.shareListing,
                          onPressed: listing == null
                              ? null
                              : () {
                                  final target = listing.slug.isNotEmpty
                                      ? listing.slug
                                      : listing.id;
                                  SharePlus.instance.share(
                                    ShareParams(
                                      text: '${listing.title}\nhttps://ghorbd.com/listings/$target',
                                      subject: listing.title,
                                    ),
                                  );
                                },
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          tooltip: l10n.addToFavorites,
                          onPressed: () async {
                            final authed = await _ensureAuthenticated();
                            if (!authed) {
                              if (context.mounted) context.push('/login');
                            } else if (listing != null && context.mounted) {
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
                body: Container(
                  // Premium gradient scaffold (Round 4) + a state
                  // crossfade (loading → content no longer hard-cuts).
                  decoration: AppColors.scaffoldDecoration(isDark),
                  child: CrossfadeSwitcher(
                    child: KeyedSubtree(
                      key: ValueKey(state.runtimeType.toString()),
                      child: Builder(
                        builder: (context) {
                    if (state is ListingDetailLoading) {
                      return const AppLoadingView();
                    }

                    if (state is ListingDetailError) {
                      return AppErrorView(
                        message: state.message,
                        onRetry: () => context
                            .read<ListingDetailBloc>()
                            .add(ListingDetailFetch(widget.idOrSlug, fallbackId: widget.fallbackId)),
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
                          // 1. Photo Gallery Carousel (Round 4: the
                          // gallery and the price/title block below it
                          // enter with the shared motion system)
                          FadeSlideIn(child: _buildGallery(listing, isDark)),
                          const SizedBox(height: AppSpacing.md),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Price & Purpose Badge (wraps instead of
                                // overflowing on narrow screens / large text)
                                Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            formattedPrice,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? AppColors.accentMint
                                                  : AppColors.priceTag,
                                            ),
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
                                          AppFormatters.formatNumber(
                                            listing.viewCount,
                                            isBangla:
                                                l10n.localeName == 'bn',
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
                                const SizedBox(height: AppSpacing.md),

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
                                const SizedBox(height: AppSpacing.md),

                                // Key Property Attributes Grid
                                _buildSpecsGrid(listing, l10n, isDark),
                                const SizedBox(height: AppSpacing.md),

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
                                  const SizedBox(height: AppSpacing.md),
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
                                  const SizedBox(height: AppSpacing.md),
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
                                  onPressed: () async {
                                    final authed = await _ensureAuthenticated();
                                    if (!authed) {
                                      if (context.mounted) context.push('/login');
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content:
                                                Text(l10n.reportListingHint),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),

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
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final columns =
                                          AppSpacing.listingColumns(
                                        constraints.maxWidth,
                                      );
                                      if (columns == 1) {
                                        return Column(
                                          children: state.similar
                                              .asMap()
                                              .entries
                                              .map(
                                                (entry) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: AppSpacing.md,
                                                  ),
                                                  child:
                                                      FadeSlideIn.staggered(
                                                    index: entry.key,
                                                    child: PressScale(
                                                      child: ListingCard(
                                                        listing: entry.value,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        );
                                      }
                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: columns,
                                          crossAxisSpacing: AppSpacing.md,
                                          mainAxisSpacing: AppSpacing.md,
                                          mainAxisExtent: 430,
                                        ),
                                        itemCount: state.similar.length,
                                        itemBuilder: (context, index) =>
                                            FadeSlideIn.staggered(
                                          index: index,
                                          child: PressScale(
                                            child: ListingCard(
                                              listing: state.similar[index],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
                              label: isAuth
                                  ? l10n.callOwner
                                  : l10n.loginToViewPhone,
                              icon: Icons.phone,
                              onPressed: () async {
                                final authed = await _ensureAuthenticated();
                                if (!authed) {
                                  if (context.mounted) context.push('/login');
                                } else {
                                  if (context.mounted) {
                                    context
                                        .read<ContactBloc>()
                                        .add(RevealContactPhone(listing.id));
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: isAuth
                                  ? l10n.sendMessage
                                  : l10n.loginToSendMessage,
                              icon: Icons.chat_bubble_outline,
                              variant: AppButtonVariant.outline,
                              onPressed: () async {
                                final authed = await _ensureAuthenticated();
                                if (!authed) {
                                  if (context.mounted) context.push('/login');
                                } else {
                                  if (context.mounted) {
                                    InquiryBottomSheet.show(
                                      context,
                                      listingId: listing.id,
                                    );
                                  }
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
                    ),
                  ),
                ),
              );
            },
          );
        },
          );
        },
      ),
    );
  }

  Widget _buildGallery(ListingEntity listing, bool isDark) {
    if (listing.images.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: isDark ? AppColors.surfaceDark : Colors.grey[200],
          child: const Center(
            child: Icon(Icons.home_outlined, size: 64, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            itemCount: listing.images.length,
            onPageChanged: (index) => setState(() => _activeImageIndex = index),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: listing.images[index],
                fit: BoxFit.cover,
                // Round 4: fade photos in and decode near display
                // size (16:9 hero, capped at 1080px wide).
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 120),
                memCacheWidth: 1080,
                errorWidget: (_, __, ___) => Container(
                  color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
                placeholder: (_, __) => Container(
                  color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.home_outlined, size: 48, color: Colors.grey),
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
              listing.images.length > 10 ? 10 : listing.images.length,
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
        l10n.bedroomsCount(AppFormatters.formatNumber(listing.bed, isBangla: l10n.localeName == 'bn')),
      ));
    }
    if (listing.bath > 0) {
      specs.add((
        Icons.bathtub_outlined,
        l10n.bathrooms,
        l10n.bathroomsCount(AppFormatters.formatNumber(listing.bath, isBangla: l10n.localeName == 'bn')),
      ));
    }
    if (listing.size > 0) {
      specs.add((
        Icons.square_foot_outlined,
        l10n.sizeLabel,
        l10n.sizeSqft(AppFormatters.formatNumber(listing.size, isBangla: l10n.localeName == 'bn')),
      ));
    }
    if (listing.floor != null) {
      specs.add((
        Icons.stairs_outlined,
        l10n.floorNumber,
        AppFormatters.formatNumber(listing.floor!, isBangla: l10n.localeName == 'bn'),
      ));
    }
    if (listing.landAreaValue != null) {
      specs.add((
        Icons.landscape_outlined,
        l10n.landArea,
        '${AppFormatters.toBanglaDigits(listing.landAreaValue!)} ${listing.landAreaUnit ?? ""}'.trim(),
      ));
    }
    if (listing.landType != null && listing.landType!.isNotEmpty) {
      specs.add((
        Icons.category_outlined,
        l10n.landType,
        listing.landType!,
      ));
    }
    if (listing.landRoadWidthFt != null) {
      specs.add((
        Icons.add_road_outlined,
        l10n.landRoadWidth,
        l10n.landRoadWidthFt(AppFormatters.toBanglaDigits(listing.landRoadWidthFt!)),
      ));
    }
    if (listing.landFacing != null && listing.landFacing!.isNotEmpty) {
      specs.add((
        Icons.explore_outlined,
        l10n.landFacing,
        listing.landFacing!,
      ));
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    // Round 4 smoothness: the specs are a small bounded set (≤ 8), so
    // they render as a Wrap of fixed-width cells instead of a nested
    // shrink-wrapped GridView inside the scroll view.
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = AppSpacing.specColumns(constraints.maxWidth);
          final cellWidth =
              (constraints.maxWidth - AppSpacing.md * (columns - 1)) / columns;
          return Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (icon, title, value) in specs)
                SizedBox(
                  width: cellWidth,
                  height: 56,
                  child: Row(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
                ),
            ],
          );
        }
      ),
    );
  }
}
