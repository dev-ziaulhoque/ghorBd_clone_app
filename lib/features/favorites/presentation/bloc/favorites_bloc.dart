import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../browse/domain/entities/listing_entity.dart';
import '../../domain/usecases/favorites_usecases.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FetchFavorites extends FavoritesEvent {
  const FetchFavorites();
}

class ToggleFavorite extends FavoritesEvent {
  final ListingEntity listing;
  const ToggleFavorite(this.listing);

  @override
  List<Object?> get props => [listing];
}

class RemoveFavorite extends FavoritesEvent {
  final String listingId;
  const RemoveFavorite(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

// States
abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<ListingEntity> favorites;
  const FavoritesLoaded(this.favorites);

  bool isFavorite(String listingId) =>
      favorites.any((item) => item.id == listingId);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String messageKey;
  const FavoritesError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

// Bloc
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final AddFavoriteUseCase addFavoriteUseCase;
  final RemoveFavoriteUseCase removeFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super(const FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    final result = await getFavoritesUseCase();
    result.fold(
      (failure) => emit(FavoritesError(failure.messageKey)),
      (items) => emit(FavoritesLoaded(items)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentList = state is FavoritesLoaded
        ? List<ListingEntity>.from((state as FavoritesLoaded).favorites)
        : <ListingEntity>[];

    final isFav = currentList.any((l) => l.id == event.listing.id);

    if (isFav) {
      currentList.removeWhere((l) => l.id == event.listing.id);
      emit(FavoritesLoaded(currentList));
      final result = await removeFavoriteUseCase(event.listing.id);
      result.fold(
        (_) {
          // Revert if failed
          currentList.add(event.listing);
          emit(FavoritesLoaded(currentList));
        },
        (_) {},
      );
    } else {
      currentList.insert(0, event.listing);
      emit(FavoritesLoaded(currentList));
      final result = await addFavoriteUseCase(event.listing.id);
      result.fold(
        (_) {
          // Revert if failed
          currentList.removeWhere((l) => l.id == event.listing.id);
          emit(FavoritesLoaded(currentList));
        },
        (_) {},
      );
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentList = List<ListingEntity>.from((state as FavoritesLoaded).favorites);
      currentList.removeWhere((item) => item.id == event.listingId);
      emit(FavoritesLoaded(currentList));
    }
    await removeFavoriteUseCase(event.listingId);
  }
}
