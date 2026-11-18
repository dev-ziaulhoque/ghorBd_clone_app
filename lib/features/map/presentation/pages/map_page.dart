import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../../browse/presentation/widgets/filter_bottom_sheet.dart';
import '../../domain/entities/place_entity.dart';
import '../bloc/map_bloc.dart';
import '../utils/dhaka_coordinates.dart';
import '../widgets/dhaka_map_painter.dart';
import '../widgets/map_bottom_preview_card.dart';
import '../widgets/map_controls_overlay.dart';
import '../widgets/map_pin_marker.dart';

class MapPage extends StatefulWidget {
  final ListingFilterParams? initialParams;
  const MapPage({super.key, this.initialParams});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late final MapBloc _mapBloc;
  final _searchController = TextEditingController();
  final _transformationController = TransformationController();
  final _mapViewportKey = GlobalKey();

  late final AnimationController _animationController;
  Animation<Matrix4>? _matrixAnimation;

  MapThemeStyle _currentStyle = MapThemeStyle.modern;
  String _selectedAreaSlug = 'all';
  String _selectedMarketPurpose = 'all';
  bool _isCardDismissed = false;
  bool _hasInitialCentered = false;
  bool _isIconOnlyMode = false;

  @override
  void initState() {
    super.initState();
    _mapBloc = sl<MapBloc>()
      ..add(LoadMapDataEvent(params: widget.initialParams));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() {
        if (_matrixAnimation != null) {
          _transformationController.value = _matrixAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    _mapBloc.close();
    super.dispose();
  }

  void _openFilters(BuildContext context, ListingFilterParams currentParams) {
    FilterBottomSheet.show(
      context: context,
      currentParams: currentParams,
      onApply: (newParams) {
        _mapBloc.add(LoadMapDataEvent(params: newParams));
      },
    );
  }

  void _animateCameraTo(Offset target, {double zoom = 1.25}) {
    final current = _transformationController.value;
    final RenderBox? box =
        _mapViewportKey.currentContext?.findRenderObject() as RenderBox?;
    final viewportSize = box?.size ?? const Size(400, 700);

    // Visible height adjusted if bottom card is active
    final double visibleHeight =
        (!_isCardDismissed) ? (viewportSize.height - 180) : viewportSize.height;

    final double tx = (viewportSize.width / 2) - (target.dx * zoom);
    final double ty = (visibleHeight / 2) - (target.dy * zoom);

    final targetMatrix = Matrix4.diagonal3Values(zoom, zoom, 1.0)
      ..setTranslationRaw(tx, ty, 0.0);

    _matrixAnimation = Matrix4Tween(begin: current, end: targetMatrix).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );

    _animationController.forward(from: 0.0);
  }

  void _zoomBy(double factor) {
    final current = _transformationController.value;
    final RenderBox? box =
        _mapViewportKey.currentContext?.findRenderObject() as RenderBox?;
    final viewportSize = box?.size ?? const Size(400, 700);

    final currentScale = current.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.55, 3.5);

    final double cx = viewportSize.width / 2;
    final double cy = viewportSize.height / 2;

    final double tx = current.storage[12];
    final double ty = current.storage[13];

    final double canvasX = (cx - tx) / currentScale;
    final double canvasY = (cy - ty) / currentScale;

    final double newTx = cx - (canvasX * newScale);
    final double newTy = cy - (canvasY * newScale);

    final targetMatrix = Matrix4.diagonal3Values(newScale, newScale, 1.0)
      ..setTranslationRaw(newTx, newTy, 0.0);

    _matrixAnimation = Matrix4Tween(begin: current, end: targetMatrix).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward(from: 0.0);
  }

  void _recenterToDhaka() {
    _animateCameraTo(
      DhakaCoordinates.project(23.7800, 90.4000),
      zoom: 0.95,
    );
    setState(() => _selectedAreaSlug = 'all');
  }

  void _toggleMapStyle() {
    setState(() {
      switch (_currentStyle) {
        case MapThemeStyle.modern:
          _currentStyle = MapThemeStyle.satelliteNight;
          break;
        case MapThemeStyle.satelliteNight:
          _currentStyle = MapThemeStyle.blueprint;
          break;
        case MapThemeStyle.blueprint:
          _currentStyle = MapThemeStyle.modern;
          break;
      }
    });
  }

