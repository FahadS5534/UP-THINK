import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/learning_gap_repository.dart';

final learningGapRepositoryProvider = Provider<LearningGapRepository>((ref) {
  return LearningGapRepository();
});

final learningGapsOverviewProvider = FutureProvider<LearningGapsOverview>((ref) async {
  final repo = ref.watch(learningGapRepositoryProvider);
  return repo.getLearningGapsOverview();
});
