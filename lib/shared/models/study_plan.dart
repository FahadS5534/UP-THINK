enum StudyTaskType {
  reviewFundamentals,
  practiceDrills,
  strengthenConcepts,
  testUnderstanding,
}

enum StudyPriority {
  high,
  medium,
  low,
}

/// Upthink Individual Study Task Model
class StudyTask {
  final String id;
  final String planId;
  final String title;
  final String description;
  final StudyTaskType taskType;
  final StudyPriority priority;
  final int estimatedMinutes;
  final String scheduledTime;
  final bool isCompleted;
  final String? masteryNote;
  final int orderIndex;

  const StudyTask({
    required this.id,
    required this.planId,
    required this.title,
    required this.description,
    required this.taskType,
    required this.priority,
    required this.estimatedMinutes,
    required this.scheduledTime,
    this.isCompleted = false,
    this.masteryNote,
    this.orderIndex = 0,
  });

  String get taskTypeLabel {
    switch (taskType) {
      case StudyTaskType.reviewFundamentals:
        return 'REVIEW FUNDAMENTALS';
      case StudyTaskType.practiceDrills:
        return 'PRACTICE DRILLS';
      case StudyTaskType.strengthenConcepts:
        return 'STRENGTHEN CONCEPTS';
      case StudyTaskType.testUnderstanding:
        return 'TEST UNDERSTANDING';
    }
  }

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    StudyTaskType type = StudyTaskType.reviewFundamentals;
    final typeStr = (json['task_type'] as String?)?.toUpperCase();
    if (typeStr == 'PRACTICE_DRILLS') {
      type = StudyTaskType.practiceDrills;
    } else if (typeStr == 'STRENGTHEN_CONCEPTS') {
      type = StudyTaskType.strengthenConcepts;
    } else if (typeStr == 'TEST_UNDERSTANDING') {
      type = StudyTaskType.testUnderstanding;
    }

    StudyPriority prio = StudyPriority.medium;
    final prioStr = (json['priority'] as String?)?.toUpperCase();
    if (prioStr == 'HIGH') {
      prio = StudyPriority.high;
    } else if (prioStr == 'LOW') {
      prio = StudyPriority.low;
    }

    return StudyTask(
      id: json['id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      taskType: type,
      priority: prio,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 30,
      scheduledTime: json['scheduled_time'] as String? ?? '10:30 AM • 45m',
      isCompleted: json['is_completed'] as bool? ?? false,
      masteryNote: json['mastery_note'] as String?,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'title': title,
      'description': description,
      'task_type': taskType.name,
      'priority': priority.name,
      'estimated_minutes': estimatedMinutes,
      'scheduled_time': scheduledTime,
      'is_completed': isCompleted,
      'mastery_note': masteryNote,
      'order_index': orderIndex,
    };
  }

  StudyTask copyWith({
    bool? isCompleted,
    String? masteryNote,
  }) {
    return StudyTask(
      id: id,
      planId: planId,
      title: title,
      description: description,
      taskType: taskType,
      priority: priority,
      estimatedMinutes: estimatedMinutes,
      scheduledTime: scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      masteryNote: masteryNote ?? this.masteryNote,
      orderIndex: orderIndex,
    );
  }
}

/// Upthink Personalized Study Plan Model
class StudyPlan {
  final String id;
  final String studentId;
  final String title;
  final String planningDate;
  final double targetHours;
  final double completedHours;
  final double onTrackPercentage;
  final String remainingTimeText;
  final String aiSyncInfo;
  final List<StudyTask> tasks;

  const StudyPlan({
    required this.id,
    required this.studentId,
    required this.title,
    required this.planningDate,
    required this.targetHours,
    required this.completedHours,
    required this.onTrackPercentage,
    required this.remainingTimeText,
    required this.aiSyncInfo,
    this.tasks = const [],
  });

  factory StudyPlan.fromJson(Map<String, dynamic> json, [List<StudyTask> tasks = const []]) {
    return StudyPlan(
      id: json['id'] as String? ?? '',
      studentId: json['student_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Personalized Study Plan',
      planningDate: json['planning_date'] as String? ?? 'Oct 24',
      targetHours: (json['target_hours'] as num?)?.toDouble() ?? 6.0,
      completedHours: (json['completed_hours'] as num?)?.toDouble() ?? 4.5,
      onTrackPercentage: (json['on_track_percentage'] as num?)?.toDouble() ?? 75.0,
      remainingTimeText: json['remaining_time_text'] as String? ?? '1h 30m remaining',
      aiSyncInfo: json['ai_sync_info'] as String? ?? 'Elena Vass • AI Model Synced (Oct 24)',
      tasks: tasks,
    );
  }

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
