import '../../../shared/models/study_plan.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../shared/services/supabase_service.dart';

/// Repository for Personalized Study Plan
class StudyPlanRepository {
  Future<StudyPlan> getStudyPlan() async {
    final client = SupabaseService.instance.client;

    if (client != null) {
      try {
        final planData = await client
            .from('study_plans')
            .select()
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        if (planData != null) {
          final tasksData = await client
              .from('study_tasks')
              .select()
              .eq('plan_id', planData['id'])
              .order('order_index');

          final tasks = (tasksData as List<dynamic>?)
                  ?.map((t) => StudyTask.fromJson(t as Map<String, dynamic>))
                  .toList() ??
              [];

          return StudyPlan.fromJson(planData, tasks);
        }
      } catch (_) {}
    }

    return _getDefaultStudyPlan();
  }

  /// Toggle task completion state
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        await client.from('study_tasks').update({
          'is_completed': isCompleted,
          'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
        }).eq('id', taskId);
      } catch (_) {}
    }
  }

  /// Regenerate study plan using AI
  Future<StudyPlan> regeneratePlan() async {
    // Invoke protected edge function or Gemini service
    final edgeResult = await SupabaseService.instance.invokeEdgeFunction(
      functionName: 'study-plan-generate',
      body: {},
    );

    if (edgeResult != null && edgeResult['tasks'] != null) {
      final rawTasks = edgeResult['tasks'] as List<dynamic>;
      final tasks = rawTasks
          .map((t) => StudyTask.fromJson(t as Map<String, dynamic>))
          .toList();
      return _getDefaultStudyPlan().copyWithTasks(tasks);
    }

    // Call GeminiService directly
    final generatedTasks = await GeminiService.instance.generateStudyTasks(
      gapTopics: ['Eigenvalues & Spectral Theorem', 'Stochastic Gradient Descent'],
    );

    final tasks = generatedTasks.map((t) => StudyTask.fromJson(t)).toList();
    return _getDefaultStudyPlan().copyWithTasks(tasks);
  }

  StudyPlan _getDefaultStudyPlan() {
    return const StudyPlan(
      id: 'plan-default-1',
      studentId: 'student-elena-vass-id',
      title: 'Personalized Study Plan',
      planningDate: 'Oct 24',
      targetHours: 6.0,
      completedHours: 4.5,
      onTrackPercentage: 75.0,
      remainingTimeText: '1h 30m remaining',
      aiSyncInfo: 'Elena Vass • AI Model Synced (Oct 24)',
      tasks: [
        StudyTask(
          id: 'task-1',
          planId: 'plan-default-1',
          title: 'Orthogonal Projections & Eigenspaces',
          description: 'Review Strang Lecture 14 notes & complete 3 verification proofs.',
          taskType: StudyTaskType.reviewFundamentals,
          priority: StudyPriority.low,
          estimatedMinutes: 25,
          scheduledTime: '08:30 AM • 25m',
          isCompleted: true,
          masteryNote: 'Mastery verified at 94% retention',
          orderIndex: 0,
        ),
        StudyTask(
          id: 'task-2',
          planId: 'plan-default-1',
          title: 'Spectral Theorem: SVD & Matrix Diagonalization',
          description: 'Targeted problem set isolating characteristic polynomial roots and orthogonal eigenvectors.',
          taskType: StudyTaskType.practiceDrills,
          priority: StudyPriority.high,
          estimatedMinutes: 45,
          scheduledTime: '10:30 AM • 45m',
          isCompleted: false,
          masteryNote: null,
          orderIndex: 1,
        ),
        StudyTask(
          id: 'task-3',
          planId: 'plan-default-1',
          title: 'Conjugate Priors in Continuous Distributions',
          description: 'Synthesize normal-normal and beta-binomial Bayesian update equations.',
          taskType: StudyTaskType.strengthenConcepts,
          priority: StudyPriority.medium,
          estimatedMinutes: 35,
          scheduledTime: '02:00 PM • 35m',
          isCompleted: false,
          masteryNote: null,
          orderIndex: 2,
        ),
        StudyTask(
          id: 'task-4',
          planId: 'plan-default-1',
          title: 'Linear Algebra Benchmark Self-Check',
          description: '12-question diagnostic checking retention before Section B session.',
          taskType: StudyTaskType.testUnderstanding,
          priority: StudyPriority.low,
          estimatedMinutes: 20,
          scheduledTime: '04:30 PM • 20m',
          isCompleted: false,
          masteryNote: null,
          orderIndex: 3,
        ),
      ],
    );
  }
}

extension StudyPlanExt on StudyPlan {
  StudyPlan copyWithTasks(List<StudyTask> newTasks) {
    return StudyPlan(
      id: id,
      studentId: studentId,
      title: title,
      planningDate: planningDate,
      targetHours: targetHours,
      completedHours: completedHours,
      onTrackPercentage: onTrackPercentage,
      remainingTimeText: remainingTimeText,
      aiSyncInfo: aiSyncInfo,
      tasks: newTasks,
    );
  }
}
