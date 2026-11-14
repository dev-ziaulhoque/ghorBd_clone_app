import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/content_entities.dart';
import '../../domain/usecases/content_usecases.dart';

// Events
abstract class QaEvent extends Equatable {
  const QaEvent();
  @override
  List<Object?> get props => [];
}

class FetchQuestionsEvent extends QaEvent {
  final String? category;
  final String? sort;
  const FetchQuestionsEvent({this.category, this.sort});

  @override
  List<Object?> get props => [category, sort];
}

class FetchQuestionDetailEvent extends QaEvent {
  final String idOrSlug;
  const FetchQuestionDetailEvent(this.idOrSlug);

  @override
  List<Object?> get props => [idOrSlug];
}

class AskQuestionEvent extends QaEvent {
  final String title;
  final String body;
  final String category;
  final List<String> tags;

  const AskQuestionEvent({
    required this.title,
    required this.body,
    required this.category,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [title, body, category, tags];
}

class PostAnswerEvent extends QaEvent {
  final String questionId;
  final String body;

  const PostAnswerEvent({required this.questionId, required this.body});

  @override
  List<Object?> get props => [questionId, body];
}

class FetchMyQuestionsEvent extends QaEvent {
  const FetchMyQuestionsEvent();
}

// States
abstract class QaState extends Equatable {
  const QaState();
  @override
  List<Object?> get props => [];
}

class QaInitial extends QaState {}

class QaLoading extends QaState {}

class QaLoaded extends QaState {
  final List<QuestionEntity> questions;
  final String activeCategory;
  final QuestionEntity? selectedQuestion;
  final List<AnswerEntity> answers;
  final List<QuestionEntity> myQuestions;
  final bool isSubmitting;
  final String? actionSuccessMessage;

  const QaLoaded({
    this.questions = const [],
    this.activeCategory = 'all',
    this.selectedQuestion,
    this.answers = const [],
    this.myQuestions = const [],
    this.isSubmitting = false,
    this.actionSuccessMessage,
  });

  QaLoaded copyWith({
    List<QuestionEntity>? questions,
    String? activeCategory,
    QuestionEntity? selectedQuestion,
    List<AnswerEntity>? answers,
    List<QuestionEntity>? myQuestions,
    bool? isSubmitting,
    String? actionSuccessMessage,
  }) {
    return QaLoaded(
      questions: questions ?? this.questions,
      activeCategory: activeCategory ?? this.activeCategory,
      selectedQuestion: selectedQuestion ?? this.selectedQuestion,
      answers: answers ?? this.answers,
      myQuestions: myQuestions ?? this.myQuestions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        activeCategory,
        selectedQuestion,
        answers,
        myQuestions,
        isSubmitting,
        actionSuccessMessage,
      ];
}

class QaError extends QaState {
  final String message;
  const QaError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class QaBloc extends Bloc<QaEvent, QaState> {
  final GetQuestionsUseCase getQuestionsUseCase;
  final GetQuestionDetailUseCase getQuestionDetailUseCase;
  final AskQuestionUseCase askQuestionUseCase;
  final GetAnswersUseCase getAnswersUseCase;
  final PostAnswerUseCase postAnswerUseCase;
  final GetMyQuestionsUseCase getMyQuestionsUseCase;

  QaBloc({
    required this.getQuestionsUseCase,
    required this.getQuestionDetailUseCase,
    required this.askQuestionUseCase,
    required this.getAnswersUseCase,
    required this.postAnswerUseCase,
    required this.getMyQuestionsUseCase,
  }) : super(QaInitial()) {
    on<FetchQuestionsEvent>(_onFetchQuestions);
    on<FetchQuestionDetailEvent>(_onFetchDetail);
    on<AskQuestionEvent>(_onAskQuestion);
    on<PostAnswerEvent>(_onPostAnswer);
    on<FetchMyQuestionsEvent>(_onFetchMyQuestions);
  }

  Future<void> _onFetchQuestions(
    FetchQuestionsEvent event,
    Emitter<QaState> emit,
  ) async {
    emit(QaLoading());
    final cat = event.category ?? 'all';
    final result = await getQuestionsUseCase(
      category: cat == 'all' ? null : cat,
      sort: event.sort,
    );
    result.fold(
      (failure) => emit(QaError(failure.message)),
      (questions) => emit(QaLoaded(questions: questions, activeCategory: cat)),
    );
  }

  Future<void> _onFetchDetail(
    FetchQuestionDetailEvent event,
    Emitter<QaState> emit,
  ) async {
    emit(QaLoading());
    final qResult = await getQuestionDetailUseCase(event.idOrSlug);
    await qResult.fold(
      (failure) async => emit(QaError(failure.message)),
      (question) async {
        final aResult = await getAnswersUseCase(question.id);
        final answers = aResult.getOrElse((_) => []);
        emit(QaLoaded(selectedQuestion: question, answers: answers));
      },
    );
  }

  Future<void> _onAskQuestion(
    AskQuestionEvent event,
    Emitter<QaState> emit,
  ) async {
    final current = state is QaLoaded ? (state as QaLoaded) : const QaLoaded();
    emit(current.copyWith(isSubmitting: true));

    final result = await askQuestionUseCase(
      title: event.title,
      body: event.body,
      category: event.category,
      tags: event.tags,
    );

    result.fold(
      (failure) => emit(QaError(failure.message)),
      (question) => emit(current.copyWith(
        isSubmitting: false,
        actionSuccessMessage: 'Question submitted successfully',
      )),
    );
  }

  Future<void> _onPostAnswer(
    PostAnswerEvent event,
    Emitter<QaState> emit,
  ) async {
    if (state is! QaLoaded) return;
    final current = state as QaLoaded;

    emit(current.copyWith(isSubmitting: true));
    final result = await postAnswerUseCase(
      questionId: event.questionId,
      body: event.body,
    );

    result.fold(
      (failure) => emit(current.copyWith(isSubmitting: false, actionSuccessMessage: failure.message)),
      (answer) => emit(current.copyWith(
        isSubmitting: false,
        answers: [...current.answers, answer],
        actionSuccessMessage: 'Answer posted successfully',
      )),
    );
  }

  Future<void> _onFetchMyQuestions(
    FetchMyQuestionsEvent event,
    Emitter<QaState> emit,
  ) async {
    emit(QaLoading());
    final result = await getMyQuestionsUseCase();
    result.fold(
      (failure) => emit(QaError(failure.message)),
      (questions) => emit(QaLoaded(myQuestions: questions)),
    );
  }
}
