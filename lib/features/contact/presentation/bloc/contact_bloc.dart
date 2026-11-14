import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/contact_usecases.dart';

// Events
abstract class ContactEvent extends Equatable {
  const ContactEvent();
  @override
  List<Object?> get props => [];
}

class RevealContactPhone extends ContactEvent {
  final String listingId;
  const RevealContactPhone(this.listingId);

  @override
  List<Object?> get props => [listingId];
}

class SendContactInquiry extends ContactEvent {
  final String listingId;
  final String content;
  const SendContactInquiry({required this.listingId, required this.content});

  @override
  List<Object?> get props => [listingId, content];
}

// States
abstract class ContactState extends Equatable {
  const ContactState();
  @override
  List<Object?> get props => [];
}

class ContactInitial extends ContactState {
  const ContactInitial();
}

class ContactLoading extends ContactState {
  const ContactLoading();
}

class PhoneRevealed extends ContactState {
  final String phone;
  const PhoneRevealed(this.phone);

  @override
  List<Object?> get props => [phone];
}

class InquirySentSuccess extends ContactState {
  const InquirySentSuccess();
}

class ContactError extends ContactState {
  final String messageKey;
  const ContactError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}

// Bloc
class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final GetContactPhoneUseCase getContactPhoneUseCase;
  final SendInquiryUseCase sendInquiryUseCase;

  ContactBloc({
    required this.getContactPhoneUseCase,
    required this.sendInquiryUseCase,
  }) : super(const ContactInitial()) {
    on<RevealContactPhone>(_onRevealContactPhone);
    on<SendContactInquiry>(_onSendContactInquiry);
  }

  Future<void> _onRevealContactPhone(
    RevealContactPhone event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    final result = await getContactPhoneUseCase(event.listingId);
    result.fold(
      (failure) => emit(ContactError(failure.messageKey)),
      (phone) => emit(PhoneRevealed(phone)),
    );
  }

  Future<void> _onSendContactInquiry(
    SendContactInquiry event,
    Emitter<ContactState> emit,
  ) async {
    if (event.content.trim().isEmpty) {
      emit(const ContactError('validation_error'));
      return;
    }
    emit(const ContactLoading());
    final result = await sendInquiryUseCase(event.listingId, event.content.trim());
    result.fold(
      (failure) => emit(ContactError(failure.messageKey)),
      (_) => emit(const InquirySentSuccess()),
    );
  }
}
