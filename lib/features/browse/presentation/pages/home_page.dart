import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../core/config/app_preferences.dart';
import '../../../../core/security/session_manager.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/app_motion.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_bar.dart';
import '../../../../shared/widgets/listing_skeleton.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../domain/entities/listing_entity.dart';
import '../bloc/home_bloc.dart';
import '../widgets/listing_card.dart';
import '../widgets/search_bar_widget.dart';

/// Home screen implementation.
/// Traceability: SCR-001, REQ-001–006, 040, 044, 045, API-022, API-048.
///
/// Content curation (V2): Home stays light and app-appropriate — search,
/// categories, popular areas/divisions, featured, for-sale and rent
/// listings only. Blog / FAQ / testimonials / long marketing footers live
/// on their own content pages, not here.
///
/// Round 3: the page is a [CustomScrollView] — a floating/snapping
/// [SliverAppBar], the search bar as a floating sliver header, and the
/// listing sections as lazy slivers (no shrink-wrapped grids). Sections
/// and cards enter with the shared [FadeSlideIn] stagger, cards use
/// [PressScale] press feedback, and the header shows the user's real
/// profile photo ([UserAvatar]) when logged in.
///
/// Responsive (V2): content is centred with a max width on tablets, the
/// category grid is 4/6 columns, featured listings use a horizontal rail
/// on phones and a grid on tablets, and rent/sale listings use the
/// shared 1→2→3-column listing layout.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  // Header identity for the profile avatar (Round 3). Loaded once from
  // the session / profile API; purely decorative — any failure leaves
  // the guest/login affordance in place and never breaks Home.
  bool _isAuthenticated = false;
  String? _userName;
  String? _userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadHeaderUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHeaderUser() async {
    try {
      if (!sl.isRegistered<SessionManager>()) return;
      final session = sl<SessionManager>();
      if (session.currentStatus != SessionStatus.authenticated) return;
      if (mounted) setState(() => _isAuthenticated = true);

      final name = await session.getUserName();
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _userName = name);
      }

      if (sl.isRegistered<GetCurrentUserUseCase>()) {
        final result = await sl<GetCurrentUserUseCase>()();
        result.fold(
          (_) {},
          (user) {
            if (mounted && user != null) {
              setState(() {
                _userName = user.name;
                _userPhotoUrl = user.profilePhotoUrl;
              });
            }
          },
        );
      }
    } catch (_) {
      // Header avatar is best-effort only.
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.push('/listings?search=${Uri.encodeComponent(query.trim())}');
    }
  }

  /// App-bar actions shared by the sliver app bar (all states).
  List<Widget> _appBarActions(BuildContext context, AppLocalizations l10n) {
    return [
      // Quick Language Toggle (REQ-041)
      TextButton(
        onPressed: () {
          if (sl.isRegistered<AppPreferencesService>()) {
            sl<AppPreferencesService>().toggleLanguage();
          }
        },
        child: Text(
          l10n.localeName == 'bn' ? 'EN' : 'বাং',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      IconButton(
        icon: const Icon(Icons.favorite_border),
        tooltip: l10n.navFavorites,
        onPressed: () => context.push('/favorites'),
      ),
      // Profile: real photo / initial avatar when logged in, a login
      // icon for guests (Round 3).
      if (_isAuthenticated)
        IconButton(
          tooltip: l10n.navProfile,
          onPressed: () => context.push('/profile'),
          icon: UserAvatar(
            isGuest: false,
            name: _userName,
            photoUrl: _userPhotoUrl,
            radius: 16,
          ),
        )
      else
        IconButton(
          icon: const Icon(Icons.login_rounded),
          tooltip: l10n.authLogin,
          onPressed: () => context.push('/login'),
        ),
    ];
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return SliverAppBar(
      floating: true,
      snap: true,
      pinned: false,
      // Round 4 premium: glassy translucent bar (backdrop blur) over
      // the scrolling content instead of a flat strip.
      backgroundColor: Colors.transparent,
      flexibleSpace: const GlassBarBackground(),
      title: Text(
        l10n.appName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: _appBarActions(context, l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeFetchData()),
      child: Scaffold(
        // The premium scaffold decoration (dark gradient / light flat)
        // is painted by the body wrapper below.
        backgroundColor: Colors.transparent,
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                break;
              case 1:
                context.push('/listings');
                break;
              case 2:
                context.push('/map');
                break;
              case 3:
                context.push('/favorites');
                break;
              case 4:
                context.push('/profile');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.list_alt_outlined),
              selectedIcon: const Icon(Icons.list_alt),
              label: l10n.navListings,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map),
              label: l10n.navMap,
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_border),
              selectedIcon: const Icon(Icons.favorite),
              label: l10n.navFavorites,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
        body: Container(
          decoration: AppColors.scaffoldDecoration(isDark),
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    // Round 4: skeleton / error / content crossfade
                    // instead of hard cuts between states.
                    final Widget view;
                    final String viewKey;
                    if (state is HomeLoading) {
                      viewKey = 'home-loading';
                      view = CustomScrollView(
                        slivers: [
                          _buildSliverAppBar(context, l10n),
                          const SliverFillRemaining(
                            hasScrollBody: true,
                            child: HomeSkeletonView(),
                          ),
                        ],
                      );
                    } else if (state is HomeError) {
                      viewKey = 'home-error';
                      view = CustomScrollView(
                        slivers: [
                          _buildSliverAppBar(context, l10n),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: AppErrorView(
                              message: state.message,
                              onRetry: () => context
                                  .read<HomeBloc>()
                                  .add(const HomeFetchData()),
                            ),
                          ),
                        ],
                      );
                    } else if (state is HomeLoaded) {
                      viewKey = 'home-loaded';
                      view = _buildLoaded(context, l10n, state);
                    } else {
                      viewKey = 'home-empty';
                      view = const SizedBox.shrink();
                    }
                    return CrossfadeSwitcher(
                      child: KeyedSubtree(key: ValueKey(viewKey), child: view),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    AppLocalizations l10n,
    HomeLoaded state,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // De-duplicate across sections: a listing shown as featured must
    // not reappear in the rent/sale sections below it.
    final featuredIds = state.featuredListings.map((e) => e.id).toSet();
    final rentListings = state.recentRentListings
        .where((e) => !featuredIds.contains(e.id))
        .toList();
    final saleListings = state.recentSaleListings
        .where((e) => !featuredIds.contains(e.id))
        .where((e) => !rentListings.any((r) => r.id == e.id))
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeFetchData());
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Page padding + centring inset for the max content width.
          final sidePad = AppSpacing.pagePadding(width) +
              math.max(0.0, (width - AppSpacing.contentMaxWidth) / 2);
          final textScale =
              MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
          final searchExtent =
              AppSpacing.inputHeight + AppSpacing.sm * 2 + (textScale - 1) * 24;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, l10n),

              // 1. Hero greeting strip (search lives in the floating
              // sliver header right below so it can reappear on
              // scroll-up).
              SliverToBoxAdapter(
                child: FadeSlideIn(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      sidePad,
                      AppSpacing.md,
                      sidePad,
                      AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.primary.withAlpha(15),
                    ),
                    child: Text(
                      l10n.heroTitle,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.primaryDark,
                          ),
                    ),
                  ),
                ),
              ),

              // 2. Search — floating sliver header: hides on scroll
              // down, floats/snaps back on scroll up.
              SliverPersistentHeader(
                floating: true,
                delegate: _SearchHeaderDelegate(
                  extent: searchExtent,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      sidePad,
                      AppSpacing.sm,
                      sidePad,
                      AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.primary.withAlpha(15),
                    ),
                    child: SearchBarWidget(
                      controller: _searchController,
                      onSubmitted: _onSearch,
                      onFilterTap: () => context.push('/listings'),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.md),
              ),

              // 3. Property Type Categories (grid)
              SliverToBoxAdapter(
                child: FadeSlideIn.staggered(
                  index: 1,
                  child: _sectionHeader(
                    context,
                    l10n.filterPropertyType,
                    horizontalPadding: sidePad,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.sm),
              ),
              _buildCategorySliver(context, l10n, width, sidePad),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              // 4. Featured Listings
              if (state.featuredListings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: FadeSlideIn.staggered(
                    index: 2,
                    child: _sectionHeader(
                      context,
                      l10n.featuredListings,
                      horizontalPadding: sidePad,
                      onSeeAll: () =>
                          context.push('/listings?featured=true'),
                      seeAllLabel: l10n.all,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),
                _buildFeaturedSliver(
                  context,
                  state.featuredListings,
                  width,
                  sidePad,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],

              // 5. Popular Areas / Divisions
              if (state.popularAreas.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: FadeSlideIn.staggered(
                    index: 3,
                    child: _sectionHeader(
                      context,
                      l10n.popularAreas,
                      horizontalPadding: sidePad,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.sm),
                ),
                SliverToBoxAdapter(
                  child: FadeSlideIn.staggered(
                    index: 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePad),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: state.popularAreas
                            .map(
                              (area) => ActionChip(
                                label: Text(area.name),
                                onPressed: () => context.push(
                                  '/listings?area=${area.slug}',
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],

              // 6. For-Sale Listings
              if (saleListings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _sectionHeader(
                    context,
                    l10n.recentSaleListings,
                    horizontalPadding: sidePad,
                    onSeeAll: () => context.push('/listings?purpose=sale'),
                    seeAllLabel: l10n.all,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),
                _buildListingSliver(context, saleListings, width, sidePad),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],

              // 7. Recent Rent Listings
              if (rentListings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _sectionHeader(
                    context,
                    l10n.recentRentListings,
                    horizontalPadding: sidePad,
                    onSeeAll: () => context.push('/listings?purpose=rent'),
                    seeAllLabel: l10n.all,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xs),
                ),
                _buildListingSliver(context, rentListings, width, sidePad),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xl),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    required double horizontalPadding,
    VoidCallback? onSeeAll,
    String? seeAllLabel,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          // Round 4 premium section header: a short emerald gradient
          // accent bar before the title.
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.ctaGradient,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(seeAllLabel ?? ''),
            ),
        ],
      ),
    );
  }

  /// Featured listings as a sliver (Round 4): horizontal rail on
  /// phones (fast, swipeable), a lazy [SliverGrid] on tablets — the
  /// Round 3 shrink-wrapped GridView is gone, so the page has exactly
  /// one scroll owner and items build lazily.
  Widget _buildFeaturedSliver(
    BuildContext context,
    List<ListingEntity> listings,
    double width,
    double sidePad,
  ) {
    if (width >= AppSpacing.tabletBreakpoint) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppSpacing.listingColumns(width),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            // Cards carry an image + price + 2-line title + specs; a
            // tall main-axis extent keeps them overflow-free at text
            // scale 2.0.
            mainAxisExtent: 430,
          ),
          itemCount: listings.length,
          itemBuilder: (context, index) => _animatedCard(listings[index], index),
        ),
      );
    }
    // Rail height grows with the user's text scale (capped) so card text
    // ellipsises inside the card instead of overflowing the rail.
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.5);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 400 * textScale,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: sidePad),
          scrollDirection: Axis.horizontal,
          itemCount: listings.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (context, index) {
            final cardWidth = (width * 0.78).clamp(240.0, 300.0).toDouble();
            return SizedBox(
              width: cardWidth,
              child: _animatedCard(listings[index], index),
            );
          },
        ),
      ),
    );
  }

  /// One listing card with the Round 4 treatment: scroll-triggered
  /// reveal, press feedback, and a [RepaintBoundary] so a card's
  /// entrance/press animations never repaint its neighbours.
  Widget _animatedCard(ListingEntity listing, int index) {
    return RepaintBoundary(
      child: ScrollReveal(
        index: index,
        child: PressScale(child: ListingCard(listing: listing)),
      ),
    );
  }

  /// Lazy listing section for the sale/rent blocks: a real
  /// [SliverList] on phones, [SliverGrid] on wider layouts — items are
  /// built as they scroll into view and enter with the shared stagger.
  Widget _buildListingSliver(
    BuildContext context,
    List<ListingEntity> listings,
    double width,
    double sidePad,
  ) {
    final columns = AppSpacing.listingColumns(width);
    if (columns == 1) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        sliver: SliverList.separated(
          itemCount: listings.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) =>
              _animatedCard(listings[index], index),
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sidePad),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          mainAxisExtent: 430,
        ),
        itemCount: listings.length,
        itemBuilder: (context, index) =>
            _animatedCard(listings[index], index),
      ),
    );
  }

  /// Category tiles as a lazy [SliverGrid] (Round 4 — the Round 3
  /// shrink-wrapped GridView inside the scroll view is gone). Tiles
  /// pop in with a scale stagger and carry the premium emerald→mint
  /// gradient tint on their icon circles.
  Widget _buildCategorySliver(
    BuildContext context,
    AppLocalizations l10n,
    double width,
    double sidePad,
  ) {
    // Mirrors ghorbd.com's category set/order. 'hotel' is a real backend
    // type (added Round 3); 'sublet' is NOT a backend type yet (the API
    // rejects it with a 422), so it is deliberately absent.
    final categories = [
      (Icons.apartment, l10n.apartment, 'apartment'),
      (Icons.home, l10n.house, 'house'),
      (Icons.bed_outlined, l10n.room, 'room'),
      (Icons.hotel, l10n.hotel, 'hotel'),
      (Icons.storefront, l10n.shop, 'shop'),
      (Icons.business, l10n.office, 'office'),
      (Icons.terrain, l10n.land, 'land'),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sidePad),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppSpacing.categoryColumns(width),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          // Round 3 density: 92 → 74 (smaller icon circle + tighter label).
          mainAxisExtent: 74,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final (icon, label, type) = categories[index];
          return FadeSlideIn.staggered(
            index: index,
            duration: AppMotion.medium,
            scaleFrom: 0.9,
            child: PressScale(
              child: InkWell(
                onTap: () {
                  if (type == 'land') {
                    context.push('/land');
                  } else {
                    context.push('/listings?type=$type');
                  }
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Premium gradient-tinted icon tile: a soft emerald
                    // wash disc with a gradient ring on dark, a light
                    // emerald tint on light.
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.primary.withAlpha(31)
                            : AppColors.primary.withAlpha(22),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryLight.withAlpha(90)
                              : AppColors.primary.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Fixed-height delegate for the floating search header on Home.
/// The header hides on scroll down and floats/snaps back on scroll up.
class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  _SearchHeaderDelegate({required this.child, required this.extent});

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
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) {
    return oldDelegate.extent != extent || oldDelegate.child != child;
  }
}
