import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/mastery_bar.dart';
import '../../../core/widgets/progress_ring.dart';
import '../data/assessment_repository.dart';
import '../providers/assessment_provider.dart';

/// Screen 6: Assessment Diagnostic Results
class AssessmentResultsScreen extends ConsumerWidget {
  final String assessmentId;

  const AssessmentResultsScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(assessmentResultsProvider(assessmentId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ASSESSMENT REVIEW',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'Student Results & Review',
              style: AppTypography.headlineSm.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHighContrast,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: resultsAsync.when(
        loading: () => const LoadingView(message: 'Computing aggregate diagnostic topology...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(assessmentResultsProvider(assessmentId)),
        ),
        data: (results) => _buildResultsContent(context, results),
      ),
    );
  }

  Widget _buildResultsContent(BuildContext context, AssessmentResultsData results) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session Meta Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Session #402-A Completed • Evaluated via Gemini',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'LINEAR ALG. II',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.outline,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hero Score Panel
          _buildHeroScorePanel(results),
          const SizedBox(height: 18),

          // Knowledge Topology Impact
          _buildTopologyImpactSection(results),
          const SizedBox(height: 18),

          // Identified Cognitive Gap Spotlight
          _buildCognitiveGapSection(results.cognitiveGap),
          const SizedBox(height: 18),

          // Adaptive Remediation Ready Card
          _buildAdaptiveRemediationCard(),
          const SizedBox(height: 20),

          // Actionable Next Steps
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeroScorePanel(AssessmentResultsData results) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(18),
      hasGlow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGGREGATE MASTERY RATING',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMediumContrast,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${results.aggregateMastery}%',
                        style: AppTypography.metricNumeral.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up,
                              size: 13,
                              color: AppColors.onPrimary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+${results.baselineDelta}% vs baseline',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Ring Chart
              ProgressRing(
                value: results.correctCount / results.totalCount,
                size: 76,
                strokeWidth: 7,
                progressColor: AppColors.primary,
                trackColor: AppColors.surfaceContainerHighest,
                centerLabel: '${results.correctCount}',
                centerSubLabel: 'of ${results.totalCount}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metric Breakdown Bar (3 columns)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACCURACY',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.8,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          text: '${results.correctCount} ',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHighContrast,
                          ),
                          children: [
                            TextSpan(
                              text: '/ ${results.errorCount} err',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.textMediumContrast,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.glassBorder),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DURATION',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.8,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        results.durationText,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.glassBorder),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPEED RANK',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.8,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          text: '${results.speedRank}',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHighContrast,
                          ),
                          children: [
                            TextSpan(
                              text: 'th',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textMediumContrast,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyImpactSection(AssessmentResultsData results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.account_tree_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'KNOWLEDGE TOPOLOGY IMPACT',
                  style: AppTypography.labelMd.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textHighContrast,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Text(
              '${results.domains.length} Domains Indexed',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textLowContrast,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...results.domains.map((item) {
          final color = Color(int.parse(item.colorHex.replaceFirst('#', '0xFF')));

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassPanel(
              backgroundColor: AppColors.surfaceContainer,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.domain,
                            style: AppTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHighContrast,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: AppTypography.labelSm.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MasteryBar(
                    percentage: item.percentage.toDouble(),
                    height: 5,
                    barColor: color,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.note,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textMediumContrast,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCognitiveGapSection(CognitiveGapDetail gap) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainer,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'IDENTIFIED COGNITIVE GAP',
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHighContrast,
                      letterSpacing: 0.8,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PREREQUISITE BLOCK',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      gap.nodeCode,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      gap.topologyDepth,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  gap.title,
                  style: AppTypography.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHighContrast,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.subdirectory_arrow_right,
                      size: 14,
                      color: AppColors.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        gap.description,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveRemediationCard() {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainer,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_fix_high,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adaptive Remediation Ready',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHighContrast,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Targeted synthetic modules calibrated to isolate Hessian eigenvalues and stochastic perturbation trajectories.',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.textMediumContrast,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary CTA: Generate Adaptive Study Plan
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/plan'),
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Generate Adaptive Study Plan',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Secondary CTA: Review Answers
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: () => context.go('/learn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.textHighContrast,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.rule,
                      size: 16,
                      color: AppColors.textMediumContrast,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Review All 12 Answers & Explanations',
                      style: AppTypography.labelMd.copyWith(
                        color: AppColors.textHighContrast,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textMediumContrast,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
