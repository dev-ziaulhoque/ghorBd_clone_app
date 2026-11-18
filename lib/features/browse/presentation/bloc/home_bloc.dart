import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/cache/response_cache.dart';
import '../../data/repositories/browse_repository_impl.dart';
import '../../domain/entities/area_entity.dart';
import '../../domain/entities/facets_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/usecases/get_areas_usecase.dart';
import '../../domain/usecases/get_listings_usecase.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeFetchData extends HomeEvent {
  const HomeFetchData();
}

/// Internal event: fresh areas arrived via the response cache's
/// background revalidation (stale-while-revalidate) and should patch
/// the currently displayed [HomeLoaded] state.
class HomeAreasRefreshed extends HomeEvent {
  final List<AreaEntity> areas;

  const HomeAreasRefreshed(this.areas);

  @override
  List<Object?> get props => [areas];
}

// States
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ListingEntity> featuredListings;
  final List<AreaEntity> popularAreas;
  final List<ListingEntity> recentRentListings;

  /// Recent for-sale listings (Home "for sale" section). Optional so
  /// existing constructions of [HomeLoaded] keep working.
  final List<ListingEntity> recentSaleListings;

  const HomeLoaded({
    required this.featuredListings,
    required this.popularAreas,
    required this.recentRentListings,
    this.recentSaleListings = const [],
  });

  HomeLoaded copyWith({
    List<ListingEntity>? featuredListings,
    List<AreaEntity>? popularAreas,
    List<ListingEntity>? recentRentListings,
    List<ListingEntity>? recentSaleListings,
  }) {
    return HomeLoaded(
      featuredListings: featuredListings ?? this.featuredListings,
      popularAreas: popularAreas ?? this.popularAreas,
      recentRentListings: recentRentListings ?? this.recentRentListings,
      recentSaleListings: recentSaleListings ?? this.recentSaleListings,
    );
  }

  @override
  List<Object?> get props => [
        featuredListings,
        popularAreas,
        recentRentListings,
        recentSaleListings,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetListingsUseCase _getListingsUseCase;
  final GetAreasUseCase _getAreasUseCase;

  /// Optional response cache (Round 2 SWR): when the repository's
  /// background revalidation writes fresh areas into the cache, the bloc
  /// re-emits [HomeLoaded] with the fresh areas so the UI updates in
  /// place. Null in existing tests → listener inactive.
  final ResponseCache? _cache;
  bool _updatingFromCache = false;

  HomeBloc({
    required GetListingsUseCase getListingsUseCase,
    required GetAreasUseCase getAreasUseCase,
    ResponseCache? cache,
  })  : _getListingsUseCase = getListingsUseCase,
        _getAreasUseCase = getAreasUseCase,
        _cache = cache,
        super(HomeInitial()) {
    on<HomeFetchData>(_onFetchData);
    on<HomeAreasRefreshed>(_onAreasRefreshed);
    _cache?.addListener(_onCacheChanged);
  }

  @override
  Future<void> close() {
    _cache?.removeListener(_onCacheChanged);
    return super.close();
  }

  void _onAreasRefreshed(
    HomeAreasRefreshed event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is HomeLoaded && event.areas.isNotEmpty) {
      emit(current.copyWith(popularAreas: event.areas));
    }
  }

  /// SWR hook: fresh areas landed in the cache (background revalidation
  /// finished). Re-read them (served from the now-fresh cache, no
  /// network) and route them through a normal bloc event.
  void _onCacheChanged() {
    unawaited(_refreshAreasFromCache());
  }

  Future<void> _refreshAreasFromCache() async {
    final cache = _cache;
    if (cache == null || isClosed || _updatingFromCache) return;
    if (cache.lastChangedKey !=
        BrowseRepositoryImpl.areasCacheKey(popular: true)) {
      return;
    }
    if (state is! HomeLoaded) return;
    _updatingFromCache = true;
    try {
      final result = await _getAreasUseCase(popular: true);
      if (isClosed) return;
      result.fold(
        (_) {},
        (areas) {
          if (areas.isNotEmpty) add(HomeAreasRefreshed(areas));
        },
      );
    } finally {
      _updatingFromCache = false;
    }
  }

  Future<void> _onFetchData(
    HomeFetchData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    // Round 2: all four section loads run in PARALLEL — total wait is
    // one backend round-trip (~1.2–1.9 s), not the sum of four
    // sequential ones. Categories are a local constant in HomePage, so
    // they need no fetch. (Record `.wait` from Dart 3.)
    final (featuredResult, areasResult, recentResult, saleResult) = await (
      _getListingsUseCase(
        const ListingFilterParams(featured: true, perPage: 6),
      ),
      _getAreasUseCase(popular: true),
      _getListingsUseCase(
        const ListingFilterParams(purpose: 'rent', sort: 'newest', perPage: 6),
      ),
      // Failure of the sale section must not fail Home: the section is
      // simply hidden when empty (handled in the fold below).
      _getListingsUseCase(
        const ListingFilterParams(purpose: 'sale', sort: 'newest', perPage: 6),
      ),
    ).wait;

    featuredResult.fold(
      (failure) => emit(HomeError(message: failure.messageKey)),
      (featuredData) {
        final popularAreas = areasResult.fold(
          (_) => <AreaEntity>[],
          (areas) => areas,
        );
        final recentListings = recentResult.fold(
          (_) => featuredData.listings,
          (recentData) => recentData.listings,
        );
        final saleListings = saleResult.fold(
          (_) => <ListingEntity>[],
          (saleData) => saleData.listings,
        );

        emit(
          HomeLoaded(
            featuredListings: featuredData.listings,
            popularAreas: popularAreas,
            recentRentListings: recentListings,
            recentSaleListings: saleListings,
          ),
        );
      },
    );
  }
}
