import '../../../core/widgets/severity_badge.dart';
import '../../../shared/models/learning_gap.dart';
import '../../../shared/services/supabase_service.dart';

/// Topic Diagnostic Detail with prerequisite dependency
class TopicRemediationItem {
  final LearningGap gap;
  final String prerequisiteName;
  final String prerequisiteNote;
  final String unlockedPathwaysText;

  const TopicRemediationItem({
    required this.gap,
    required this.prerequisiteName,
    required this.prerequisiteNote,
    required this.unlockedPathwaysText,
  });
}

/// Learning Gaps Diagnostic Overview
class LearningGapsOverview {
  final int totalGaps; // 4
  final int highRiskCount; // 2
  final int mediumRiskCount; // 1
  final int lowRiskCount; // 1
  final List<TopicRemediationItem> items;

  const LearningGapsOverview({
    required this.totalGaps,
    required this.highRiskCount,
    required this.mediumRiskCount,
    required this.lowRiskCount,
    required this.items,
  });
}

/// Repository for Learning Gaps Diagnostic
class LearningGapRepository {
  Future<LearningGapsOverview> getLearningGapsOverview() async {
    final client = SupabaseService.instance.client;

    if (client != null) {
      try {
        final res = await client.from('learning_gaps').select();
        final raw = res as List<dynamic>?;
        if (raw != null && raw.isNotEmpty) {
          final gaps = raw.map((g) => LearningGap.fromJson(g as Map<String, dynamic>)).toList();
          return _mapGapsToOverview(gaps);
        }
      } catch (_) {}
    }

    return _getDefaultOverview();
  }

  LearningGapsOverview _mapGapsToOverview(List<LearningGap> gaps) {
    int high = 0;
    int med = 0;
    int low = 0;

    final items = gaps.map((g) {
      if (g.severity == GapSeverity.high) high++;
      if (g.severity == GapSeverity.medium) med++;
      if (g.severity == GapSeverity.low) low++;

      return TopicRemediationItem(
        gap: g,
        prerequisiteName: 'Unit 4.2: Gram-Schmidt Process',
        prerequisiteNote: 'Direct predecessor deficiency (Estimated review: 14 mins)',
        unlockedPathwaysText: '2 Pathways Unlocked Upon Fix',
      );
    }).toList();

    return LearningGapsOverview(
      totalGaps: gaps.length,
      highRiskCount: high,
      mediumRiskCount: med,
      lowRiskCount: low,
      items: items,
    );
  }

  LearningGapsOverview _getDefaultOverview() {
    final defaultGaps = [
      const LearningGap(
        id: 'gap-1',
        topicName: 'Eigenvalues & Spectral Theorem',
        courseCode: 'MATH 302',
        nodeCode: 'Node #MATH-401',
        masteryPercentage: 42.0,
        severity: GapSeverity.high,
        diagnosis: 'Struggle with proofs of orthogonality. Prerequisite blocker for Quantum Physics & SVD.',
        recommendedAction: 'Launch Targeted Remediation',
        recentQuizScore: 'Score: 2/5 (Quiz 3)',
        trendPercentage: -4.0,
        blockerDetails: 'Critical Blocker',
      ),
      const LearningGap(
        id: 'gap-2',
        topicName: 'Stochastic Gradient Descent',
        courseCode: 'CS 881',
        nodeCode: 'Node #CS-502',
        masteryPercentage: 54.0,
        severity: GapSeverity.high,
        diagnosis: 'Saddle-point escape conditions and negative Hessian eigenvalues in non-convex optimization.',
        recommendedAction: 'Targeted Remediation',
        recentQuizScore: 'Score: 3/6',
        trendPercentage: -2.0,
        blockerDetails: 'Foundation Blocker',
      ),
      const LearningGap(
        id: 'gap-3',
        topicName: 'Bayesian Inference & Priors',
        courseCode: 'STAT 410',
        nodeCode: 'Node #STAT-410',
        masteryPercentage: 64.0,
        severity: GapSeverity.medium,
        diagnosis: 'Confusion between conjugate priors and posterior calculation in continuous distributions.',
        recommendedAction: 'Practice Drills',
        recentQuizScore: 'Score: 4/6',
        trendPercentage: 7.0,
        blockerDetails: 'Intermediate Dependency',
      ),
      const LearningGap(
        id: 'gap-4',
        topicName: 'Vector Spaces & Nullity',
        courseCode: 'MATH 302',
        nodeCode: 'Node #MATH-305',
        masteryPercentage: 72.0,
        severity: GapSeverity.low,
        diagnosis: 'Minor calculation slips during rank-nullity theorem verification under timed pressure.',
        recommendedAction: 'Review Notes',
        recentQuizScore: 'Score: 5/6',
        trendPercentage: 11.0,
        blockerDetails: 'Low Risk',
      ),
    ];

    return LearningGapsOverview(
      totalGaps: 4,
      highRiskCount: 2,
      mediumRiskCount: 1,
      lowRiskCount: 1,
      items: defaultGaps.map((g) {
        return TopicRemediationItem(
          gap: g,
          prerequisiteName: g.id == 'gap-1'
              ? 'Unit 4.2: Gram-Schmidt Process'
              : 'Unit 3.1: Vector Calculus & Jacobians',
          prerequisiteNote: 'Direct predecessor deficiency (Estimated review: 14 mins)',
          unlockedPathwaysText: '2 Pathways Unlocked Upon Fix',
        );
      }).toList(),
    );
  }
}
