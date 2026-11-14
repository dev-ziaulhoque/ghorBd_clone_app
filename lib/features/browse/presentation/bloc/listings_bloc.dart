import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/facets_entity.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/usecases/search_listings_usecase.dart';

// Events
abstract class ListingsEvent extends Equatable {
  const ListingsEvent();

  @override
  List<Object?> get props => [];
}

class ListingsFilterChanged extends ListingsEvent {
  final ListingFilterParams params;

  const ListingsFilterChanged(this.params);

  @override
  List<Object?> get props => [params];
}

class ListingsPageChanged extends ListingsEvent {
  final int page;

  const ListingsPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class ListingsRefresh extends ListingsEvent {
  const ListingsRefresh();
}

// States
abstract class ListingsState extends Equatable {
  final ListingFilterParams currentParams;

  const ListingsState({this.currentParams = const ListingFilterParams()});

  @override
  List<Object?> get props => [currentParams];
}

class ListingsInitial extends ListingsState {}

class ListingsLoading extends ListingsState {
  const ListingsLoading({super.currentParams});
}

class ListingsLoaded extends ListingsState {
  final List<ListingEntity> listings;
  final int total;
  final int totalPages;
  final int currentPage;
  final ListingFacetsEntity facets;

  const ListingsLoaded({
    required this.listings,
    required this.total,
    required this.totalPages,
    required this.currentPage,
    required this.facets,
    required super.currentParams,
  });

  @override
  List<Object?> get props => [
        listings,
        total,
        totalPages,
        currentPage,
        facets,
        currentParams,
      ];
}

class ListingsEmpty extends ListingsState {
  const ListingsEmpty({required super.currentParams});
}

class ListingsError extends ListingsState {
  final String message;

  const ListingsError({
    required this.message,
    required super.currentParams,
  });

  @override
  List<Object?> get props => [message, currentParams];
}

// BLoC
class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  final SearchListingsUseCase _searchListingsUseCase;
  ListingFilterParams _currentParams;

  ListingsBloc({
    required SearchListingsUseCase searchListingsUseCase,
    ListingFilterParams initialParams = const ListingFilterParams(),
  })  : _searchListingsUseCase = searchListingsUseCase,
        _currentParams = initialParams,
        super(ListingsInitial()) {
    on<ListingsFilterChanged>(_onFilterChanged);
    on<ListingsPageChanged>(_onPageChanged);
    on<ListingsRefresh>(_onRefresh);
  }

  Future<void> _fetch(
    Emitter<ListingsState> emit, {
    required ListingFilterParams params,
  }) async {
    _currentParams = params;
    emit(ListingsLoading(currentParams: _currentParams));

    final result = await _searchListingsUseCase(_currentParams);

    result.fold(
      (failure) => emit(
        ListingsError(
          message: failure.messageKey,
          currentParams: _currentParams,
        ),
      ),
      (data) {
        if (data.listings.isEmpty) {
          emit(ListingsEmpty(currentParams: _currentParams));
        } else {
          emit(
            ListingsLoaded(
              listings: data.listings,
              total: data.total,
              totalPages: data.totalPages,
              currentPage: _currentParams.page,
              facets: data.facets,
              currentParams: _currentParams,
            ),
          );
        }
      },
    );
  }

  Future<void> _onFilterChanged(
    ListingsFilterChanged event,
    Emitter<ListingsState> emit,
  ) async {
    await _fetch(emit, params: event.params.copyWith(page: 1));
  }

  Future<void> _onPageChanged(
    ListingsPageChanged event,
    Emitter<ListingsState> emit,
  ) async {
    await _fetch(emit, params: _currentParams.copyWith(page: event.page));
  }

  Future<void> _onRefresh(
    ListingsRefresh event,
    Emitter<ListingsState> emit,
  ) async {
    await _fetch(emit, params: _currentParams);
  }
}
