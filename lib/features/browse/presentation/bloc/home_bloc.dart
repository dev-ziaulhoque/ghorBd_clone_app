import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  const HomeLoaded({
    required this.featuredListings,
    required this.popularAreas,
    required this.recentRentListings,
  });

  @override
  List<Object?> get props => [
        featuredListings,
        popularAreas,
        recentRentListings,
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

  HomeBloc({
    required GetListingsUseCase getListingsUseCase,
    required GetAreasUseCase getAreasUseCase,
  })  : _getListingsUseCase = getListingsUseCase,
        _getAreasUseCase = getAreasUseCase,
        super(HomeInitial()) {
    on<HomeFetchData>(_onFetchData);
  }

  Future<void> _onFetchData(
    HomeFetchData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    // 1. Fetch featured listings
    final featuredResult = await _getListingsUseCase(
      const ListingFilterParams(featured: true, perPage: 6),
    );

    // 2. Fetch popular areas
    final areasResult = await _getAreasUseCase(popular: true);

    // 3. Fetch recent rent listings
    final recentResult = await _getListingsUseCase(
      const ListingFilterParams(purpose: 'rent', sort: 'newest', perPage: 6),
    );

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

        emit(
          HomeLoaded(
            featuredListings: featuredData.listings,
            popularAreas: popularAreas,
            recentRentListings: recentListings,
          ),
        );
      },
    );
  }
}
