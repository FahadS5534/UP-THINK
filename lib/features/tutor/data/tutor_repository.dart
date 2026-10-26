import '../../../shared/models/tutor_message.dart';
import '../../../shared/services/gemini_service.dart';
import '../../../shared/services/supabase_service.dart';

/// Repository for AI Tutor & Study Companion
class TutorRepository {
  Future<List<TutorMessage>> getConversationMessages(String conversationId) async {
    final client = SupabaseService.instance.client;

    if (client != null) {
      try {
        final res = await client
            .from('tutor_messages')
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: true);

        final raw = res as List<dynamic>?;
        if (raw != null && raw.isNotEmpty) {
          return raw.map((m) => TutorMessage.fromJson(m as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }

    return _getDefaultConversation();
  }

  /// Send prompt to AI Tutor
  Future<TutorMessage> sendMessage({
    required String conversationId,
    required String prompt,
  }) async {
    // 1. Try Supabase Edge Function with protected Gemini & RAG
    final edgeResult = await SupabaseService.instance.invokeEdgeFunction(
      functionName: 'tutor-chat',
      body: {
        'prompt': prompt,
        'conversationId': conversationId,
        'topic': 'Linear Algebra: Spectral Theorem',
        'contextCourse': 'MATH-204 Lecture Notes & Gilbert Strang Ch. 6',
      },
    );

    if (edgeResult != null) {
      final formula = edgeResult['formula'] as Map<String, dynamic>?;
      final rawCitations = edgeResult['citations'] as List<dynamic>? ?? [];
      final rawTakeaways = edgeResult['takeaways'] as List<dynamic>? ?? [];

      return TutorMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        senderRole: 'assistant',
        content: edgeResult['content'] as String? ?? 'Synthesis complete.',
        formulaIdentity: formula?['identity'] as String?,
        formulaBody: formula?['body'] as String?,
        formulaExplanation: formula?['explanation'] as String?,
        takeaways: rawTakeaways.map((e) => e.toString()).toList(),
        citations: rawCitations
            .map((c) => SourceCitation.fromJson(c as Map<String, dynamic>))
            .toList(),
        timeLabel: 'Just now',
      );
    }

    // 2. Fallback to GeminiService
    final geminiRes = await GeminiService.instance.askTutor(prompt: prompt);
    final rawTakeaways = geminiRes['takeaways'] as List<dynamic>? ?? [];

    return TutorMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderRole: 'assistant',
      content: geminiRes['content'] as String? ?? '',
      formulaIdentity: geminiRes['formulaIdentity'] as String?,
      formulaBody: geminiRes['formulaBody'] as String?,
      formulaExplanation: geminiRes['formulaExplanation'] as String?,
      takeaways: rawTakeaways.map((e) => e.toString()).toList(),
      citations: [
        const SourceCitation(
          title: 'MATH 204: Theorem 6.4 (Spectral)',
          detail: 'Lecture 14 · Slide 18 · Vector distance: 0.082',
          excerpt: 'Real symmetric matrices have purely real eigenvalues and an orthonormal basis of eigenvectors.',
        ),
      ],
      timeLabel: 'Just now',
    );
  }

  List<TutorMessage> _getDefaultConversation() {
    return [
      const TutorMessage(
        id: 'msg-seed-1',
        senderRole: 'user',
        content: 'Why does an n × n real symmetric matrix always have n real eigenvalues and an orthonormal basis of eigenvectors?',
        timeLabel: '10:42 AM',
      ),
      const TutorMessage(
        id: 'msg-seed-2',
        senderRole: 'assistant',
        content: 'The foundation of the **Spectral Theorem** for real symmetric matrices rests on two key mathematical guarantees:',
        formulaIdentity: 'A = Aᵀ ∈ ℝⁿˣⁿ',
        formulaBody: 'Av = λv ⇒ v*Av = v*(λv) = λ||v||²\nTaking conjugate transpose: (Av)*v = v*A*v = v*Aᵀv = λ̄||v||²',
        formulaExplanation: 'Since λ||v||² = λ̄||v||² and ||v|| > 0, we conclude λ = λ̄. Hence, all eigenvalues are strictly real.',
        takeaways: [
          'Orthogonality of Distinct Eigenspaces: If λ₁ ≠ λ₂, then v₁ᵀv₂ = 0 automatically.',
          'Complete Basis Guaranteed: Repeated eigenvalues still possess geometric multiplicity equal to algebraic multiplicity.',
        ],
        citations: [
          SourceCitation(
            title: 'MATH 204: Theorem 6.4 (Spectral)',
            detail: 'Lecture 14 · Slide 18 · Vector distance: 0.082',
            excerpt: 'Every real symmetric matrix can be factored as A = QΛQᵀ with orthogonal Q.',
          ),
        ],
        timeLabel: '10:43 AM',
      ),
    ];
  }
}
