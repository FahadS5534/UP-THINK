/// Question Answer Option
class QuestionOption {
  final String id; // A, B, C, D
  final String text;
  final String? subtitle;

  const QuestionOption({
    required this.id,
    required this.text,
    this.subtitle,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String? ?? 'A',
      text: json['text'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'subtitle': subtitle,
    };
  }
}

/// Upthink Assessment Question Model
class AssessmentQuestion {
  final String id;
  final String assessmentId;
  final int orderIndex;
  final String topicTag;
  final int points;
  final String promptStem;
  final String? formalHypothesis;
  final String? proofHint;
  final List<QuestionOption> options;
  final String? correctOption; // Kept secure on server
  final String? explanation;

  const AssessmentQuestion({
    required this.id,
    required this.assessmentId,
    required this.orderIndex,
    required this.topicTag,
    required this.points,
    required this.promptStem,
    this.formalHypothesis,
    this.proofHint,
    required this.options,
    this.correctOption,
    this.explanation,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final options = rawOptions
        .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
        .toList();

    return AssessmentQuestion(
      id: json['id'] as String? ?? '',
      assessmentId: json['assessment_id'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 1,
      topicTag: json['topic_tag'] as String? ?? 'Spectral Theorem • Real Symmetric',
      points: (json['points'] as num?)?.toInt() ?? 3,
      promptStem: json['prompt_stem'] as String? ?? '',
      formalHypothesis: json['formal_hypothesis'] as String?,
      proofHint: json['proof_hint'] as String?,
      options: options,
      correctOption: json['correct_option'] as String?,
      explanation: json['explanation'] as String?,
    );
  }
}

/// Upthink Assessment Model
class Assessment {
  final String id;
  final String title;
  final String courseCode;
  final String subject;
  final int timeLimitMinutes;
  final int questionCount;
  final int totalPoints;
  final String engineMode;
  final String status; // ACTIVE, DRAFT, SCHEDULED, ARCHIVED
  final String? scheduledLabel;
  final double meanScore;
  final int turnInCount;
  final int totalEnrolled;

  const Assessment({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.subject,
    required this.timeLimitMinutes,
    required this.questionCount,
    required this.totalPoints,
    required this.engineMode,
    required this.status,
    this.scheduledLabel,
    this.meanScore = 0.0,
    this.turnInCount = 0,
    this.totalEnrolled = 46,
  });

  bool get isLive => status == 'ACTIVE';
  bool get isDraft => status == 'DRAFT';
  bool get isScheduled => status == 'SCHEDULED';

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Diagnostic Assessment',
      courseCode: json['course_code'] as String? ?? 'MATH-402',
      subject: json['subject'] as String? ?? 'Linear Algebra',
      timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt() ?? 25,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 12,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 36,
      engineMode: json['engine_mode'] as String? ?? 'ADAPTIVE',
      status: json['status'] as String? ?? 'ACTIVE',
      scheduledLabel: json['scheduled_label'] as String?,
      meanScore: (json['mean_score'] as num?)?.toDouble() ?? 0.0,
      turnInCount: (json['turn_in_count'] as num?)?.toInt() ?? 0,
      totalEnrolled: (json['total_enrolled'] as num?)?.toInt() ?? 46,
    );
  }
}
