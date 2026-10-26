import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../shared/models/cohort.dart';
import '../providers/facilitator_provider.dart';

/// Screen 7: Facilitator Cohort Dashboard
class FacilitatorDashboardScreen extends ConsumerStatefulWidget {
  final String cohortId;

  const FacilitatorDashboardScreen({
    super.key,
    this.cohortId = 'c0000000-0000-0000-0000-000000000001',
  });

  @override
  ConsumerState<FacilitatorDashboardScreen> createState() => _FacilitatorDashboardScreenState();
}

class _FacilitatorDashboardScreenState extends ConsumerState<FacilitatorDashboardScreen> {
  bool _isDropdownOpen = false;
  String _selectedSection = 'Fall 2025 • Section B';

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(facilitatorCohortAnalyticsProvider(widget.cohortId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: analyticsAsync.when(
        loading: () => const LoadingView(message: 'Compiling faculty cohort matrix...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(facilitatorCohortAnalyticsProvider(widget.cohortId)),
        ),
        data: (cohort) => _buildDashboardContent(context, cohort),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, CohortData cohort) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cohort Context Switcher & Sub-Header
          _buildCohortSwitcher(cohort),
          const SizedBox(height: 16),

          // Key Metrics (2x2 Grid)
          _buildMetricsGrid(cohort),
          const SizedBox(height: 16),

          // Interactive Score Distribution Chart
          _buildScoreSpreadChart(cohort),
          const SizedBox(height: 18),

          // Critical Class-Wide Learning Gaps Section
          _buildCriticalGapsSection(context),
        ],
      ),
    );
  }

  Widget _buildCohortSwitcher(CohortData cohort) {
    return Column(
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
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'COHORT ANALYTICS • ${cohort.code}',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Live Sync',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10,
                  color: AppColors.textMediumContrast,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dropdown Selector Button
        InkWell(
          onTap: () => setState(() => _isDropdownOpen = !_isDropdownOpen),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSection,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                      Text(
                        '${cohort.totalEnrolled} Students • ${cohort.name}',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textMediumContrast,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Dropdown Sheet
        if (_isDropdownOpen) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Fall 2025 • Section B';
                      _isDropdownOpen = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fall 2025 • Section B',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '46 Enrolled (Current View)',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                                color: AppColors.textMediumContrast,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSection = 'Fall 2025 • Section A';
                      _isDropdownOpen = false;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fall 2025 • Section A',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.textHighContrast,
                              ),
                            ),
                            Text(
                              '42 Enrolled • Morning Studio',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                                color: AppColors.textMediumContrast,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'MATH-302',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(CohortData cohort) {
    return Column(
      children: [
        Row(
          children: [
            // Card 1: Class Avg Mastery
            Expanded(
              child: GlassPanel(
                backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AVG MASTERY',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const Icon(
                          Icons.equalizer,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cohort.avgMastery}%',
                      style: AppTypography.headlineLgMobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHighContrast,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            '${cohort.masteryChange}%',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              color: AppColors.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'vs past wk',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 10,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Benchmark Completion
            Expanded(
              child: GlassPanel(
                backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COMPLETION',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const Icon(
                          Icons.task_alt,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cohort.completionRate}%',
                      style: AppTypography.headlineLgMobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cohort.submittedCount} of ${cohort.totalEnrolled} submitted',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 10,
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 3: Action Req.
            Expanded(
              child: GlassPanel(
                backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACTION REQ.',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.highRisk,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        text: '${cohort.actionRequiredCount} ',
                        style: AppTypography.headlineLgMobile.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.highRisk,
                        ),
                        children: [
                          TextSpan(
                            text: 'nodes',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textMediumContrast,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.highRiskBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CRITICAL FLAG',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          color: AppColors.highRisk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Card 4: Retention
            Expanded(
              child: GlassPanel(
                backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RETENTION',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const Icon(
                          Icons.psychology_outlined,
                          size: 16,
                          color: AppColors.tertiaryFixed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${cohort.retentionRate}%',
                      style: AppTypography.headlineLgMobile.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHighContrast,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '14-day memory trace',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 10,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreSpreadChart(CohortData cohort) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cohort Score Spread',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHighContrast,
                    ),
                  ),
                ],
              ),
              Text(
                'n=${cohort.totalEnrolled} calibrated',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 11,
                  color: AppColors.textMediumContrast,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom 4-Column Bar Graph
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: cohort.scoreDistribution.map((b) {
                final color = Color(int.parse(b.colorHex.replaceFirst('#', '0xFF')));

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${b.percentage.toInt()}%',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 36,
                        height: 70 * (b.percentage / 45.0),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.label,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.highRisk,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Remedial Need: 7',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 11,
                      color: AppColors.textMediumContrast,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Peak Velocity: 19',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 11,
                      color: AppColors.textMediumContrast,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalGapsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.domain_verification_outlined,
                  size: 18,
                  color: AppColors.highRisk,
                ),
                const SizedBox(width: 6),
                Text(
                  'Critical Gaps',
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHighContrast,
                  ),
                ),
              ],
            ),
            Text(
              'RANKED BY FAILURE',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
                letterSpacing: 0.8,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gap 1
        GlassPanel(
          backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.highRiskBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'RANK #1 GAP',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.highRisk,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: AppColors.highRisk,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '48% Cohort Failure',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.highRisk,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Eigenvalues & Spectral Theorem',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Identified Invariant Subspace Drift in timed proofs.',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMediumContrast,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/authoring'),
                  icon: const Icon(Icons.bolt, size: 16),
                  label: const Text('Deploy Socratic Drill'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
