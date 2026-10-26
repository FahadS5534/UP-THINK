import '../../core/widgets/severity_badge.dart';

/// Upthink Learning Gap Diagnostic Model
class LearningGap {
  final String id;
  final String topicName;
  final String courseCode;
  final String nodeCode;
  final double masteryPercentage;
  final GapSeverity severity;
  final String diagnosis;
  final String recommendedAction;
  final String? blockerDetails;
  final String? recentQuizScore;
  final double trendPercentage;

  const LearningGap({
    required this.id,
    required this.topicName,
    required this.courseCode,
    required this.nodeCode,
    required this.masteryPercentage,
    required this.severity,
    required this.diagnosis,
    required this.recommendedAction,
    this.blockerDetails,
    this.recentQuizScore,
    this.trendPercentage = 0.0,
  });

  factory LearningGap.fromJson(Map<String, dynamic> json) {
    GapSeverity parsedSeverity = GapSeverity.high;
    final sevStr = (json['severity'] as String?)?.toUpperCase();
    if (sevStr == 'MEDIUM') {
      parsedSeverity = GapSeverity.medium;
    } else if (sevStr == 'LOW') {
      parsedSeverity = GapSeverity.low;
    }

    return LearningGap(
      id: json['id'] as String? ?? '',
      topicName: json['topic_name'] as String? ?? 'Eigenvalues & Spectral Theorem',
      courseCode: json['course_code'] as String? ?? 'MATH 302',
      nodeCode: json['node_code'] as String? ?? 'Node #MATH-401',
      masteryPercentage: (json['mastery_percentage'] as num?)?.toDouble() ?? 42.0,
      severity: parsedSeverity,
      diagnosis: json['diagnosis'] as String? ?? '',
      recommendedAction: json['recommended_action'] as String? ?? 'Review topic',
      blockerDetails: json['blocker_details'] as String?,
      recentQuizScore: json['recent_quiz_score'] as String?,
      trendPercentage: (json['trend_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_name': topicName,
      'course_code': courseCode,
      'node_code': nodeCode,
      'mastery_percentage': masteryPercentage,
      'severity': severity == GapSeverity.high
          ? 'HIGH'
          : severity == GapSeverity.medium
              ? 'MEDIUM'
              : 'LOW',
      'diagnosis': diagnosis,
      'recommended_action': recommendedAction,
      'blocker_details': blockerDetails,
      'recent_quiz_score': recentQuizScore,
      'trend_percentage': trendPercentage,
    };
  }
}
