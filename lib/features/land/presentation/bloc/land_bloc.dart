import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../browse/domain/entities/facets_entity.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../domain/usecases/get_land_listings_usecase.dart';

// Events
abstract class LandEvent extends Equatable {
  const LandEvent();
  @override
  List<Object?> get props => [];
}

class FetchLandListingsEvent extends LandEvent {
  final ListingFilterParams? params;
  const FetchLandListingsEvent({this.params});

  @override
  List<Object?> get props => [params];
}

class FilterLandTypeEvent extends LandEvent {
  final String? landType;
  const FilterLandTypeEvent(this.landType);

  @override
  List<Object?> get props => [landType];
}

// States
abstract class LandState extends Equatable {
  const LandState();
  @override
  List<Object?> get props => [];
}

class LandInitial extends LandState {
  const LandInitial();
}

class LandLoading extends LandState {
  const LandLoading();
}

class LandLoaded extends LandState {
  final List<ListingEntity> listings;
  final int total;
  final ListingFilterParams currentParams;

  const LandLoaded({
    required this.listings,
    required this.total,
    required this.currentParams,
  });

  @override
  List<Object?> get props => [listings, total, currentParams];
}

class LandError extends LandState {
  final String messageKey;
  const LandError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

// Bloc
class LandBloc extends Bloc<LandEvent, LandState> {
  final GetLandListingsUseCase getLandListingsUseCase;

  LandBloc({required this.getLandListingsUseCase}) : super(const LandInitial()) {
    on<FetchLandListingsEvent>(_onFetchLandListings);
    on<FilterLandTypeEvent>(_onFilterLandType);
  }

  Future<void> _onFetchLandListings(
    FetchLandListingsEvent event,
    Emitter<LandState> emit,
  ) async {
    emit(const LandLoading());
    final params = (event.params ?? const ListingFilterParams()).copyWith(
      propertyType: 'land',
    );
    final result = await getLandListingsUseCase(params);
    result.fold(
      (failure) => emit(LandError(failure.messageKey)),
      (data) => emit(LandLoaded(
        listings: data.listings,
        total: data.total,
        currentParams: params,
      )),
    );
  }

  Future<void> _onFilterLandType(
    FilterLandTypeEvent event,
    Emitter<LandState> emit,
  ) async {
    final currentParams = state is LandLoaded
        ? (state as LandLoaded).currentParams
        : const ListingFilterParams();

    final newParams = currentParams.copyWith(
      propertyType: 'land',
      search: event.landType,
    );

    add(FetchLandListingsEvent(params: newParams));
  }
}
