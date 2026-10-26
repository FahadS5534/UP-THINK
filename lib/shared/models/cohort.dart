/// Score Spread Distribution Bucket
class ScoreDistributionBucket {
  final String label; // <50%, 50-70%, 70-85%, >85%
  final double percentage; // e.g. 15, 28, 41, 16
  final String colorHex;
  final int studentCount;

  const ScoreDistributionBucket({
    required this.label,
    required this.percentage,
    required this.colorHex,
    required this.studentCount,
  });
}

/// Upthink Cohort Analytics Model
class CohortData {
  final String id;
  final String code; // MATH-302
  final String section; // Section B
  final String name; // Machine Learning Foundry
  final int totalEnrolled; // 46
  final double avgMastery; // 71.4%
  final double masteryChange; // -2.1%
  final double completionRate; // 93.5%
  final int submittedCount; // 43
  final int actionRequiredCount; // 7
  final double retentionRate; // 84.2%
  final List<ScoreDistributionBucket> scoreDistribution;

  const CohortData({
    required this.id,
    required this.code,
    required this.section,
    required this.name,
    required this.totalEnrolled,
    required this.avgMastery,
    required this.masteryChange,
    required this.completionRate,
    required this.submittedCount,
    required this.actionRequiredCount,
    required this.retentionRate,
    required this.scoreDistribution,
  });

  factory CohortData.defaultCohort() {
    return const CohortData(
      id: 'c0000000-0000-0000-0000-000000000001',
      code: 'MATH-302',
      section: 'Section B',
      name: 'Machine Learning Foundry',
      totalEnrolled: 46,
      avgMastery: 71.4,
      masteryChange: -2.1,
      completionRate: 93.5,
      submittedCount: 43,
      actionRequiredCount: 7,
      retentionRate: 84.2,
      scoreDistribution: [
        ScoreDistributionBucket(label: '<50%', percentage: 15, colorHex: '#E98278', studentCount: 7),
        ScoreDistributionBucket(label: '50-70%', percentage: 28, colorHex: '#E6BC72', studentCount: 13),
        ScoreDistributionBucket(label: '70-85%', percentage: 41, colorHex: '#C8F169', studentCount: 19),
        ScoreDistributionBucket(label: '>85%', percentage: 16, colorHex: '#CCEDAC', studentCount: 7),
      ],
    );
  }
}
