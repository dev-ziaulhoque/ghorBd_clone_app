import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/listing_entity.dart';
import '../../domain/usecases/get_listing_detail_usecase.dart';

// Events
abstract class ListingDetailEvent extends Equatable {
  const ListingDetailEvent();

  @override
  List<Object?> get props => [];
}

class ListingDetailFetch extends ListingDetailEvent {
  final String idOrSlug;
  final String? fallbackId;

  const ListingDetailFetch(this.idOrSlug, {this.fallbackId});

  @override
  List<Object?> get props => [idOrSlug, fallbackId];
}

// States
abstract class ListingDetailState extends Equatable {
  const ListingDetailState();

  @override
  List<Object?> get props => [];
}

class ListingDetailInitial extends ListingDetailState {}

class ListingDetailLoading extends ListingDetailState {}

class ListingDetailLoaded extends ListingDetailState {
  final ListingEntity listing;
  final List<ListingEntity> similar;

  const ListingDetailLoaded({
    required this.listing,
    this.similar = const [],
  });

  @override
  List<Object?> get props => [listing, similar];
}

class ListingDetailError extends ListingDetailState {
  final String message;

  const ListingDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class ListingDetailBloc extends Bloc<ListingDetailEvent, ListingDetailState> {
  final GetListingDetailUseCase _getListingDetailUseCase;

  ListingDetailBloc({required GetListingDetailUseCase getListingDetailUseCase})
      : _getListingDetailUseCase = getListingDetailUseCase,
        super(ListingDetailInitial()) {
    on<ListingDetailFetch>(_onFetch);
  }

  Future<void> _onFetch(
    ListingDetailFetch event,
    Emitter<ListingDetailState> emit,
  ) async {
    emit(ListingDetailLoading());
    var result = await _getListingDetailUseCase(event.idOrSlug);
    if (result.isLeft() &&
        event.fallbackId != null &&
        event.fallbackId!.isNotEmpty &&
        event.fallbackId != event.idOrSlug) {
      result = await _getListingDetailUseCase(event.fallbackId!);
    }
    result.fold(
      (failure) => emit(ListingDetailError(message: failure.messageKey)),
      (data) => emit(
        ListingDetailLoaded(
          listing: data.listing,
          similar: data.similar,
        ),
      ),
    );
  }
}
