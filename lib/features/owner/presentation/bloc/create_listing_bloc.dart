import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/create_listing_params.dart';
import '../../domain/entities/owner_listing_item.dart';
import '../../domain/usecases/owner_usecases.dart';

// Events
abstract class CreateListingEvent extends Equatable {
  const CreateListingEvent();
  @override
  List<Object?> get props => [];
}

class SubmitCreateListingEvent extends CreateListingEvent {
  final CreateListingParams params;
  const SubmitCreateListingEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class SubmitUpdateListingEvent extends CreateListingEvent {
  final String id;
  final Map<String, dynamic> updateFields;
  const SubmitUpdateListingEvent({required this.id, required this.updateFields});

  @override
  List<Object?> get props => [id, updateFields];
}

class UploadPhotosEvent extends CreateListingEvent {
  final List<String> filePaths;
  const UploadPhotosEvent(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

// States
abstract class CreateListingState extends Equatable {
  const CreateListingState();
  @override
  List<Object?> get props => [];
}

class CreateListingInitial extends CreateListingState {}

class CreateListingLoading extends CreateListingState {}

class CreateListingSuccess extends CreateListingState {
  final OwnerListingItem listing;
  final bool isUpdate;
  const CreateListingSuccess(this.listing, {this.isUpdate = false});

  @override
  List<Object?> get props => [listing, isUpdate];
}

class CreateListingPhotosUploaded extends CreateListingState {
  final List<String> urls;
  const CreateListingPhotosUploaded(this.urls);

  @override
  List<Object?> get props => [urls];
}

class CreateListingError extends CreateListingState {
  final String message;
  const CreateListingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CreateListingBloc extends Bloc<CreateListingEvent, CreateListingState> {
  final CreateListingUseCase createListingUseCase;
  final UpdateListingUseCase updateListingUseCase;
  final UploadMediaUseCase uploadMediaUseCase;

  CreateListingBloc({
    required this.createListingUseCase,
    required this.updateListingUseCase,
    required this.uploadMediaUseCase,
  }) : super(CreateListingInitial()) {
    on<SubmitCreateListingEvent>(_onCreate);
    on<SubmitUpdateListingEvent>(_onUpdate);
    on<UploadPhotosEvent>(_onUploadPhotos);
  }

  Future<void> _onCreate(
    SubmitCreateListingEvent event,
    Emitter<CreateListingState> emit,
  ) async {
    emit(CreateListingLoading());
    final result = await createListingUseCase(event.params);
    result.fold(
      (failure) => emit(CreateListingError(failure.message)),
      (listing) => emit(CreateListingSuccess(listing, isUpdate: false)),
    );
  }

  Future<void> _onUpdate(
    SubmitUpdateListingEvent event,
    Emitter<CreateListingState> emit,
  ) async {
    emit(CreateListingLoading());
    final result = await updateListingUseCase(event.id, event.updateFields);
    result.fold(
      (failure) => emit(CreateListingError(failure.message)),
      (listing) => emit(CreateListingSuccess(listing, isUpdate: true)),
    );
  }

  Future<void> _onUploadPhotos(
    UploadPhotosEvent event,
    Emitter<CreateListingState> emit,
  ) async {
    emit(CreateListingLoading());
    final result = await uploadMediaUseCase(event.filePaths);
    result.fold(
      (failure) => emit(CreateListingError(failure.message)),
      (urls) => emit(CreateListingPhotosUploaded(urls)),
    );
  }
}
