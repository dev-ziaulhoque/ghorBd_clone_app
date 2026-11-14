import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/usecases/contact_usecases.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class SubmitReportEvent extends ReportEvent {
  final String listingId;
  final String reason;
  final String? details;

  const SubmitReportEvent({
    required this.listingId,
    required this.reason,
    this.details,
  });

  @override
  List<Object?> get props => [listingId, reason, details];
}

// States
abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportSubmitting extends ReportState {
  const ReportSubmitting();
}

class ReportSuccessState extends ReportState {
  final ReportEntity report;
  const ReportSuccessState(this.report);

  @override
  List<Object?> get props => [report];
}

class ReportErrorState extends ReportState {
  final String messageKey;
  const ReportErrorState(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

// Bloc
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportListingUseCase reportListingUseCase;

  ReportBloc({required this.reportListingUseCase})
      : super(const ReportInitial()) {
    on<SubmitReportEvent>(_onSubmitReport);
  }

  Future<void> _onSubmitReport(
    SubmitReportEvent event,
    Emitter<ReportState> emit,
  ) async {
    if (event.reason.trim().isEmpty) {
      emit(const ReportErrorState('validation_error'));
      return;
    }

    emit(const ReportSubmitting());
    final result = await reportListingUseCase(
      listingId: event.listingId,
      reason: event.reason,
      details: event.details,
    );
    result.fold(
      (failure) => emit(ReportErrorState(failure.messageKey)),
      (report) => emit(ReportSuccessState(report)),
    );
  }
}
