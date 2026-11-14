import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/content_entities.dart';
import '../../domain/usecases/content_usecases.dart';

// Events
abstract class StaticContentEvent extends Equatable {
  const StaticContentEvent();
  @override
  List<Object?> get props => [];
}

class FetchGuidesEvent extends StaticContentEvent {
  const FetchGuidesEvent();
}

class FetchGuideDetailEvent extends StaticContentEvent {
  final String slug;
  const FetchGuideDetailEvent(this.slug);

  @override
  List<Object?> get props => [slug];
}

class FetchStaticPageEvent extends StaticContentEvent {
  final String slug; // about, contact, privacy, terms, help
  const FetchStaticPageEvent(this.slug);

  @override
  List<Object?> get props => [slug];
}

// States
abstract class StaticContentState extends Equatable {
  const StaticContentState();
  @override
  List<Object?> get props => [];
}

class StaticContentInitial extends StaticContentState {}

class StaticContentLoading extends StaticContentState {}

class GuidesLoaded extends StaticContentState {
  final List<GuideEntity> guides;
  const GuidesLoaded(this.guides);

  @override
  List<Object?> get props => [guides];
}

class GuideDetailLoaded extends StaticContentState {
  final GuideEntity guide;
  const GuideDetailLoaded(this.guide);

  @override
  List<Object?> get props => [guide];
}

class StaticPageLoaded extends StaticContentState {
  final StaticPageEntity page;
  const StaticPageLoaded(this.page);

  @override
  List<Object?> get props => [page];
}

class StaticContentError extends StaticContentState {
  final String message;
  const StaticContentError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class StaticContentBloc extends Bloc<StaticContentEvent, StaticContentState> {
  final GetGuidesUseCase getGuidesUseCase;
  final GetGuideDetailUseCase getGuideDetailUseCase;
  final GetStaticPageUseCase getStaticPageUseCase;

  StaticContentBloc({
    required this.getGuidesUseCase,
    required this.getGuideDetailUseCase,
    required this.getStaticPageUseCase,
  }) : super(StaticContentInitial()) {
    on<FetchGuidesEvent>(_onFetchGuides);
    on<FetchGuideDetailEvent>(_onFetchGuideDetail);
    on<FetchStaticPageEvent>(_onFetchStaticPage);
  }

  Future<void> _onFetchGuides(
    FetchGuidesEvent event,
    Emitter<StaticContentState> emit,
  ) async {
    emit(StaticContentLoading());
    final result = await getGuidesUseCase();
    result.fold(
      (failure) => emit(StaticContentError(failure.message)),
      (guides) => emit(GuidesLoaded(guides)),
    );
  }

  Future<void> _onFetchGuideDetail(
    FetchGuideDetailEvent event,
    Emitter<StaticContentState> emit,
  ) async {
    emit(StaticContentLoading());
    final result = await getGuideDetailUseCase(event.slug);
    result.fold(
      (failure) => emit(StaticContentError(failure.message)),
      (guide) => emit(GuideDetailLoaded(guide)),
    );
  }

  Future<void> _onFetchStaticPage(
    FetchStaticPageEvent event,
    Emitter<StaticContentState> emit,
  ) async {
    emit(StaticContentLoading());
    final result = await getStaticPageUseCase(event.slug);
    result.fold(
      (failure) => emit(StaticContentError(failure.message)),
      (page) => emit(StaticPageLoaded(page)),
    );
  }
}
