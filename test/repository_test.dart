import 'package:flutter_test/flutter_test.dart';
import 'package:upthink/core/widgets/severity_badge.dart';
import 'package:upthink/features/auth/data/auth_repository.dart';
import 'package:upthink/features/learning_gaps/data/learning_gap_repository.dart';
import 'package:upthink/features/study_plans/data/study_plan_repository.dart';
import 'package:upthink/features/assessments/data/assessment_repository.dart';
import 'package:upthink/features/facilitator/data/facilitator_repository.dart';

void main() {
  group('AuthRepository Tests', () {
    test('Returns default demo student when offline', () {
      final student = AuthRepository.getDemoStudent();
      expect(student.fullName, 'Elena Vass');
      expect(student.isFacilitator, false);
      expect(student.email, 'elena.vass@oxford.ac.uk');
    });

    test('Returns default demo facilitator when switched', () {
      final facilitator = AuthRepository.getDemoFacilitator();
      expect(facilitator.fullName, 'Dr. Charles Hawthorne');
      expect(facilitator.isFacilitator, true);
      expect(facilitator.department, 'Faculty of Mathematics');
    });
  });

  group('LearningGapRepository Tests', () {
    test('Provides fallback diagnostic gaps overview with high severity', () async {
      final repo = LearningGapRepository();
      final overview = await repo.getLearningGapsOverview();
      expect(overview.items.isNotEmpty, true);

      final hasHighSeverity = overview.items.any((item) => item.gap.severity == GapSeverity.high);
      expect(hasHighSeverity, true);

      final eigenItem = overview.items.firstWhere((item) => item.gap.topicName.contains('Eigenvalues'));
      expect(eigenItem.gap.masteryPercentage, 42.0);
    });
  });

  group('StudyPlanRepository Tests', () {
    test('Generates structured tasks tied to academic weaknesses', () async {
      final repo = StudyPlanRepository();
      final plan = await repo.getStudyPlan();

      expect(plan.title, isNotEmpty);
      expect(plan.tasks.isNotEmpty, true);
      expect(plan.tasks.any((t) => t.isCompleted), true);
    });
  });

  group('AssessmentRepository Tests', () {
    test('Provides diagnostic questions with answer options', () async {
      final repo = AssessmentRepository();
      final questions = await repo.getQuestions('asmt-diag-1');

      expect(questions.length, 12);
      for (final q in questions) {
        expect(q.options.length, 4);
        expect(q.promptStem.isNotEmpty, true);
      }
    });

    test('Authoritatively computes submission score results', () async {
      final repo = AssessmentRepository();
      final result = await repo.submitAssessment(
        assessmentId: 'asmt-diag-1',
        answers: {'q-1': 'A', 'q-2': 'B', 'q-3': 'A', 'q-4': 'B', 'q-5': 'C'},
        durationSeconds: 1120,
      );

      expect(result.aggregateMastery, greaterThan(0));
      expect(result.domains.isNotEmpty, true);
      expect(result.cognitiveGap.title.isNotEmpty, true);
    });
  });

  group('FacilitatorRepository Tests', () {
    test('Returns cohort performance and critical learning gaps', () async {
      final repo = FacilitatorRepository();
      final cohort = await repo.getCohortAnalytics('cohort-ee-302');

      expect(cohort.name, isNotEmpty);
      expect(cohort.totalEnrolled, 46);
      expect(cohort.actionRequiredCount, 7);
      expect(cohort.scoreDistribution.isNotEmpty, true);
    });
  });
}
