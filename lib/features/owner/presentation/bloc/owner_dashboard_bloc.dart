import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/owner_dashboard_stats.dart';
import '../../domain/entities/owner_listing_item.dart';
import '../../domain/usecases/owner_usecases.dart';

// Events
abstract class OwnerDashboardEvent extends Equatable {
  const OwnerDashboardEvent();
  @override
  List<Object?> get props => [];
}

class FetchOwnerDashboardData extends OwnerDashboardEvent {
  final String? status;
  const FetchOwnerDashboardData({this.status});

  @override
  List<Object?> get props => [status];
}

class ChangeListingStatusFilter extends OwnerDashboardEvent {
  final String status;
  const ChangeListingStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class TransitionListingEvent extends OwnerDashboardEvent {
  final String id;
  final String action;
  const TransitionListingEvent({required this.id, required this.action});

  @override
  List<Object?> get props => [id, action];
}

// States
abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();
  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {}

class OwnerDashboardLoading extends OwnerDashboardState {}

class OwnerDashboardLoaded extends OwnerDashboardState {
  final OwnerDashboardStats stats;
  final List<OwnerListingItem> listings;
  final String activeFilter; // 'all', 'active', 'pending', 'archived'
  final bool isActionLoading;
  final String? actionSuccessMessage;
  final bool isOwnerRole;

  const OwnerDashboardLoaded({
    required this.stats,
    required this.listings,
    this.activeFilter = 'all',
    this.isActionLoading = false,
    this.actionSuccessMessage,
    this.isOwnerRole = true,
  });

  OwnerDashboardLoaded copyWith({
    OwnerDashboardStats? stats,
    List<OwnerListingItem>? listings,
    String? activeFilter,
    bool? isActionLoading,
    String? actionSuccessMessage,
    bool? isOwnerRole,
  }) {
    return OwnerDashboardLoaded(
      stats: stats ?? this.stats,
      listings: listings ?? this.listings,
      activeFilter: activeFilter ?? this.activeFilter,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionSuccessMessage: actionSuccessMessage,
      isOwnerRole: isOwnerRole ?? this.isOwnerRole,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        listings,
        activeFilter,
        isActionLoading,
        actionSuccessMessage,
        isOwnerRole,
      ];
}

class OwnerDashboardError extends OwnerDashboardState {
  final String message;
  const OwnerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OwnerDashboardBloc extends Bloc<OwnerDashboardEvent, OwnerDashboardState> {
  final GetOwnerDashboardStatsUseCase getDashboardStatsUseCase;
  final GetMyListingsUseCase getMyListingsUseCase;
  final TransitionListingStatusUseCase transitionListingStatusUseCase;

  OwnerDashboardBloc({
    required this.getDashboardStatsUseCase,
    required this.getMyListingsUseCase,
    required this.transitionListingStatusUseCase,
  }) : super(OwnerDashboardInitial()) {
    on<FetchOwnerDashboardData>(_onFetchData);
    on<ChangeListingStatusFilter>(_onChangeFilter);
    on<TransitionListingEvent>(_onTransitionListing);
  }

  Future<void> _onFetchData(
    FetchOwnerDashboardData event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    emit(OwnerDashboardLoading());

    final statsResult = await getDashboardStatsUseCase();
    final filter = event.status ?? 'all';
    final listingsResult = await getMyListingsUseCase(
      status: filter == 'all' ? null : filter,
    );

    // API-036 (/owner/dashboard) is restricted to owners/staff/admin, returning 403 Forbidden
    // ("Not allowed") for tenant accounts.
    // API-035 (/listings/mine) is accessible to any authenticated role.
    // When a tenant views the dashboard, stats are zeroed and isOwnerRole is marked false,
    // allowing their personal listings and UI to load cleanly instead of blocking with a 403 error.
    statsResult.fold(
      (statsFailure) {
        final isForbidden = statsFailure is ForbiddenFailure ||
            statsFailure.code == 'FORBIDDEN' ||
            statsFailure.message.toLowerCase().contains('not allowed');

        if (isForbidden) {
          listingsResult.fold(
            (listingsFailure) => emit(OwnerDashboardError(listingsFailure.message)),
            (listings) => emit(OwnerDashboardLoaded(
              stats: const OwnerDashboardStats(total: 0, active: 0, draft: 0, views: 0, favorites: 0),
              listings: listings,
              activeFilter: filter,
              isOwnerRole: false,
            )),
          );
        } else {
          emit(OwnerDashboardError(statsFailure.message));
        }
      },
      (stats) {
        listingsResult.fold(
          (listingsFailure) => emit(OwnerDashboardError(listingsFailure.message)),
          (listings) => emit(OwnerDashboardLoaded(
            stats: stats,
            listings: listings,
            activeFilter: filter,
            isOwnerRole: true,
          )),
        );
      },
    );
  }

  Future<void> _onChangeFilter(
    ChangeListingStatusFilter event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    if (state is! OwnerDashboardLoaded) return;
    final current = state as OwnerDashboardLoaded;

    emit(current.copyWith(isActionLoading: true, activeFilter: event.status));

    final filter = event.status == 'all' ? null : event.status;
    final result = await getMyListingsUseCase(status: filter);

    result.fold(
      (failure) => emit(OwnerDashboardError(failure.message)),
      (listings) => emit(current.copyWith(
        listings: listings,
        activeFilter: event.status,
        isActionLoading: false,
      )),
    );
  }

  Future<void> _onTransitionListing(
    TransitionListingEvent event,
    Emitter<OwnerDashboardState> emit,
  ) async {
    if (state is! OwnerDashboardLoaded) return;
    final current = state as OwnerDashboardLoaded;

    emit(current.copyWith(isActionLoading: true));

    final result = await transitionListingStatusUseCase(
      id: event.id,
      action: event.action,
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(isActionLoading: false));
      },
      (success) async {
        // Refresh listings and stats after transition
        final statsResult = await getDashboardStatsUseCase();
        final listingsResult = await getMyListingsUseCase(
          status: current.activeFilter == 'all' ? null : current.activeFilter,
        );

        final newStats = statsResult.getOrElse((_) => current.stats);
        final newListings = listingsResult.getOrElse((_) => current.listings);

        emit(current.copyWith(
          stats: newStats,
          listings: newListings,
          isActionLoading: false,
          actionSuccessMessage: 'Status changed to ${event.action}',
        ));
      },
    );
  }
}
