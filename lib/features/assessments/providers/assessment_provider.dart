import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/assessment.dart';
import '../data/assessment_repository.dart';

final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  return AssessmentRepository();
});

final assessmentQuestionsProvider = FutureProvider.family<List<AssessmentQuestion>, String>((ref, assessmentId) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  return repo.getQuestions(assessmentId);
});

class ActiveQuizState {
  final int currentQuestionIndex;
  final Map<String, String> selectedAnswers; // {questionId: optionId}
  final Set<String> flaggedQuestions;
  final int remainingSeconds;
  final bool isSubmitted;

  const ActiveQuizState({
    this.currentQuestionIndex = 3, // Question 4 in screen.png (0-indexed 3)
    this.selectedAnswers = const {'q-4': 'B'},
    this.flaggedQuestions = const {},
    this.remainingSeconds = 860, // 14:20
    this.isSubmitted = false,
  });

  ActiveQuizState copyWith({
    int? currentQuestionIndex,
    Map<String, String>? selectedAnswers,
    Set<String>? flaggedQuestions,
    int? remainingSeconds,
    bool? isSubmitted,
  }) {
    return ActiveQuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class ActiveQuizNotifier extends Notifier<ActiveQuizState> {
  @override
  ActiveQuizState build() {
    return const ActiveQuizState();
  }

  void selectOption(String questionId, String optionId) {
    final updated = Map<String, String>.from(state.selectedAnswers);
    updated[questionId] = optionId;
    state = state.copyWith(selectedAnswers: updated);
  }

  void toggleFlag(String questionId) {
    final updated = Set<String>.from(state.flaggedQuestions);
    if (updated.contains(questionId)) {
      updated.remove(questionId);
    } else {
      updated.add(questionId);
    }
    state = state.copyWith(flaggedQuestions: updated);
  }

  void goToQuestion(int index) {
    state = state.copyWith(currentQuestionIndex: index);
  }
}

final activeQuizProvider = NotifierProvider<ActiveQuizNotifier, ActiveQuizState>(ActiveQuizNotifier.new);

final assessmentResultsProvider = FutureProvider.family<AssessmentResultsData, String>((ref, assessmentId) async {
  final repo = ref.watch(assessmentRepositoryProvider);
  final quizState = ref.watch(activeQuizProvider);
  return repo.submitAssessment(
    assessmentId: assessmentId,
    answers: quizState.selectedAnswers,
    durationSeconds: 1120, // 18m 40s
  );
});
