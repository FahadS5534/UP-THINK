import 'package:flutter_test/flutter_test.dart';
import 'package:upthink/core/widgets/severity_badge.dart';
import 'package:upthink/shared/models/app_user.dart';
import 'package:upthink/shared/models/learning_gap.dart';
import 'package:upthink/shared/models/study_plan.dart';
import 'package:upthink/shared/models/assessment.dart';
import 'package:upthink/shared/models/tutor_message.dart';

void main() {
  group('AppUser Model Tests', () {
    test('Correctly deserializes student role from JSON', () {
      final json = {
        'id': 'usr-123',
        'email': 'student@university.edu',
        'full_name': 'Elena Rostova',
        'role': 'STUDENT',
        'department': 'Electrical Engineering',
        'study_volume_hours': 64.5,
        'mastered_nodes_count': 148,
      };

      final user = AppUser.fromJson(json);
      expect(user.id, 'usr-123');
      expect(user.fullName, 'Elena Rostova');
      expect(user.role, UserRole.student);
      expect(user.isFacilitator, false);
      expect(user.studyVolumeHours, 64.5);
      expect(user.masteredNodesCount, 148);
    });

    test('Correctly deserializes facilitator role from JSON', () {
      final json = {
        'id': 'fac-456',
        'email': 'professor@university.edu',
        'full_name': 'Dr. Aris Thorne',
        'role': 'FACILITATOR',
        'department': 'Computer Science',
      };

      final user = AppUser.fromJson(json);
      expect(user.id, 'fac-456');
      expect(user.role, UserRole.facilitator);
      expect(user.isFacilitator, true);
    });
  });

  group('LearningGap Model Tests', () {
    test('Parses HIGH severity learning gap accurately', () {
      final json = {
        'id': 'gap-1',
        'topic_name': 'Eigenvalues & Spectral Radius',
        'course_code': 'MATH 302',
        'node_code': 'Node #MATH-401',
        'mastery_percentage': 42.0,
        'severity': 'HIGH',
        'diagnosis': 'Matrix diagonalization edge cases',
        'recommended_action': 'Review 15m module',
      };

      final gap = LearningGap.fromJson(json);
      expect(gap.id, 'gap-1');
      expect(gap.topicName, 'Eigenvalues & Spectral Radius');
      expect(gap.masteryPercentage, 42.0);
      expect(gap.severity, GapSeverity.high);
    });
  });

  group('StudyPlan & StudyTask Model Tests', () {
    test('Handles task toggle and progress updates', () {
      const task1 = StudyTask(
        id: 't-1',
        planId: 'plan-1',
        title: 'Complete Orthogonal Projections Diagnostic',
        description: 'Verify understanding of dot products',
        taskType: StudyTaskType.practiceDrills,
        priority: StudyPriority.high,
        estimatedMinutes: 25,
        scheduledTime: '10:30 AM • 25m',
        isCompleted: false,
      );

      const task2 = StudyTask(
        id: 't-2',
        planId: 'plan-1',
        title: 'Review Fourier Transform duality notes',
        description: 'Spectral duality properties',
        taskType: StudyTaskType.reviewFundamentals,
        priority: StudyPriority.medium,
        estimatedMinutes: 15,
        scheduledTime: '02:00 PM • 15m',
        isCompleted: true,
      );

      const plan = StudyPlan(
        id: 'plan-1',
        studentId: 'usr-1',
        title: 'Weekly Focus Calibration',
        planningDate: 'OCT 25 - NOV 01',
        completedHours: 3.5,
        targetHours: 6.0,
        onTrackPercentage: 75.0,
        remainingTimeText: '1h 30m remaining',
        aiSyncInfo: 'Calibrated via diagnostic gaps',
        tasks: [task1, task2],
      );

      expect(plan.tasks.length, 2);
      expect(plan.tasks[0].isCompleted, false);
      expect(plan.tasks[1].isCompleted, true);

      // Toggle task 1
      final updatedTask1 = task1.copyWith(isCompleted: true);
      final updatedPlan = plan.copyWithTasks([updatedTask1, task2]);
      expect(updatedPlan.tasks[0].isCompleted, true);
    });
  });

  group('Assessment Model Tests', () {
    test('Parses question options and answer choices correctly', () {
      final json = {
        'id': 'q-1',
        'assessment_id': 'asmt-1',
        'order_index': 1,
        'topic_tag': 'Spectral Theorem • Real Symmetric',
        'points': 5,
        'prompt_stem': 'What is the divergence of a solenoidal vector field?',
        'options': [
          {'id': 'A', 'text': 'Zero everywhere'},
          {'id': 'B', 'text': 'Equal to curl'},
          {'id': 'C', 'text': 'Non-zero scalar'},
        ],
      };

      final q = AssessmentQuestion.fromJson(json);
      expect(q.id, 'q-1');
      expect(q.options.length, 3);
      expect(q.options[0].id, 'A');
      expect(q.options[0].text, 'Zero everywhere');
      expect(q.promptStem, 'What is the divergence of a solenoidal vector field?');
    });
  });

  group('TutorMessage Model Tests', () {
    test('Parses citations with verifiable source metadata', () {
      final json = {
        'id': 'msg-1',
        'sender_role': 'assistant',
        'content': 'The Fourier Transform decomposes an arbitrary function into constituent frequencies.',
        'time_label': '10:42 AM',
        'citations': [
          {
            'title': 'Signals and Systems Syllabus',
            'detail': 'Section 4.2 - Continuous-Time Fourier Transform',
            'excerpt': 'Equations 4.10 through 4.12 demonstrate spectral duality.',
          }
        ],
      };

      final msg = TutorMessage.fromJson(json);
      expect(msg.isAssistant, true);
      expect(msg.citations.length, 1);
      expect(msg.citations.first.title, 'Signals and Systems Syllabus');
      expect(msg.citations.first.detail, 'Section 4.2 - Continuous-Time Fourier Transform');
    });
  });
}
