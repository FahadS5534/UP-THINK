import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../shared/models/tutor_message.dart';
import '../providers/tutor_provider.dart';

/// Screen 2: AI Tutor — Study Companion
class AiTutorScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const AiTutorScreen({
    super.key,
    this.conversationId = 'conv-spectral-1',
  });

  @override
  ConsumerState<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends ConsumerState<AiTutorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSynthesizing = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? promptOverride]) async {
    final text = promptOverride ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (promptOverride == null) {
      _textController.clear();
    }

    setState(() => _isSynthesizing = true);
    _scrollToBottom();

    try {
      await ref
          .read(tutorMessagesProvider(widget.conversationId).notifier)
          .sendPrompt(text);
    } finally {
      if (mounted) {
        setState(() => _isSynthesizing = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(tutorMessagesProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Messages Feed with Header & Topology Cards
            Expanded(
              child: messagesAsync.when(
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
                data: (messages) => ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    // Topic Context Metadata Card
                    _buildContextMetadataCard(),
                    const SizedBox(height: 14),

                    // Interactive Concept Node Hierarchy Widget
                    _buildConceptNodeHierarchyWidget(),
                    const SizedBox(height: 16),

                    // Messages Stream
                    ...messages.map((msg) => _buildMessageBubble(msg)),

                    // Synthesizing Indicator
                    if (_isSynthesizing) ...[
                      const SizedBox(height: 8),
                      _buildSynthesizingIndicator(),
                    ],
                    const SizedBox(height: 14),

                    // Dynamic Follow-up Action Pills
                    _buildSuggestedExplorationSection(),
                  ],
                ),
              ),
            ),

            // Academic Tutor Input Dock
            _buildInputDock(),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMetadataCard() {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'STUDY COMPANION',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Synced Knowledge Base',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        color: AppColors.textMediumContrast,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Linear Algebra: Spectral Theorem',
            style: AppTypography.headlineSm.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textHighContrast,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'MATH-204 Lecture Notes & Gilbert Strang Ch. 6',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textMediumContrast,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Referencing 3 course embeddings + 1 textbook node',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMediumContrast,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConceptNodeHierarchyWidget() {
    return GlassPanel(
      backgroundColor: AppColors.surfaceContainer,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONCEPT NODE HIERARCHY',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.textMediumContrast,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.insights,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Inspect Matrix',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Node Lattice Canvas
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: _NodeLatticePainter(),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          'Active Focus: Symmetric Decomp.',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.textHighContrast,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TutorMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, left: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'You (Student)',
                  style: AppTypography.labelSm.copyWith(fontSize: 11),
                ),
                const SizedBox(width: 6),
                Text(
                  msg.timeLabel,
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 10,
                    color: AppColors.textLowContrast,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                msg.content,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textHighContrast,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Assistant Response
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'λ',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Companion AI',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                msg.timeLabel,
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10,
                  color: AppColors.textLowContrast,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: msg.content,
                  styleSheet: MarkdownStyleSheet(
                    p: AppTypography.bodyMd.copyWith(height: 1.5),
                    strong: AppTypography.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHighContrast,
                    ),
                  ),
                ),

                // Formal Formula Callout Block
                if (msg.formulaBody != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FORMAL IDENTITY',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                            if (msg.formulaIdentity != null)
                              Text(
                                msg.formulaIdentity!,
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textMediumContrast,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          msg.formulaBody!,
                          style: AppTypography.bodyMd.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.primary,
                            height: 1.4,
                          ),
                        ),
                        if (msg.formulaExplanation != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            msg.formulaExplanation!,
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.textMediumContrast,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Academic Takeaways
                if (msg.takeaways.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'KEY TAKEAWAYS',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textMediumContrast,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...msg.takeaways.map((takeaway) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                takeaway,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.textHighContrast,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                // Source Citation Card
                if (msg.citations.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ...msg.citations.map((c) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.verified_outlined,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.title,
                                  style: AppTypography.labelSm.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textHighContrast,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  c.detail,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.textMediumContrast,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: AppColors.textMediumContrast,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynthesizingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Synthesizing answer using Gemini & course vectors...',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.textMediumContrast,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedExplorationSection() {
    final suggestions = [
      {'icon': Icons.lightbulb_outline, 'label': 'Explain this simply', 'color': AppColors.primary},
      {'icon': Icons.quiz_outlined, 'label': 'Give me a practice question', 'color': AppColors.secondary},
      {'icon': Icons.view_in_ar, 'label': 'Show geometric intuition', 'color': AppColors.tertiaryFixed},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SUGGESTED EXPLORATION',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
                letterSpacing: 1.0,
                fontSize: 10,
              ),
            ),
            Text(
              'Tap to ask',
              style: AppTypography.labelSm.copyWith(
                color: AppColors.textMediumContrast,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: suggestions.map((s) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  onPressed: () => _handleSend(s['label'] as String),
                  avatar: Icon(
                    s['icon'] as IconData,
                    size: 14,
                    color: s['color'] as Color,
                  ),
                  label: Text(
                    s['label'] as String,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.textHighContrast,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: AppColors.surfaceContainerHigh,
                  side: const BorderSide(color: AppColors.glassBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInputDock() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Attach button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.attach_file, size: 20),
                color: AppColors.textMediumContrast,
                tooltip: 'Attach notes',
              ),
              // Mic button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic_none, size: 20),
                color: AppColors.textMediumContrast,
                tooltip: 'Voice dictation',
              ),
              // Input field
              Expanded(
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _handleSend(),
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textHighContrast),
                    decoration: InputDecoration(
                      hintText: 'Ask your companion or paste equation...',
                      hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.textLowContrast),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send Button
              InkWell(
                onTap: _handleSend,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66C8F169),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    size: 20,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.token_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Context: 4,120 / 32k tokens',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: AppColors.textMediumContrast,
                    ),
                  ),
                ],
              ),
              Text(
                'LATEX & MARKDOWN ENABLED',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 9,
                  color: AppColors.textLowContrast,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NodeLatticePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final limeLine = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0;

    final subtleLine = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 1.5;

    final pTop = Offset(w * 0.5, h * 0.2);
    final pLeft = Offset(w * 0.3, h * 0.5);
    final pRight = Offset(w * 0.7, h * 0.5);
    final pBottom = Offset(w * 0.5, h * 0.8);

    canvas.drawLine(pTop, pLeft, limeLine);
    canvas.drawLine(pTop, pRight, subtleLine);
    canvas.drawLine(pLeft, pRight, limeLine);
    canvas.drawLine(pLeft, pBottom, subtleLine);
    canvas.drawLine(pRight, pBottom, limeLine);

    final limeNode = Paint()..color = AppColors.primary;
    final darkNode = Paint()..color = AppColors.surfaceContainer;
    final amberNode = Paint()..color = AppColors.secondary;

    canvas.drawCircle(pTop, 8, limeNode);
    canvas.drawCircle(pLeft, 9, limeNode);
    canvas.drawCircle(pRight, 9, darkNode);
    canvas.drawCircle(pRight, 9, subtleLine);
    canvas.drawCircle(pBottom, 8, amberNode);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
