import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pricing_plan_entity.dart';
import '../../domain/usecases/get_pricing_plans_usecase.dart';

// Events
abstract class PricingEvent extends Equatable {
  const PricingEvent();
  @override
  List<Object?> get props => [];
}

class FetchPricingPlansEvent extends PricingEvent {
  const FetchPricingPlansEvent();
}

// States
abstract class PricingState extends Equatable {
  const PricingState();
  @override
  List<Object?> get props => [];
}

class PricingInitial extends PricingState {}

class PricingLoading extends PricingState {}

class PricingLoaded extends PricingState {
  final List<PricingPlanEntity> plans;

  const PricingLoaded(this.plans);

  @override
  List<Object?> get props => [plans];
}

class PricingError extends PricingState {
  final String message;

  const PricingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final GetPricingPlansUseCase getPricingPlansUseCase;

  PricingBloc({required this.getPricingPlansUseCase}) : super(PricingInitial()) {
    on<FetchPricingPlansEvent>(_onFetchPricingPlans);
  }

  Future<void> _onFetchPricingPlans(
    FetchPricingPlansEvent event,
    Emitter<PricingState> emit,
  ) async {
    emit(PricingLoading());
    final result = await getPricingPlansUseCase();
    result.fold(
      (failure) => emit(PricingError(failure.message)),
      (plans) => emit(PricingLoaded(plans)),
    );
  }
}
