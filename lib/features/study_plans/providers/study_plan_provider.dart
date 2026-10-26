import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/study_plan.dart';
import '../data/study_plan_repository.dart';

final studyPlanRepositoryProvider = Provider<StudyPlanRepository>((ref) {
  return StudyPlanRepository();
});

class StudyPlanNotifier extends AsyncNotifier<StudyPlan> {
  @override
  Future<StudyPlan> build() async {
    final repository = ref.watch(studyPlanRepositoryProvider);
    return repository.getStudyPlan();
  }

  Future<void> loadPlan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(studyPlanRepositoryProvider).getStudyPlan();
    });
  }

  Future<void> toggleTask(String taskId, bool currentStatus) async {
    final currentPlan = state.value;
    if (currentPlan == null) return;

    final updatedTasks = currentPlan.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(isCompleted: !currentStatus);
      }
      return t;
    }).toList();

    state = AsyncValue.data(currentPlan.copyWithTasks(updatedTasks));
    await ref.read(studyPlanRepositoryProvider).toggleTaskCompletion(taskId, !currentStatus);
  }

  Future<void> regeneratePlan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(studyPlanRepositoryProvider).regeneratePlan();
    });
  }
}

final studyPlanStateProvider = AsyncNotifierProvider<StudyPlanNotifier, StudyPlan>(StudyPlanNotifier.new);
