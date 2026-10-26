import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../shared/models/assessment.dart';
import '../providers/assessment_provider.dart';

/// Screen 5: Interactive Quiz and Diagnostic Assessment
class QuizAssessmentScreen extends ConsumerWidget {
  final String assessmentId;

  const QuizAssessmentScreen({
    super.key,
    required this.assessmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(assessmentQuestionsProvider(assessmentId));
    final quizState = ref.watch(activeQuizProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: questionsAsync.when(
        loading: () => const LoadingView(message: 'Initializing diagnostic enclave...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(assessmentQuestionsProvider(assessmentId)),
        ),
        data: (questions) {
          if (questions.isEmpty) {
            return const EmptyStateView(
              title: 'No Questions Found',
              description: 'This diagnostic has no questions authored yet.',
            );
          }

          final currentIndex = quizState.currentQuestionIndex.clamp(0, questions.length - 1);
          final currentQuestion = questions[currentIndex];
          final currentNumber = currentIndex + 1;
          final totalCount = questions.length;
          final progress = currentNumber / totalCount;
          final isFlagged = quizState.flaggedQuestions.contains(currentQuestion.id);
          final selectedOption = quizState.selectedAnswers[currentQuestion.id];

          return SafeArea(
            child: Column(
              children: [
                // Assessment Top Header with Close & Timer
                _buildHeader(context, progress),

                // Question Content Scrollable Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      // Question Metatools Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'QUESTION',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textMediumContrast,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  currentNumber.toString().padLeft(2, '0'),
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '/ $totalCount',
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textLowContrast,
                                ),
                              ),
                            ],
                          ),
                          // Flag for Review Button
                          InkWell(
                            onTap: () => ref
                                .read(activeQuizProvider.notifier)
                                .toggleFlag(currentQuestion.id),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isFlagged
                                    ? AppColors.secondaryContainer
                                    : AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isFlagged
                                      ? AppColors.secondary
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bookmark,
                                    size: 15,
                                    color: isFlagged
                                        ? AppColors.secondary
                                        : AppColors.textMediumContrast,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isFlagged
                                        ? 'Flagged (#${currentNumber.toString().padLeft(2, '0')})'
                                        : 'Flag for review',
                                    style: AppTypography.labelSm.copyWith(
                                      color: isFlagged
                                          ? AppColors.secondary
                                          : AppColors.textMediumContrast,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Primary Question Editorial Panel
                      _buildQuestionCard(currentQuestion),
                      const SizedBox(height: 14),

                      // Multiple Choice Options Matrix
                      ...currentQuestion.options.map((option) {
                        final isSelected = selectedOption == option.id;
                        return _buildOptionTile(
                          ref,
                          currentQuestion.id,
                          option.id,
                          option.text,
                          isSelected,
                        );
                      }),
                      const SizedBox(height: 14),

                      // Editorial Visual Proof Anchor
                      _buildVisualProofAnchor(),
                      const SizedBox(height: 14),

                      // Question Grid Matrix Drawer
                      _buildMatrixDrawer(ref, questions, currentIndex),
                      const SizedBox(height: 16),

                      // Bottom Navigation Actions
                      _buildBottomActions(context, ref, currentIndex, totalCount),
                      const SizedBox(height: 12),

                      // Autosave Banner
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Answers autosaved to session enclave • 14:22',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double progress) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/learn'),
                    icon: const Icon(Icons.close, size: 22),
                    color: AppColors.textMediumContrast,
                    tooltip: 'Exit assessment',
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASSESSMENT IN PROGRESS',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        'Student Quiz / Assessment',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textHighContrast,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Timer Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '14:20',
                      style: AppTypography.labelMd.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Progress Track
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.surfaceContainerHigh,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 3,
        ),
      ],
    );
  }

  Widget _buildQuestionCard(AssessmentQuestion question) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow.withValues(alpha: 0.95),
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
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    question.topicTag.toUpperCase(),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMediumContrast,
                      letterSpacing: 0.8,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${question.points} Points',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.promptStem,
            style: AppTypography.bodyLg.copyWith(
              color: AppColors.textHighContrast,
              height: 1.5,
            ),
          ),
          if (question.formalHypothesis != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FORMAL HYPOTHESIS',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9,
                          color: AppColors.textMediumContrast,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Icon(
                        Icons.functions,
                        size: 14,
                        color: AppColors.textMediumContrast,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.formalHypothesis!,
                    style: AppTypography.bodyMd.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.textHighContrast,
                    ),
                  ),
                  if (question.proofHint != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      question.proofHint!,
                      style: AppTypography.labelSm.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.primaryFixedDim,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    WidgetRef ref,
    String questionId,
    String optionId,
    String text,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => ref
            .read(activeQuizProvider.notifier)
            .selectOption(questionId, optionId),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'OPTION $optionId',
                          style: AppTypography.labelSm.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textLowContrast,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'ACTIVE CHOICE',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textHighContrast,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualProofAnchor() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(40, 40),
            painter: _ProofVectorPainter(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORTHOGONALITY LEMMA',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '(λ₁ - λ₂)(v₁ ⋅ v₂) = 0 ⇒ v₁ ⊥ v₂',
                  style: AppTypography.bodySm.copyWith(
                    fontFamily: 'monospace',
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

  Widget _buildMatrixDrawer(
    WidgetRef ref,
    List<dynamic> questions,
    int currentIndex,
  ) {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BENCHMARK MATRIX (${questions.length} ITEMS)',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMediumContrast,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
              Text(
                '33% Recorded',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 12 items grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, i) {
              final isCurrent = i == currentIndex;
              final isAnswered = i < currentIndex;

              Color bg;
              Color text;
              if (isCurrent) {
                bg = AppColors.primary;
                text = AppColors.onPrimary;
              } else if (isAnswered) {
                bg = AppColors.tertiaryContainer.withValues(alpha: 0.3);
                text = AppColors.primary;
              } else {
                bg = AppColors.surfaceContainerHigh;
                text = AppColors.textMediumContrast;
              }

              return InkWell(
                onTap: () => ref.read(activeQuizProvider.notifier).goToQuestion(i),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(4),
                    border: isCurrent
                        ? Border.all(color: AppColors.primary, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
    int totalCount,
  ) {
    final isLast = currentIndex >= totalCount - 1;

    return Row(
      children: [
        // Previous Button
        if (currentIndex > 0) ...[
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => ref
                    .read(activeQuizProvider.notifier)
                    .goToQuestion(currentIndex - 1),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHigh,
                  foregroundColor: AppColors.textHighContrast,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],

        // Next / Submit Button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isLast) {
                  context.go('/results/a0000000-0000-0000-0000-000000000001');
                } else {
                  ref
                      .read(activeQuizProvider.notifier)
                      .goToQuestion(currentIndex + 1);
                }
              },
              icon: Icon(
                isLast ? Icons.check_circle_outline : Icons.arrow_forward,
                size: 18,
              ),
              label: Text(
                isLast ? 'Submit Assessment' : 'Next Benchmark',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
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
        ),
      ],
    );
  }
}

class _ProofVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final axis = Paint()
      ..color = AppColors.textMediumContrast
      ..strokeWidth = 1.2;

    final limeLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.5;

    final amberLine = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 1.5;

    // Axes
    canvas.drawLine(Offset(4, h - 4), Offset(w - 4, h - 4), axis);
    canvas.drawLine(Offset(4, h - 4), Offset(4, 4), axis);

    // Orthogonal Vectors
    canvas.drawLine(Offset(4, h - 4), Offset(w * 0.7, h * 0.3), amberLine);
    canvas.drawLine(Offset(4, h - 4), Offset(w * 0.5, h * 0.6), limeLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
