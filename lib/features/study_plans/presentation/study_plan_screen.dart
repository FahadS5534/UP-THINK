import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../../shared/models/study_plan.dart';
import '../providers/study_plan_provider.dart';

/// Screen 4: Personalized Study Plan
class StudyPlanScreen extends ConsumerWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(studyPlanStateProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: planAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(studyPlanStateProvider.notifier).loadPlan(),
        ),
        data: (plan) => _buildPlanContent(context, ref, plan),
      ),
    );
  }

  Widget _buildPlanContent(BuildContext context, WidgetRef ref, StudyPlan plan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Regeneration Trigger
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                        Expanded(
                          child: Text(
                            plan.aiSyncInfo.toUpperCase(),
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              color: AppColors.textMediumContrast,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.title,
                      style: AppTypography.headlineLgMobile.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHighContrast,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Regenerate Plan Button
              InkWell(
                onTap: () => ref.read(studyPlanStateProvider.notifier).regeneratePlan(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_fix_high,
                        size: 15,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Regenerate',
                        style: AppTypography.labelMd.copyWith(
                          fontSize: 12,
                          color: AppColors.textHighContrast,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekly Progress Summary Card
          _buildWeeklyProgressCard(plan),
          const SizedBox(height: 18),

          // Timeline Flow Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "TODAY'S ADAPTIVE SEQUENCE",
                    style: AppTypography.labelMd.copyWith(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMediumContrast,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      plan.planningDate,
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Reorder',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Vertical Timeline Tasks
          ...plan.tasks.map((task) => _buildTimelineTaskTile(ref, task)),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard(StudyPlan plan) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainer.withValues(alpha: 0.9),
      padding: const EdgeInsets.all(16),
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
                    'WEEKLY TRAJECTORY',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMediumContrast,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      text: '${plan.completedHours}h ',
                      style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHighContrast,
                      ),
                      children: [
                        TextSpan(
                          text: '/ ${plan.targetHours}h target',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${plan.onTrackPercentage.toInt()}% On Track',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.remainingTimeText,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 11,
                      color: AppColors.textMediumContrast,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: plan.onTrackPercentage / 100.0,
              backgroundColor: AppColors.surfaceContainerLowest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // 7-day Dot Cadence Matrix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayDot('M', isCompleted: true),
              _buildDayDot('T', isCompleted: true),
              _buildDayDot('W', isCompleted: true),
              _buildDayDot('T', isToday: true, todayDayNumber: '24'),
              _buildDayDot('F', dayNumber: '25'),
              _buildDayDot('S', dayNumber: '26'),
              _buildDayDot('S', dayNumber: '27'),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Stat Pill Bar
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPill(Icons.checklist, '3 Tasks Left Today', AppColors.secondary),
              _buildPill(Icons.schedule, 'Est. 1h 45m', AppColors.primary),
              _buildPill(Icons.psychology, 'Spectral Theorem & SGD', AppColors.textMediumContrast),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayDot(
    String dayLabel, {
    bool isCompleted = false,
    bool isToday = false,
    String? dayNumber,
    String? todayDayNumber,
  }) {
    return Column(
      children: [
        Text(
          dayLabel,
          style: AppTypography.labelSm.copyWith(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppColors.primary : AppColors.textMediumContrast,
          ),
        ),
        const SizedBox(height: 4),
        if (isCompleted)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: AppColors.primary,
            ),
          )
        else if (isToday)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                todayDayNumber ?? '24',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          )
        else
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dayNumber ?? '25',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMediumContrast,
                  fontSize: 11,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPill(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              fontSize: 11,
              color: AppColors.textHighContrast,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTaskTile(WidgetRef ref, StudyTask task) {
    final isDone = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        onTap: () => ref.read(studyPlanStateProvider.notifier).toggleTask(task.id, task.isCompleted),
        backgroundColor: isDone
            ? AppColors.surfaceContainerLow.withValues(alpha: 0.7)
            : AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.taskTypeLabel,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                    ),
                    if (task.priority == StudyPriority.high) ...[
                      const SizedBox(width: 6),
                      const SeverityBadge(severity: GapSeverity.high, showDot: true),
                    ],
                  ],
                ),
                Text(
                  task.scheduledTime,
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 11,
                    color: task.priority == StudyPriority.high
                        ? AppColors.primary
                        : AppColors.textMediumContrast,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppColors.textMediumContrast
                              : AppColors.textHighContrast,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textMediumContrast,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Checkbox toggle
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDone ? AppColors.primary : AppColors.outline,
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.onPrimary,
                        )
                      : null,
                ),
              ],
            ),

            if (task.masteryNote != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.masteryNote!,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMediumContrast,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