  void _onAreaChipSelected(MapAreaChip chip, MapLoaded state) {
    setState(() {
      _selectedAreaSlug = chip.slug;
      _isCardDismissed = false;
    });

    final targetOffset = DhakaCoordinates.project(chip.lat, chip.lng);
    _animateCameraTo(targetOffset, zoom: chip.zoom);

    if (chip.slug != 'all') {
      // Find matching listing in that area if any
      final match = state.listings.where((l) {
        final area = l.areaSlug.toLowerCase();
        return area.contains(chip.slug) || chip.slug.contains(area);
      }).firstOrNull;

      if (match != null) {
        _mapBloc.add(SelectListingPinEvent(match));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _mapBloc,
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
        body: BlocConsumer<MapBloc, MapState>(
          listener: (context, state) {
            if (state is MapLoaded && !_hasInitialCentered) {
              _hasInitialCentered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (state.selectedPlace != null) {
                  _animateCameraTo(
                    DhakaCoordinates.project(
                      state.selectedPlace!.lat,
                      state.selectedPlace!.lng,
                    ),
                    zoom: 1.35,
                  );
                } else if (state.listings.isNotEmpty) {
                  final firstListing = state.listings.first;
                  final (lat, lng) =
                      DhakaCoordinates.getLatLngForArea(firstListing.areaSlug);
                  _animateCameraTo(
                    DhakaCoordinates.project(lat, lng),
                    zoom: 1.15,
                  );
                } else {
                  _recenterToDhaka();
                }
              });
            }
          },
          builder: (context, state) {
            if (state is MapLoading) {
              return const AppLoadingView();
            }

            if (state is MapError) {
              return AppErrorView(
                message: state.messageKey,
                onRetry: () => _mapBloc.add(const LoadMapDataEvent()),
              );
            }

            if (state is MapLoaded) {
              if (state.listings.isEmpty) {
                return AppEmptyView(
                  icon: Icons.map_outlined,
                  title: l10n.noLocationListings,
                  message: l10n.noMapLocationNotice,
                );
              }

              return Stack(
                key: _mapViewportKey,
                children: [
                  // 1. Vector Map Canvas & Interactive Pins
                  _buildInteractiveMap(context, state, isDark),

                  // 2. Top Bar: Search Autocomplete & Quick Area Chips Carousel
                  Positioned(
                    top: 10,
                    left: 14,
                    right: 14,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSearchField(context, state, isDark, l10n),
                        const SizedBox(height: 6),
                        _buildMarketFilterRow(isDark, l10n),
                        const SizedBox(height: 6),
                        _buildAreaChipsCarousel(state, isDark, l10n),
                      ],
                    ),
                  ),

                  // 3. Floating Map Controls (Zoom / Recenter / Style)
                  Positioned(
                    right: 14,
                    bottom: (state.selectedListing != null && !_isCardDismissed)
                        ? 220
                        : 84,
                    child: MapControlsOverlay(
                      currentStyle: _currentStyle,
                      onZoomIn: () => _zoomBy(1.3),
                      onZoomOut: () => _zoomBy(0.77),
                      onRecenter: _recenterToDhaka,
                      onToggleStyle: _toggleMapStyle,
                      onToggleMarkerMode: () => setState(() => _isIconOnlyMode = !_isIconOnlyMode),
                      isIconOnlyMode: _isIconOnlyMode,
                    ),
                  ),

                  // 4. Floating "View List" Switcher Button
                  Positioned(
                    bottom: (state.selectedListing != null && !_isCardDismissed)
                        ? 196
                        : 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildViewListButton(context, isDark, l10n),
                    ),
                  ),

                  // 5. Selected Property Preview Card (Bottom)
                  if (state.selectedListing != null && !_isCardDismissed)
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: MapBottomPreviewCard(
                        listing: state.selectedListing!,
                        onClose: () {
                          setState(() => _isCardDismissed = true);
                        },
                        onTap: () {
                          final target = state.selectedListing!.slug.isNotEmpty
                              ? state.selectedListing!.slug
                              : state.selectedListing!.id;
                          context.push(
                            '/listings/$target?id=${state.selectedListing!.id}',
                          );
                        },
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

  Widget _buildInteractiveMap(
    BuildContext context,
    MapLoaded state,
    bool isDark,
  ) {
    // Filter listings by selected market purpose (all / rent / sale)
    final filteredListings = state.listings.where((l) {
      if (_selectedMarketPurpose == 'rent') return l.purpose == 'rent';
      if (_selectedMarketPurpose == 'sale') return l.purpose == 'sale';
      return true;
    }).toList();

    // Group listings by areaSlug to compute dispersion offsets
    final Map<String, List<ListingEntity>> areaGroups = {};
    for (final l in filteredListings) {
      final key = l.areaSlug.toLowerCase();
      areaGroups.putIfAbsent(key, () => []).add(l);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.55,
          maxScale: 3.5,
          boundaryMargin: const EdgeInsets.all(500),
          constrained: false,
          child: SizedBox(
            width: DhakaCoordinates.canvasWidth,
            height: DhakaCoordinates.canvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cartographic Vector Canvas
                RepaintBoundary(
                  child: CustomPaint(
                    size: DhakaCoordinates.canvasSize,
                    painter: DhakaMapPainter(
                      isDark: isDark,
                      style: _currentStyle,
                    ),
                  ),
                ),

                // Selected Place Pin (from Geo autocomplete)
                if (state.selectedPlace != null)
                  _buildSelectedPlaceMarker(state.selectedPlace!),

                // Custom Listing Price Pins
                ...filteredListings.map((listing) {
                  final group = areaGroups[listing.areaSlug.toLowerCase()] ?? [listing];
                  final indexInArea = group.indexOf(listing);
                  final totalInArea = group.length;

                  final offset = DhakaCoordinates.getListingOffset(
                    listing,
                    indexInArea,
                    totalInArea,
                  );

                  final isSelected = state.selectedListing?.id == listing.id;

                  return Positioned(
                    left: offset.dx,
                    top: offset.dy,
                    child: FractionalTranslation(
                      translation: const Offset(-0.5, -1.0),
                      child: MapPinMarker(
                        listing: listing,
                        isSelected: isSelected,
                        iconOnly: _isIconOnlyMode,
                        onTap: () {
                          setState(() => _isCardDismissed = false);
                          _mapBloc.add(SelectListingPinEvent(listing));
                          _animateCameraTo(offset, zoom: 1.35);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedPlaceMarker(PlaceEntity place) {
    final offset = DhakaCoordinates.project(place.lat, place.lng);
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                place.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(Icons.place, color: Colors.redAccent, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(
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
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            key: const Key('map_place_search_field'),
            controller: _searchController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: l10n.searchPlaceHint,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _mapBloc.add(const SearchPlacesEvent(''));
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
            onChanged: (query) {
              _mapBloc.add(SearchPlacesEvent(query));
            },
          ),
        ),
        if (state.placeSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            child: Material(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              elevation: 6,
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: state.placeSuggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final place = state.placeSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      place.label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      place.fullLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      _searchController.text = place.label;
                      _mapBloc.add(SelectPlaceEvent(place));
                      _animateCameraTo(
                        DhakaCoordinates.project(place.lat, place.lng),
                        zoom: 1.45,
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMarketFilterRow(bool isDark, AppLocalizations l10n) {
    return Row(
      children: [
        _buildMarketPill(
          label: l10n.allMarket,
          icon: Icons.domain,
          isSelected: _selectedMarketPurpose == 'all',
          onTap: () => setState(() => _selectedMarketPurpose = 'all'),
          isDark: isDark,
        ),
        const SizedBox(width: 6),
        _buildMarketPill(
          label: l10n.rentMarket,
          icon: Icons.key_rounded,
          isSelected: _selectedMarketPurpose == 'rent',
          onTap: () => setState(() => _selectedMarketPurpose = 'rent'),
          isDark: isDark,
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: 6),
        _buildMarketPill(
          label: l10n.saleMarket,
          icon: Icons.sell_rounded,
          isSelected: _selectedMarketPurpose == 'sale',
          onTap: () => setState(() => _selectedMarketPurpose = 'sale'),
          isDark: isDark,
          activeColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }

  Widget _buildMarketPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color activeColor = AppColors.primary,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.surfaceDark : Colors.white),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 50 : 15),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChipsCarousel(
    MapLoaded state,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DhakaCoordinates.popularChips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final chip = DhakaCoordinates.popularChips[index];
          final isSelected = _selectedAreaSlug == chip.slug;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              onTap: () => _onAreaChipSelected(chip, state),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceDark : Colors.white),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      chip.icon,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isBn ? chip.labelBn : chip.labelEn,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
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

  Widget _buildViewListButton(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: () => context.push('/listings'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.format_list_bulleted, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                l10n.viewList,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
