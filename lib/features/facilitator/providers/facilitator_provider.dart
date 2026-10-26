import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/assessment.dart';
import '../../../shared/models/cohort.dart';
import '../data/facilitator_repository.dart';

final facilitatorRepositoryProvider = Provider<FacilitatorRepository>((ref) {
  return FacilitatorRepository();
});

final facilitatorCohortAnalyticsProvider = FutureProvider.family<CohortData, String>((ref, cohortId) async {
  final repo = ref.watch(facilitatorRepositoryProvider);
  return repo.getCohortAnalytics(cohortId);
});

final facilitatorAssessmentsProvider = FutureProvider<List<Assessment>>((ref) async {
  final repo = ref.watch(facilitatorRepositoryProvider);
  return repo.getFacilitatorAssessments();
});
