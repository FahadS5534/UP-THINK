import '../../../shared/models/assessment.dart';
import '../../../shared/models/cohort.dart';
import '../../../shared/services/supabase_service.dart';

/// Repository for Facilitator Cohort Dashboard & Authoring
class FacilitatorRepository {
  Future<CohortData> getCohortAnalytics(String cohortId) async {
    final client = SupabaseService.instance.client;

    if (client != null) {
      try {
        final res = await client
            .from('cohorts')
            .select()
            .eq('id', cohortId)
            .maybeSingle();

        if (res != null) {
          return CohortData(
            id: res['id'] as String,
            code: res['code'] as String? ?? 'MATH-302',
            section: res['section'] as String? ?? 'Section B',
            name: res['name'] as String? ?? 'Machine Learning Foundry',
            totalEnrolled: (res['total_enrolled'] as num?)?.toInt() ?? 46,
            avgMastery: (res['avg_mastery'] as num?)?.toDouble() ?? 71.4,
            masteryChange: -2.1,
            completionRate: (res['completion_rate'] as num?)?.toDouble() ?? 93.5,
            submittedCount: 43,
            actionRequiredCount: (res['critical_flags_count'] as num?)?.toInt() ?? 7,
            retentionRate: (res['retention_rate'] as num?)?.toDouble() ?? 84.2,
            scoreDistribution: CohortData.defaultCohort().scoreDistribution,
          );
        }
      } catch (_) {}
    }

    return CohortData.defaultCohort();
  }

  /// Get assessments for facilitator workspace
  Future<List<Assessment>> getFacilitatorAssessments() async {
    final client = SupabaseService.instance.client;

    if (client != null) {
      try {
        final res = await client.from('assessments').select();
        final raw = res as List<dynamic>?;
        if (raw != null && raw.isNotEmpty) {
          return raw.map((a) => Assessment.fromJson(a as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return _getDefaultAssessments();
  }

  /// Create and author a new assessment question
  Future<AssessmentQuestion> createQuestion({
    required String assessmentId,
    required String stem,
    required String correctOption,
    required List<QuestionOption> options,
    String? topicTag,
    int points = 3,
  }) async {
    final newQuestion = AssessmentQuestion(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      assessmentId: assessmentId,
      orderIndex: 5,
      topicTag: topicTag ?? 'Spectral Decomposition & SVD',
      points: points,
      promptStem: stem,
      options: options,
      correctOption: correctOption,
      explanation: 'Authoritative validation established by faculty.',
    );

    final client = SupabaseService.instance.client;
    if (client != null) {
      try {
        await client.from('assessment_questions').insert({
          'id': newQuestion.id,
          'assessment_id': assessmentId,
          'order_index': newQuestion.orderIndex,
          'topic_tag': newQuestion.topicTag,
          'points': points,
          'prompt_stem': stem,
          'options': options.map((o) => o.toJson()).toList(),
          'correct_option': correctOption,
          'explanation': newQuestion.explanation,
        });
      } catch (_) {}
    }

    return newQuestion;
  }

  List<Assessment> _getDefaultAssessments() {
    return const [
      Assessment(
        id: 'a-1',
        title: 'Diagnostic #4: Spectral Theorem & Orthogonality',
        courseCode: 'MATH-402',
        subject: 'Linear Algebra',
        timeLimitMinutes: 25,
        questionCount: 12,
        totalPoints: 36,
        engineMode: 'ADAPTIVE',
        status: 'ACTIVE',
        scheduledLabel: 'Live Now',
        meanScore: 78.4,
        turnInCount: 43,
        totalEnrolled: 46,
      ),
      Assessment(
        id: 'a-2',
        title: 'Mid-Check: Stochastic Optimization & SGD',
        courseCode: 'CS-881',
        subject: 'Machine Learning',
        timeLimitMinutes: 30,
        questionCount: 10,
        totalPoints: 30,
        engineMode: 'ADAPTIVE',
        status: 'SCHEDULED',
        scheduledLabel: 'SCHEDULED: OCT 28',
        meanScore: 74.0,
        turnInCount: 0,
        totalEnrolled: 88,
      ),
      Assessment(
        id: 'a-3',
        title: 'Diagnostic #3: Vector Spaces & Inner Products',
        courseCode: 'MATH-302',
        subject: 'Linear Algebra',
        timeLimitMinutes: 20,
        questionCount: 8,
        totalPoints: 24,
        engineMode: 'STANDARD',
        status: 'DRAFT',
        meanScore: 0.0,
        turnInCount: 0,
        totalEnrolled: 46,
      ),
    ];
  }
}
