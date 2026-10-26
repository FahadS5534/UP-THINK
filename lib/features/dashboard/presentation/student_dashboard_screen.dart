import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../providers/dashboard_provider.dart';

/// Screen 1: Student Dashboard
class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(studentDashboardProvider);
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.value ?? AuthRepository.getDemoStudent();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: dashboardAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(studentDashboardProvider),
        ),
        data: (data) => _buildDashboardContent(context, user.fullName, data),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    String userName,
    DashboardOverview data,
  ) {
    final firstName = userName.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Greeting & Live Model Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THURSDAY, OCT 24',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textMediumContrast,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Good morning, $firstName',
                      style: AppTypography.headlineLgMobile.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHighContrast,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Live Model Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x99C8F169),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE MODEL',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Card: Computational Diagnostic
          _buildHeroCard(context, data),
          const SizedBox(height: 20),

          // Section: Needs your attention
          _buildNeedsAttentionSection(context, data),
          const SizedBox(height: 20),

          // Section: Continue Learning (Next Recommended Task)
          _buildContinueLearningSection(context, data),
          const SizedBox(height: 20),

          // Section: Weekly Learning Activity
          _buildWeeklyActivitySection(data),
          const SizedBox(height: 20),

          // Bottom Preview of Upcoming Assessment
          _buildUpcomingAssessmentCard(context, data),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, DashboardOverview data) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      hasGlow: true,
      backgroundColor: AppColors.surfaceContainer.withValues(alpha: 0.90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMPUTATIONAL DIAGNOSTIC',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your learning, decoded.',
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHighContrast,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.query_stats,
                size: 20,
                color: AppColors.textMediumContrast,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Ring & Metric Summary Layout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Circular Progress Ring
                ProgressRing(
                  value: data.overallMastery / 100.0,
                  size: 88,
                  strokeWidth: 8,
                  progressColor: AppColors.primary,
                  trackColor: AppColors.surfaceContainerHighest,
                  centerLabel: '${data.overallMastery.toStringAsFixed(1)}%',
                  centerSubLabel: 'SCORE',
                ),
                const SizedBox(width: 16),

                // Core Progress Metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Topics Mastered',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textMediumContrast,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          RichText(
                            text: TextSpan(
                              text: '${data.topicsMastered} ',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textHighContrast,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: '/ ${data.totalTopics}',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textMediumContrast,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: data.topicsMastered / data.totalTopics,
                          backgroundColor: AppColors.surfaceContainerHighest,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Requires Action',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textMediumContrast,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.highRiskBg,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${data.criticalActionsCount} Critical',
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 10,
                                color: AppColors.highRisk,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Today's Target",
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textMediumContrast,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          RichText(
                            text: TextSpan(
                              text: '${data.todayMinutesDone}m ',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.secondaryFixed,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              children: [
                                TextSpan(
                                  text: '/ ${data.todayTargetMinutes}m',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.textMediumContrast,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Micro Trajectory Visualizer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+${data.velocityVsCohort}% velocity vs. cohort',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMediumContrast,
                    ),
                  ),
                ],
              ),
              // Mini sparkline graphic
              CustomPaint(
                size: const Size(80, 20),
                painter: _SparklinePainter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsAttentionSection(BuildContext context, DashboardOverview data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.highRisk,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Needs your attention',
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHighContrast,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${data.attentionGaps.length} pending',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gap Cards
        ...data.attentionGaps.map((gap) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassPanel(
              onTap: () => context.go('/learn'),
              backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gap.courseCode.toUpperCase(),
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textMediumContrast,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              gap.topicName,
                              style: AppTypography.headlineSm.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textHighContrast,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SeverityBadge(severity: gap.severity),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Cognitive diagnosis callout box
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          gap.severity == GapSeverity.high ? Icons.troubleshoot : Icons.psychology,
                          size: 16,
                          color: gap.severity == GapSeverity.high
                              ? AppColors.highRisk
                              : AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Cognitive Diagnosis: ',
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textHighContrast,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: gap.diagnosis,
                                  style: AppTypography.bodySm.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textMediumContrast,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mastery percentage & action button
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mastery',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10,
                                  color: AppColors.textMediumContrast,
                                ),
                              ),
                              Text(
                                '${gap.masteryPercentage.toInt()}%',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: gap.severity == GapSeverity.high
                                      ? AppColors.highRisk
                                      : AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 64,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: gap.masteryPercentage / 100.0,
                                backgroundColor: AppColors.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  gap.severity == GapSeverity.high
                                      ? AppColors.highRisk
                                      : AppColors.secondary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Action button
                      ElevatedButton(
                        onPressed: () => context.go('/tutor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gap.severity == GapSeverity.high
                              ? AppColors.primary
                              : AppColors.surfaceContainerHighest,
                          foregroundColor: gap.severity == GapSeverity.high
                              ? AppColors.onPrimary
                              : AppColors.textHighContrast,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              gap.recommendedAction,
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: gap.severity == GapSeverity.high
                                    ? AppColors.onPrimary
                                    : AppColors.textHighContrast,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              gap.severity == GapSeverity.high
                                  ? Icons.arrow_forward
                                  : Icons.tune,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContinueLearningSection(BuildContext context, DashboardOverview data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue learning',
              style: AppTypography.headlineSm.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textHighContrast,
              ),
            ),
            Text(
              'NEXT UP',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        GlassPanel(
          onTap: () => context.go('/quiz/a0000000-0000-0000-0000-000000000001'),
          backgroundColor: AppColors.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ACTIVE SESSION',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.tertiaryFixed,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.textMediumContrast,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '25 mins left',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.continueLearningTask.title,
                style: AppTypography.headlineMd.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.continueLearningTask.description,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textMediumContrast,
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.hub_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '8 concepts covered',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.textHighContrast,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66C8F169),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.onPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyActivitySection(DashboardOverview data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Weekly Learning Activity',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHighContrast,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '312 total mins',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        GlassPanel(
          backgroundColor: AppColors.surfaceContainer.withValues(alpha: 0.7),
          child: Column(
            children: [
              // 7-day Bar Chart
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.weeklyActivity.map((day) {
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (day.isPeak) ...[
                            Text(
                              '${day.minutes}m',
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Container(
                            width: 26,
                            height: 70 * day.percentage,
                            decoration: BoxDecoration(
                              color: day.isPeak
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              boxShadow: day.isPeak
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            day.day,
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
                              color: day.isToday
                                  ? AppColors.primary
                                  : AppColors.textMediumContrast,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Legend
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                        'Target attained (>60m)',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.textMediumContrast,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Optimal focus: 10:00 - 11:30 AM',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textHighContrast,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAssessmentCard(BuildContext context, DashboardOverview data) {
    return GlassPanel(
      onTap: () => context.go('/quiz/a0000000-0000-0000-0000-000000000001'),
      backgroundColor: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'IN 3 DAYS',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.secondaryFixed,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.outline,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Oct 27',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.textMediumContrast,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data.upcomingAssessmentTitle,
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHighContrast,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textMediumContrast,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.85);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.1);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
