import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/mastery_bar.dart';
import '../../../core/widgets/severity_badge.dart';
import '../data/learning_gap_repository.dart';
import '../providers/learning_gaps_provider.dart';

/// Screen 3: Learning Gaps Diagnostic
class LearningGapsScreen extends ConsumerStatefulWidget {
  const LearningGapsScreen({super.key});

  @override
  ConsumerState<LearningGapsScreen> createState() => _LearningGapsScreenState();
}

class _LearningGapsScreenState extends ConsumerState<LearningGapsScreen> {
  String _activeFilter = 'all'; // all, high, medium, low
  final Set<String> _expandedCards = {'gap-1'};

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(learningGapsOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: overviewAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(learningGapsOverviewProvider),
        ),
        data: (data) => _buildContent(data),
      ),
    );
  }

  Widget _buildContent(LearningGapsOverview data) {
    final filteredItems = data.items.where((item) {
      if (_activeFilter == 'high') return item.gap.severity == GapSeverity.high;
      if (_activeFilter == 'medium') return item.gap.severity == GapSeverity.medium;
      if (_activeFilter == 'low') return item.gap.severity == GapSeverity.low;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topology Header Card
          _buildTopologyHeaderCard(data),
          const SizedBox(height: 14),

          // Filter Segmented Controls
          _buildFilterSegmentedControls(data),
          const SizedBox(height: 14),

          // Diagnostic Mastery Chart (Horizontal Bars + 75% Goal Marker)
          _buildDiagnosticMasteryChart(data),
          const SizedBox(height: 14),

          // Interactive Hint Callout
          _buildHintCallout(),
          const SizedBox(height: 14),

          // Topic Remediation Cards Stack
          ...filteredItems.map((item) => _buildRemediationCard(item)),
        ],
      ),
    );
  }

  Widget _buildTopologyHeaderCard(LearningGapsOverview data) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(14),
      child: Column(
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
                    'ACTIVE KNOWLEDGE TOPOLOGY',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                'Session #402-A',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMediumContrast,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4-Column Diagnostic Summary Counters
          Row(
            children: [
              _buildCounterTile('Total Gaps', data.totalGaps.toString(), AppColors.textHighContrast),
              const SizedBox(width: 8),
              _buildCounterTile('High Risk', data.highRiskCount.toString(), AppColors.highRisk),
              const SizedBox(width: 8),
              _buildCounterTile('Medium', data.mediumRiskCount.toString(), AppColors.mediumRisk),
              const SizedBox(width: 8),
              _buildCounterTile('Low Risk', data.lowRiskCount.toString(), AppColors.lowRisk),
            ],
          ),
          const SizedBox(height: 14),

          // Prerequisite Vector Node Mini Graphic Row
          Row(
            children: [
              CustomPaint(
                size: const Size(36, 36),
                painter: _PrerequisiteNodePainter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Graph Topology Delta',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHighContrast,
                      ),
                    ),
                    Text(
                      'Prerequisite blocking critical path detected',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11,
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_tree_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MAP',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headlineSm.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: AppTypography.labelSm.copyWith(
                fontSize: 9,
                color: color.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSegmentedControls(LearningGapsOverview data) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildFilterTab('all', 'All (${data.totalGaps})'),
          _buildFilterTab('high', 'High (${data.highRiskCount})'),
          _buildFilterTab('medium', 'Med (${data.mediumRiskCount})'),
          _buildFilterTab('low', 'Low (${data.lowRiskCount})'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String id, String label) {
    final isActive = _activeFilter == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeFilter = id),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.onPrimary : AppColors.textMediumContrast,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticMasteryChart(LearningGapsOverview data) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(14),
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
                    'Diagnostic Mastery',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHighContrast,
                    ),
                  ),
                  Text(
                    'Ranked relative to institutional threshold',
                    style: AppTypography.bodySm.copyWith(
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
                    '75% Target',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: AppColors.textMediumContrast,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Bars
          ...data.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TopicMasteryRow(
                title: item.gap.topicName,
                percentage: item.gap.masteryPercentage,
                delta: item.gap.trendPercentage,
                color: item.gap.severity == GapSeverity.high
                    ? AppColors.highRisk
                    : item.gap.severity == GapSeverity.medium
                        ? AppColors.mediumRisk
                        : AppColors.lowRisk,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHintCallout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tap any topic card below to inspect prerequisite graph and adaptive drills.',
              style: AppTypography.bodySm.copyWith(
                fontSize: 11,
                color: AppColors.textMediumContrast,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemediationCard(TopicRemediationItem item) {
    final gap = item.gap;
    final isExpanded = _expandedCards.contains(gap.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedCards.remove(gap.id);
            } else {
              _expandedCards.add(gap.id);
            }
          });
        },
        backgroundColor: AppColors.surfaceContainerLow,
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
                        gap.nodeCode.toUpperCase(),
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.textMediumContrast,
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
                      ),
                    ],
                  ),
                ),
                SeverityBadge(
                  severity: gap.severity,
                  customLabel: '${gap.severity.name.toUpperCase()} RISK · ${gap.masteryPercentage.toInt()}%',
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Metrics strip
            Row(
              children: [
                const Icon(
                  Icons.history_edu,
                  size: 14,
                  color: AppColors.textMediumContrast,
                ),
                const SizedBox(width: 4),
                Text(
                  gap.recentQuizScore ?? 'Score: 2/5',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    color: AppColors.textHighContrast,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (gap.blockerDetails != null) ...[
                  const SizedBox(width: 14),
                  Icon(
                    Icons.block,
                    size: 14,
                    color: gap.severity == GapSeverity.high ? AppColors.highRisk : AppColors.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gap.blockerDetails!,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 11,
                      color: gap.severity == GapSeverity.high ? AppColors.highRisk : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Diagnosis Box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: RichText(
                text: TextSpan(
                  text: 'Diagnosis: ',
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: gap.diagnosis,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w400,
                        color: AppColors.textHighContrast,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Launch Targeted Remediation Button
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/quiz/a0000000-0000-0000-0000-000000000001'),
                icon: const Icon(Icons.bolt, size: 18),
                label: Text(
                  gap.recommendedAction,
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
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

            // Expandable Prerequisite Graph Detail
            if (isExpanded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DEPENDENCY GRAPH',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        Text(
                          item.unlockedPathwaysText,
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.prerequisiteName,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHighContrast,
                      ),
                    ),
                    Text(
                      item.prerequisiteNote,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11,
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrerequisiteNodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final ring = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final limeFill = Paint()..color = AppColors.primary;
    final amberFill = Paint()..color = AppColors.secondary;

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.45, ring);
    canvas.drawCircle(Offset(w * 0.5, h * 0.2), 3, limeFill);
    canvas.drawCircle(Offset(w * 0.2, h * 0.5), 3, limeFill);
    canvas.drawCircle(Offset(w * 0.8, h * 0.5), 3, limeFill);
    canvas.drawCircle(Offset(w * 0.5, h * 0.8), 3, amberFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
