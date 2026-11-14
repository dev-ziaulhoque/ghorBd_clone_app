import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../domain/entities/place_entity.dart';
import '../../domain/usecases/map_usecases.dart';

// Events
abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class LoadMapDataEvent extends MapEvent {
  final ListingFilterParams? params;
  const LoadMapDataEvent({this.params});

  @override
  List<Object?> get props => [params];
}

class SearchPlacesEvent extends MapEvent {
  final String query;
  const SearchPlacesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectPlaceEvent extends MapEvent {
  final PlaceEntity place;
  const SelectPlaceEvent(this.place);

  @override
  List<Object?> get props => [place];
}

class SelectListingPinEvent extends MapEvent {
  final ListingEntity? listing;
  const SelectListingPinEvent(this.listing);

  @override
  List<Object?> get props => [listing];
}

class ReverseGeocodePinEvent extends MapEvent {
  final double lat;
  final double lng;
  const ReverseGeocodePinEvent({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}

// States
abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final List<ListingEntity> listings;
  final ListingEntity? selectedListing;
  final List<PlaceEntity> placeSuggestions;
  final PlaceEntity? selectedPlace;
  final ListingFilterParams filterParams;

  const MapLoaded({
    required this.listings,
    this.selectedListing,
    this.placeSuggestions = const [],
    this.selectedPlace,
    this.filterParams = const ListingFilterParams(),
  });

  MapLoaded copyWith({
    List<ListingEntity>? listings,
    ListingEntity? selectedListing,
    List<PlaceEntity>? placeSuggestions,
    PlaceEntity? selectedPlace,
    ListingFilterParams? filterParams,
    bool clearSelectedListing = false,
  }) {
    return MapLoaded(
      listings: listings ?? this.listings,
      selectedListing: clearSelectedListing
          ? null
          : (selectedListing ?? this.selectedListing),
      placeSuggestions: placeSuggestions ?? this.placeSuggestions,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      filterParams: filterParams ?? this.filterParams,
    );
  }

  @override
  List<Object?> get props => [
        listings,
        selectedListing,
        placeSuggestions,
        selectedPlace,
        filterParams,
      ];
}

class MapError extends MapState {
  final String messageKey;
  const MapError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

// Bloc
class MapBloc extends Bloc<MapEvent, MapState> {
  final SearchPlacesUseCase searchPlacesUseCase;
  final ReverseGeocodeUseCase reverseGeocodeUseCase;
  final GetMapListingsUseCase getMapListingsUseCase;

  MapBloc({
    required this.searchPlacesUseCase,
    required this.reverseGeocodeUseCase,
    required this.getMapListingsUseCase,
  }) : super(const MapInitial()) {
    on<LoadMapDataEvent>(_onLoadMapData);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<SelectPlaceEvent>(_onSelectPlace);
    on<SelectListingPinEvent>(_onSelectListingPin);
    on<ReverseGeocodePinEvent>(_onReverseGeocodePin);
  }

  Future<void> _onLoadMapData(
    LoadMapDataEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    final params = event.params ?? const ListingFilterParams();
    final result = await getMapListingsUseCase(params);
    result.fold(
      (failure) => emit(MapError(failure.messageKey)),
      (listings) => emit(MapLoaded(
        listings: listings,
        selectedListing: listings.isNotEmpty ? listings.first : null,
        filterParams: params,
      )),
    );
  }

  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<MapState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      if (state is MapLoaded) {
        emit((state as MapLoaded).copyWith(placeSuggestions: []));
      }
      return;
    }

    final result = await searchPlacesUseCase(event.query.trim());
    result.fold(
      (_) {},
      (places) {
        if (state is MapLoaded) {
          emit((state as MapLoaded).copyWith(placeSuggestions: places));
        }
      },
    );
  }

  Future<void> _onSelectPlace(
    SelectPlaceEvent event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoaded) {
      final currentState = state as MapLoaded;
      emit(currentState.copyWith(
        selectedPlace: event.place,
        placeSuggestions: [],
      ));
    }
  }

  void _onSelectListingPin(
    SelectListingPinEvent event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoaded) {
      emit((state as MapLoaded).copyWith(selectedListing: event.listing));
    }
  }

  Future<void> _onReverseGeocodePin(
    ReverseGeocodePinEvent event,
    Emitter<MapState> emit,
  ) async {
    final result = await reverseGeocodeUseCase(event.lat, event.lng);
    result.fold(
      (_) {},
      (place) {
        if (place != null && state is MapLoaded) {
          emit((state as MapLoaded).copyWith(selectedPlace: place));
        }
      },
    );
  }
}
