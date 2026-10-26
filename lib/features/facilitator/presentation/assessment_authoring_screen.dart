import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../shared/models/assessment.dart';
import '../providers/facilitator_provider.dart';

/// Screen 8: Assessment Management and Authoring
class AssessmentAuthoringScreen extends ConsumerStatefulWidget {
  const AssessmentAuthoringScreen({super.key});

  @override
  ConsumerState<AssessmentAuthoringScreen> createState() => _AssessmentAuthoringScreenState();
}

class _AssessmentAuthoringScreenState extends ConsumerState<AssessmentAuthoringScreen> {
  String _activeTab = 'active'; // active, drafts, archive
  String _selectedCorrectOption = 'B';
  final TextEditingController _stemController = TextEditingController(
    text: r'Given a matrix A ∈ ℝⁿˣⁿ, under what exact spectral decomposition constraints does A = Q Λ Qᵀ hold where Q is strictly orthogonal?',
  );

  @override
  void dispose() {
    _stemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assessmentsAsync = ref.watch(facilitatorAssessmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: assessmentsAsync.when(
        loading: () => const LoadingView(message: 'Loading assessment enclave...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(facilitatorAssessmentsProvider),
        ),
        data: (assessments) => _buildContent(assessments),
      ),
    );
  }

  Widget _buildContent(List<Assessment> assessments) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-bar & Quick Creator Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tune,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assessment Enclave',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHighContrast,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authoring wizard initialized.'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Assessment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented State Switcher (Active, Drafts, Archived)
          _buildSegmentedSwitcher(),
          const SizedBox(height: 16),

          // Active Assessments Stack
          ...assessments.map((a) => _buildAssessmentCard(a)),
          const SizedBox(height: 18),

          // Embedded Rapid Assessment Authoring Preview Card
          _buildAuthoringCard(),
        ],
      ),
    );
  }

  Widget _buildSegmentedSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabBtn('active', 'Active', '4'),
          _buildTabBtn('drafts', 'Drafts', '2'),
          _buildTabBtn('archive', 'Archived', '8'),
        ],
      ),
    );
  }

  Widget _buildTabBtn(String id, String label, String count) {
    final isActive = _activeTab == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = id),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surfaceContainerHighest : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.textHighContrast : AppColors.textMediumContrast,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 10,
                    color: isActive ? AppColors.primary : AppColors.textMediumContrast,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(Assessment a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        backgroundColor: AppColors.surfaceContainer,
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: a.isLive
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.secondaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (a.isLive) ...[
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  a.scheduledLabel?.toUpperCase() ??
                                      (a.isLive ? 'LIVE NOW' : 'SCHEDULED'),
                                  style: AppTypography.labelSm.copyWith(
                                    color: a.isLive ? AppColors.primary : AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            a.courseCode,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.textMediumContrast,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.title,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 18),
                  color: AppColors.textMediumContrast,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Statistics Grid (3 Columns)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TURN-IN',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 9,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: '${a.turnInCount} ',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            children: [
                              TextSpan(
                                text: '/${a.totalEnrolled}',
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MEAN SCORE',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 9,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${a.meanScore}%',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textHighContrast,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FORMAT',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 9,
                            color: AppColors.textMediumContrast,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${a.questionCount} Questions',
                          style: AppTypography.bodySm.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textHighContrast,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Actions row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.group, size: 16),
                    label: const Text('View Cohort Breakdown'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceContainerHighest,
                      foregroundColor: AppColors.textHighContrast,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.ios_share, size: 18),
                  color: AppColors.textMediumContrast,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthoringCard() {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
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
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Question Authoring',
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHighContrast,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Question #5 (Draft)',
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 10,
                    color: AppColors.textMediumContrast,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Prompt Stem
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROMPT & MATHEMATICAL STEM',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10,
                  color: AppColors.textMediumContrast,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.code, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'LaTeX Raw',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _stemController,
              maxLines: 3,
              style: AppTypography.bodyMd.copyWith(color: AppColors.textHighContrast),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Options & Key Formulation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'OPTIONS & KEY FORMULATION',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10,
                  color: AppColors.textMediumContrast,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'Single correct key',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          _buildAuthoringOption('A', 'Matrix A has n linearly independent real eigenvectors'),
          _buildAuthoringOption('B', 'Matrix A is symmetric, i.e., A = Aᵀ with real entries'),
          _buildAuthoringOption('C', 'Matrix A has purely non-zero singular values (det(A) ≠ 0)'),
          const SizedBox(height: 14),

          // Save / Publish Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Draft saved to session.')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.glassBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Save Draft',
                    style: AppTypography.labelMd.copyWith(color: AppColors.textHighContrast),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Assessment published to Section B.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Publish',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthoringOption(String key, String text) {
    final isSelected = _selectedCorrectOption == key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedCorrectOption = key),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.onPrimary : AppColors.textHighContrast,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textHighContrast,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.verified,
                  size: 16,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
