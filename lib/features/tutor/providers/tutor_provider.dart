import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/tutor_message.dart';
import '../data/tutor_repository.dart';

final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  return TutorRepository();
});

class TutorConversationNotifier extends AsyncNotifier<List<TutorMessage>> {
  final String conversationId;

  TutorConversationNotifier(this.conversationId);

  @override
  Future<List<TutorMessage>> build() async {
    final repo = ref.watch(tutorRepositoryProvider);
    return repo.getConversationMessages(conversationId);
  }

  Future<void> sendPrompt(String prompt) async {
    final currentMessages = state.value ?? [];
    final userMsg = TutorMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      senderRole: 'user',
      content: prompt,
      timeLabel: 'Just now',
    );

    // Optimistically append student message
    state = AsyncValue.data(<TutorMessage>[...currentMessages, userMsg]);

    try {
      final repo = ref.read(tutorRepositoryProvider);
      final assistantMsg = await repo.sendMessage(
        conversationId: conversationId,
        prompt: prompt,
      );
      final updated = <TutorMessage>[...state.value ?? [], assistantMsg];
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tutorMessagesProvider = AsyncNotifierProvider.family<TutorConversationNotifier, List<TutorMessage>, String>((id) {
  return TutorConversationNotifier(id);
});
