import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/verification_document.dart';
import '../../domain/usecases/owner_usecases.dart';

// Events
abstract class VerificationEvent extends Equatable {
  const VerificationEvent();
  @override
  List<Object?> get props => [];
}

class FetchVerificationDocumentsEvent extends VerificationEvent {
  const FetchVerificationDocumentsEvent();
}

class UploadVerificationDocumentEvent extends VerificationEvent {
  final String filePath;
  final String fileName;
  const UploadVerificationDocumentEvent({
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [filePath, fileName];
}

// States
abstract class VerificationState extends Equatable {
  const VerificationState();
  @override
  List<Object?> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationLoaded extends VerificationState {
  final List<VerificationDocument> documents;
  final bool isUploading;
  final String? successMessage;

  const VerificationLoaded({
    required this.documents,
    this.isUploading = false,
    this.successMessage,
  });

  VerificationLoaded copyWith({
    List<VerificationDocument>? documents,
    bool? isUploading,
    String? successMessage,
  }) {
    return VerificationLoaded(
      documents: documents ?? this.documents,
      isUploading: isUploading ?? this.isUploading,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [documents, isUploading, successMessage];
}

class VerificationError extends VerificationState {
  final String message;
  const VerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final GetVerificationDocumentsUseCase getDocumentsUseCase;
  final UploadVerificationDocumentUseCase uploadDocumentUseCase;

  VerificationBloc({
    required this.getDocumentsUseCase,
    required this.uploadDocumentUseCase,
  }) : super(VerificationInitial()) {
    on<FetchVerificationDocumentsEvent>(_onFetch);
    on<UploadVerificationDocumentEvent>(_onUpload);
  }

  Future<void> _onFetch(
    FetchVerificationDocumentsEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());
    final result = await getDocumentsUseCase();
    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (documents) => emit(VerificationLoaded(documents: documents)),
    );
  }

  Future<void> _onUpload(
    UploadVerificationDocumentEvent event,
    Emitter<VerificationState> emit,
  ) async {
    if (state is VerificationLoaded) {
      final current = state as VerificationLoaded;
      emit(current.copyWith(isUploading: true));
    } else {
      emit(VerificationLoading());
    }

    final result = await uploadDocumentUseCase(
      filePath: event.filePath,
      fileName: event.fileName,
    );

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (document) async {
        final docsResult = await getDocumentsUseCase();
        final docs = docsResult.getOrElse((_) => [document]);
        emit(VerificationLoaded(
          documents: docs,
          successMessage: 'Document uploaded successfully',
        ));
      },
    );
  }
}
