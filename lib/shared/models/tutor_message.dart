/// Academic RAG Source Citation
class SourceCitation {
  final String title;
  final String detail;
  final String excerpt;

  const SourceCitation({
    required this.title,
    required this.detail,
    required this.excerpt,
  });

  factory SourceCitation.fromJson(Map<String, dynamic> json) {
    return SourceCitation(
      title: json['title'] as String? ?? 'MATH 204: Theorem 6.4 (Spectral)',
      detail: json['detail'] as String? ?? 'Lecture 14 · Slide 18 · Vector distance: 0.082',
      excerpt: json['excerpt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'detail': detail,
      'excerpt': excerpt,
    };
  }
}

/// Upthink AI Tutor Message Model
class TutorMessage {
  final String id;
  final String senderRole; // user, assistant, system
  final String content;
  final String? formulaIdentity;
  final String? formulaBody;
  final String? formulaExplanation;
  final List<String> takeaways;
  final List<SourceCitation> citations;
  final String timeLabel;

  const TutorMessage({
    required this.id,
    required this.senderRole,
    required this.content,
    this.formulaIdentity,
    this.formulaBody,
    this.formulaExplanation,
    this.takeaways = const [],
    this.citations = const [],
    this.timeLabel = 'Just now',
  });

  bool get isUser => senderRole == 'user';
  bool get isAssistant => senderRole == 'assistant';

  factory TutorMessage.fromJson(Map<String, dynamic> json) {
    final rawTakeaways = json['takeaways'] as List<dynamic>? ?? [];
    final rawCitations = json['citations'] as List<dynamic>? ?? [];

    return TutorMessage(
      id: json['id'] as String? ?? '',
      senderRole: json['sender_role'] as String? ?? 'assistant',
      content: json['content'] as String? ?? '',
      formulaIdentity: json['formula_identity'] as String?,
      formulaBody: json['formula_body'] as String?,
      formulaExplanation: json['formula_explanation'] as String?,
      takeaways: rawTakeaways.map((e) => e.toString()).toList(),
      citations: rawCitations
          .map((c) => SourceCitation.fromJson(c as Map<String, dynamic>))
          .toList(),
      timeLabel: json['time_label'] as String? ?? 'Just now',
    );
  }
}
